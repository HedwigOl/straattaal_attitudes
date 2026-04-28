library(lmerTest)
library(dplyr)
library(readr)
library(tidyverse)
library(emmeans)

# Folders containing in- and outgroup responses
data_folder_outgroup <- "outgroup_responses"
data_folder_ingroup  <- "ingroup_responses"

# Get all files from folders
files_outgroup <- list.files(data_folder_outgroup, pattern = "\\.csv$", full.names = TRUE)
files_ingroup  <- list.files(data_folder_ingroup,  pattern = "\\.csv$", full.names = TRUE)

# Create clean data frame of explicit ratings
clean_explicit_questions <- function(file){
  
  df <- read_csv(file, show_col_types = FALSE)
  
  # Extract trials related to questions
  question_trials <- df[df$trial_type %in% c("survey-html-form"), ]
  
  # Detect order of questions
  question_order <- any(
    question_trials$trial_index == 682 &
      grepl("Standaard", question_trials$response, ignore.case = TRUE)
  )
  
  # Function to extract numeric scores for an attribute
  extract_score <- function(attribute, field) {
    sapply(field, function(x) {
      m <- regmatches(x, regexec(paste0("'", attribute, "_[^']+': '?(\\d+)'?"), x))[[1]]
      as.numeric(m[2])
    })
  }
  
  explicit_questions <- data.frame(
    subject_ID   = question_trials$subject_ID,
    lang_variety = sub(".*Ethnicity_([^']+)'.*", "\\1", question_trials$response),
    ethnicity    = extract_score("Ethnicity", question_trials$response),
    gender       = extract_score("Gender",    question_trials$response),
    age          = extract_score("Age",       question_trials$response),
    location     = extract_score("Location",  question_trials$response),
    class        = extract_score("Class",     question_trials$response),
    rating       = extract_score("Rating",    question_trials$response),
    order        = ifelse(question_order, 1, 2)
  )
  
  # Function to extract responses from html form
  extract_field <- function(x, field) {
    m <- regexec(paste0("'", field, "'\\s*:\\s*'([^']*)'"), x)
    out <- regmatches(x, m)
    sapply(out, function(z) if (length(z) > 1) z[2] else NA)
  }
  
  # Delete rows with non-rating questions
  explicit_responses <- explicit_questions[-c(nrow(explicit_questions)-1, nrow(explicit_questions)), ]
  
  return (explicit_responses)
}

# Combine in-group and out-group ratings into one data frame
expl_outgroup <- bind_rows(lapply(files_outgroup, clean_explicit_questions))
expl_ingroup  <- bind_rows(lapply(files_ingroup,  clean_explicit_questions)) 
expl_all      <- bind_rows(expl_outgroup, expl_ingroup)

# Add demographic information to all rows
dem_df <- read_csv("demographics.csv", show_col_types = FALSE)
expl_all$subject_ID <- as.character(expl_all$subject_ID)
dem_df$subject_ID   <- as.character(dem_df$subject_ID)
explicit_data       <- inner_join(expl_all, dem_df, by = "subject_ID")

explicit_data <- explicit_data %>%
  rename(
    age                = age.x,
    participant_age    = age.y,
    gender             = gender.x,
    participant_gender = gender.y
  )

# List of attributes
numeric_cols <- c("ethnicity", "gender", "age", "location", "class", "rating") 

# Calculate difference between Standard Dutch and Straattaal score
explicit_data_diff <- explicit_data %>%
  group_by(subject_ID, group_membership, order, straattaal_user) %>%
  summarise(
    across(all_of(numeric_cols),
           ~ .[lang_variety == "STANDAARD NEDERLANDS"] - .[lang_variety == "STRAATTAAL"]),
    .groups = "drop"
  )

# Make rating for location match stereotypes
explicit_data_diff <- explicit_data_diff %>%
  mutate(location = -location)

explicit_data_diff$group_membership <- recode(explicit_data_diff$group_membership,
                                             "ingroup"  = "In-group",
                                             "outgroup" = "Out-group")

explicit_data_diff$straattaal_user  <- recode(explicit_data_diff$straattaal_user,
                                      "Ja"  = "In-group",
                                      "Nee" = "Out-group")

# Correct specific subject_ID
explicit_data_diff <- explicit_data_diff %>%
  mutate(subject_ID = if_else(subject_ID == "7070" & age == 58, "7171", subject_ID))

# Create new column with group membership based on responses to both questions
explicit_data_diff$combined_group <- with(explicit_data_diff,
                                   ifelse(group_membership == "In-group" & straattaal_user == "In-group", "Ingroup",
                                          ifelse(group_membership == "Out-group" & straattaal_user == "Out-group", "Outgroup",
                                                 "Inconsistent"))
)

# Save explicit ratings to csv file
write.csv(explicit_data_diff, file = "explicit_ratings.csv", row.names = FALSE)

# Reshape to long format
explicit_long <- explicit_data_diff %>%
  pivot_longer(
    cols = all_of(numeric_cols),
    names_to = "attribute",
    values_to = "rating_diff"
  )

# APA-style boxplot with red zero line for all attributes and all participants
ggplot(explicit_long, aes(x = attribute, y = rating_diff, fill = attribute)) +
  geom_boxplot(color = "black", width = 0.6, outlier.shape = 21, outlier.fill = "white") +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed", size = 0.8) +  # red zero line
  scale_fill_grey(start = 0.7, end = 0.3) +   # subtle APA greys
  labs(
    x = "Attribute",
    y = "Rating Difference"
  ) +
  theme_minimal(base_family = "Times New Roman") +
  theme(
    legend.position = "none",
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black"),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 13, face = "bold"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5)
  )

# T-test for d-score deviating from 0
t.test(explicit_data_diff$age,       mu = 0)
t.test(explicit_data_diff$class,     mu = 0)
t.test(explicit_data_diff$ethnicity, mu = 0)
t.test(explicit_data_diff$gender,    mu = 0)
t.test(explicit_data_diff$location,  mu = 0)
t.test(explicit_data_diff$rating,    mu = 0)


analyse_rr <- function(group_var){
  
  # Plot box plots for in-group and out-group for the six attributes
  rr_plot <- ggplot(explicit_long, aes(x = {{group_var}}, y = rating_diff, fill = {{group_var}})) +
    geom_boxplot(color = "black") +
    geom_hline(yintercept = 0, color = "red", linetype = "dotted", size = 0.8) +
    facet_wrap(~ attribute, scales = "free_y") +
    labs(
      x = "Group membership",
      y = "Rating difference"
    ) +
    scale_fill_grey(start = 0.35, end = 0.8) +
    theme_minimal() +
    theme(
      legend.position = "none",
      text = element_text(family = "Times New Roman")
    )
  
  # Print the plot
  print(rr_plot)
  
  # Convert variable to name for model formulas
  group_name <- deparse(substitute(group_var))
  
  lm_age       <- lmer(as.formula(paste("age ~",       group_name, "+ (1|order)")), data = explicit_data_diff)
  lm_class     <- lmer(as.formula(paste("class ~",     group_name, "+ (1|order)")), data = explicit_data_diff)
  lm_ethnicity <- lmer(as.formula(paste("ethnicity ~", group_name, "+ (1|order)")), data = explicit_data_diff)
  lm_gender    <- lmer(as.formula(paste("gender ~",    group_name, "+ (1|order)")), data = explicit_data_diff)
  lm_location  <- lmer(as.formula(paste("location ~",  group_name, "+ (1|order)")), data = explicit_data_diff)
  lm_rating    <- lmer(as.formula(paste("rating ~",    group_name, "+ (1|order)")), data = explicit_data_diff)
  
  # Print results of linear models
  print(summary(lm_age))
  print(summary(lm_class))
  print(summary(lm_ethnicity))
  print(summary(lm_gender))
  print(summary(lm_location))
  print(summary(lm_rating))
  
  if (group_name == "combined_group") {
    emm_age       <- emmeans(lm_age,       specs = group_name)
    emm_class     <- emmeans(lm_class,     specs = group_name)
    emm_ethnicity <- emmeans(lm_ethnicity, specs = group_name)
    emm_gender    <- emmeans(lm_gender,    specs = group_name)
    emm_location  <- emmeans(lm_location,  specs = group_name)
    emm_rating    <- emmeans(lm_rating,    specs = group_name)
    
    # Pairwise comparisons with Tukey adjustment for 3-level factor
    print(pairs(emm_age,       adjust = "tukey"))
    print(pairs(emm_class,     adjust = "tukey"))
    print(pairs(emm_ethnicity, adjust = "tukey"))
    print(pairs(emm_gender,    adjust = "tukey"))
    print(pairs(emm_location,  adjust = "tukey"))
    print(pairs(emm_rating,    adjust = "tukey"))
  }
  
}

# Run analysis for group membership on the three grouping approaches
analysis_rr_prescreening <- analyse_rr(group_membership)
analysis_rr_prescreening <- analyse_rr(straattaal_user)
analysis_rr_prescreening <- analyse_rr(combined_group)

# Calculate mean rating difference for each attribute across all participants
mean_by_attribute <- explicit_long %>%
  group_by(attribute) %>%
  summarise(
    mean_rating = mean(rating_diff, na.rm = TRUE),
    sd_rating   = sd(rating_diff, na.rm = TRUE), 
    n           = sum(!is.na(rating_diff))       
  ) %>%
  ungroup()

explicit_means_long <- explicit_data %>%
  pivot_longer(
    cols = all_of(numeric_cols),
    names_to = "attribute",
    values_to = "score"
  ) %>%
  group_by(attribute, language_variation = lang_variety) %>%
  summarise(mean_score = mean(score, na.rm = TRUE), .groups = "drop")

# Write csv files with results
write.csv2(mean_by_attribute,   "RR_means_humans.csv",     row.names = FALSE)
write.csv2(explicit_means_long, "RR_means_humans_att.csv", row.names = FALSE)
