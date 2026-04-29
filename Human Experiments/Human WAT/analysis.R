library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
library(lme4)
library(lmerTest)
library(emmeans)

# Read data
data <- read.csv("WAT_humans_data.csv") %>%
  slice(-(1:2))

names_df <- read.csv("C:/Users/hedwi/OneDrive/names_wat.csv",
                     stringsAsFactors = FALSE, sep = ";")

# Word and name stimuli
straattaal_words <- c("Osso", "Patta", "Waggie", "Fittie", "Pokoe", "Doekoe")
standDutch_words <- c("Huis", "Schoen", "Auto", "Ruzie", "Liedje", "Geld")

mig_names <- c("Ayoub", "Mohamed", "Ilias", "Murat", "Salma", "Samira", "Fatma", "Amira")
nl_names  <- c("Martijn", "Dennis", "Jesse", "Thomas", "Anna", "Laura", "Julia", "Esther")

# Make data frame with demographic information
demographics_df <- data %>%
  select(
    age, gender, gender_5_TEXT,
    education, education_7_TEXT,
    location, location_3_TEXT,
    nl_born, nl_born_2_TEXT,
    nl_parents, nl_parents_2_TEXT,
    languages, straattaal_user
  ) %>%
  mutate(
    age = as.numeric(age),
    gender_clean    = if_else(gender    == "Other", gender_5_TEXT,    gender),
    education_clean = if_else(education == "Other", education_7_TEXT, education),
    location_clean  = if_else(location  == "Other", location_3_TEXT,  location)
  )

# Summary of demographics
demographics_summary <- demographics_df %>%
  summarise(
    n = n(),
    mean_age = mean(age, na.rm = TRUE),
    sd_age   = sd(age, na.rm = TRUE),
    min_age  = min(age, na.rm = TRUE),
    max_age  = max(age, na.rm = TRUE)
  )

demographics_by_group <- demographics_df %>%
  group_by(straattaal_user) %>%
  summarise(
    n = n(),
    mean_age = mean(age, na.rm = TRUE),
    sd_age   = sd(age,   na.rm = TRUE),
    min_age  = min(age,  na.rm = TRUE),
    max_age  = max(age,  na.rm = TRUE),
    .groups  = "drop"
  )

# Counts of demographics
demographics_counts <- list(
  gender    = count(demographics_df, gender_clean,    straattaal_user),
  education = count(demographics_df, education_clean, straattaal_user),
  location  = count(demographics_df, location_clean,  straattaal_user),
  nl_born   = count(demographics_df, nl_born,         straattaal_user),
  nl_parents= count(demographics_df, nl_parents,      straattaal_user)
)

# Analyse relative rating scores
RR_df <- data %>%
  select(starts_with("RR"), straattaal_user, prolific_id) %>%
  mutate(across(starts_with("RR"), as.numeric)) %>%
  mutate(
    diff_age       = RR_age_NED_1       - RR_age_STR_1,
    diff_ethnicity = RR_ethnicity_NED_1 - RR_ethnicity_STR_1,
    diff_gender    = RR_gender_NED_1    - RR_gender_STR_1,
    diff_rating    = RR_rating_NED_1    - RR_rating_STR_1,
    diff_location  = RR_location_STR_1  - RR_location_NED_1,
    diff_class     = RR_class_NED_1     - RR_class_STR_1
  )

RR_long <- RR_df %>%
  pivot_longer(starts_with("diff_"),
               names_to = "attribute",
               values_to = "rating_diff") %>%
  mutate(attribute = str_remove(attribute, "diff_"))

# Plot RR scores
ggplot(RR_long, aes(attribute, rating_diff, fill = attribute)) +
  geom_boxplot(color = "black", width = 0.6,
               outlier.shape = 21, outlier.fill = "white") +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  scale_fill_grey(start = 0.7, end = 0.3) +
  labs(x = "Attribute", y = "Relative Rating Difference") +
  theme_minimal(base_family = "Times New Roman") +
  theme(legend.position = "none")

# Plot for different Straattaal groeps
ggplot(RR_long, aes(straattaal_user, rating_diff, fill = straattaal_user)) +
  geom_boxplot(color = "black") +
  geom_hline(yintercept = 0, color = "red", linetype = "dotted") +
  facet_wrap(~attribute, scales = "free_y") +
  scale_fill_grey(start = 0.35, end = 0.8) +
  theme_minimal(base_family = "Times New Roman") +
  theme(legend.position = "none")

# One-sample t-test Relative rating test
rr_vars <- c("diff_age", "diff_class", "diff_ethnicity",
             "diff_gender", "diff_location", "diff_rating")

rr_ttests <- lapply(rr_vars, function(v) {
  t.test(RR_df[[v]], mu = 0)
})
names(rr_ttests) <- rr_vars

# Linear model for effect of group membership on RR scores
rr_models <- lapply(rr_vars, function(v) {
  lm(as.formula(paste(v, "~ straattaal_user")), data = RR_df)
})
names(rr_models) <- rr_vars

# Create WAT data frame
WAT_df <- data %>%
  select(prolific_id, straattaal_user, starts_with("X")) %>%
  rowwise() %>%
  mutate(across(starts_with("X"), ~{
    item <- cur_column()
    value <- .
    
    row_id <- as.numeric(str_extract(item, "\\d+"))
    gender <- str_extract(item, "(?<=_)\\w(?=_)")
    row_adj <- if_else(gender == "f", row_id + 16, row_id)
    
    case_when(
      value == "${lm://Field/1}" ~ names_df[row_adj, 1],
      value == "${lm://Field/2}" ~ names_df[row_adj, 2],
      TRUE ~ NA_character_
    )
  }))

# Count the amount of associations
counts_df <- WAT_df %>%
  pivot_longer(starts_with("X"),
               names_to = "column",
               values_to = "response") %>%
  mutate(
    word          = str_match(column, "^X\\d+_([^_]+)_")[,2],
    category      = str_extract(column, "(f_L|f_nL|m_L|m_nL)"),
    is_mig        = response %in% mig_names,
    is_nl         = response %in% nl_names,
    is_straattaal = word %in% straattaal_words,
    is_standard   = word %in% standDutch_words
  ) %>%
  filter(!is.na(category)) %>%
  group_by(prolific_id, straattaal_user, category) %>%
  summarise(
    nr_mig        = sum(is_mig),
    nr_nl         = sum(is_nl),
    nr_stereo_mig = sum(is_mig & is_straattaal),
    nr_stereo_nl  = sum(is_nl  & is_standard),
    .groups = "drop"
  )

# Calculate bias scores
bias_df <- counts_df %>%
  mutate(
    bias = (nr_stereo_mig / nr_mig) +
      (nr_stereo_nl  / nr_nl) - 1
  ) %>%
  pivot_wider(names_from = category, values_from = bias) %>%
  rowwise() %>%
  mutate(
    mean_L  = mean(c_across(ends_with("_L")),  na.rm = TRUE),
    mean_nL = mean(c_across(ends_with("_nL")), na.rm = TRUE)
  ) %>%
  ungroup()

bias_long <- bias_df %>%
  pivot_longer(c(mean_L, mean_nL),
               names_to  = "condition",
               values_to = "mean_bias")

# T-test deviation bias score 0
t.test(bias_long$mean_bias, mu = 0)

# Plot bias scores over Straattaal groups (not in Thesis)
ggplot(bias_long, aes(condition, mean_bias, fill = straattaal_user)) +
  geom_boxplot(color = "black") +
  geom_hline(yintercept = 0, color = "red", linetype = "dotted") +
  theme_minimal(base_family = "Times New Roman")

# Mixed model for Straattaal user
model <- lmer(mean_bias ~ condition * straattaal_user + (1 | prolific_id),
              data = bias_long)
summary(model)

# Summarize for label or not label
bias_mean_df <- bias_df %>%
  group_by(prolific_id) %>%
  summarise(mean_bias = mean(c(mean_L, mean_nL), na.rm = TRUE))

ethnicity_df <- RR_df %>%
  group_by(prolific_id) %>%
  summarise(diff_ethnicity = mean(diff_ethnicity, na.rm = TRUE))

# Calculate correlation RR and WAT
corr_df <- inner_join(bias_mean_df, ethnicity_df, by = "prolific_id")
cor.test(corr_df$mean_bias, corr_df$diff_ethnicity)
