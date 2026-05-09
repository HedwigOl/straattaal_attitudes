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

explicit_data_diff$Membership <- with(explicit_data_diff,
                                      ifelse(group_membership == "In-group" & straattaal_user == "In-group", "Ingroup",
                                             ifelse(group_membership == "Out-group" & straattaal_user == "Out-group", "Outgroup",
                                                    NA))
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

# T-test for d-score deviating from 0
t.test(explicit_data_diff$age,       mu = 0)
t.test(explicit_data_diff$class,     mu = 0)
t.test(explicit_data_diff$ethnicity, mu = 0)
t.test(explicit_data_diff$gender,    mu = 0)
t.test(explicit_data_diff$location,  mu = 0)
t.test(explicit_data_diff$rating,    mu = 0)

analyse_rr <- function(data_models, data_long, group_var){
  
  group_var <- rlang::ensym(group_var)
  group_name <- rlang::as_string(group_var)
  
  # ----------------------
  # Plot
  # ----------------------
  rr_plot <- ggplot(data_long,
                    aes(x = !!group_var,
                        y = rating_diff,
                        fill = !!group_var)) +
    geom_boxplot(color = "black") +
    geom_hline(yintercept = 0, color = "red",
               linetype = "dotted", linewidth = 0.8) +
    facet_wrap(~ attribute, scales = "free_y") +
    labs(x = "Group membership",
         y = "Rating difference") +
    scale_fill_grey(start = 0.35, end = 0.8) +
    theme_minimal() +
    theme(
      legend.position = "none",
      text = element_text(family = "Times New Roman")
    )
  
  print(rr_plot)
  
  # ----------------------
  # Models (FIXED)
  # ----------------------
  form <- as.formula(paste0("age ~ ", group_name, " + (1|order)"))
  lm_age <- lmer(form, data = data_models)
  
  lm_class <- lmer(as.formula(paste0("class ~ ", group_name, " + (1|order)")),
                   data = data_models)
  
  lm_ethnicity <- lmer(as.formula(paste0("ethnicity ~ ", group_name, " + (1|order)")),
                       data = data_models)
  
  lm_gender <- lmer(as.formula(paste0("gender ~ ", group_name, " + (1|order)")),
                    data = data_models)
  
  lm_location <- lmer(as.formula(paste0("location ~ ", group_name, " + (1|order)")),
                      data = data_models)
  
  lm_rating <- lmer(as.formula(paste0("rating ~ ", group_name, " + (1|order)")),
                    data = data_models)
  
  # ----------------------
  # Output
  # ----------------------
  print(summary(lm_age))
  print(summary(lm_class))
  print(summary(lm_ethnicity))
  print(summary(lm_gender))
  print(summary(lm_location))
  print(summary(lm_rating))
  
  # ----------------------
  # Post-hoc (only if 3+ groups)
  # ----------------------
  if (n_distinct(pull(data_models, !!group_var)) > 2) {
    
    print(pairs(emmeans(lm_age, group_name), adjust = "tukey"))
    print(pairs(emmeans(lm_class, group_name), adjust = "tukey"))
    print(pairs(emmeans(lm_ethnicity, group_name), adjust = "tukey"))
    print(pairs(emmeans(lm_gender, group_name), adjust = "tukey"))
    print(pairs(emmeans(lm_location, group_name), adjust = "tukey"))
    print(pairs(emmeans(lm_rating, group_name), adjust = "tukey"))
  }
}

analyse_rr(explicit_data_diff, explicit_long, group_membership)

analyse_rr(explicit_data_diff, explicit_long, straattaal_user)

analyse_rr(explicit_data_diff, explicit_long, combined_group)

analyse_rr(filter(explicit_data_diff, !is.na(Membership)),
           filter(explicit_long, !is.na(Membership)),
           Membership)


# Run analysis with group membership based on prescreening question
analysis_rr_prescreening <- analyse_rr(group_membership)

# Run analysis with group membership based on question after IAT
analysis_rr_prescreening <- analyse_rr(straattaal_user)

# Run analysis with group membership based on both questions
analysis_rr_prescreening <- analyse_rr(combined_group)

# Run analysis with group membership based on both questions (inconsistent participants excluded)
filtered_rr <- iat_dscores %>%
  filter(!is.na(Membership))
analysis_rr_final        <- analyse_rr(Membership)


# Calculate mean rating difference for each attribute across all participants
mean_by_attribute <- explicit_long %>%
  group_by(attribute) %>%
  summarise(
    mean_rating = mean(rating_diff, na.rm = TRUE),
    sd_rating   = sd(rating_diff, na.rm = TRUE), 
    n           = sum(!is.na(rating_diff))       
  ) %>%
  ungroup()

write.csv2(mean_by_attribute, "RR_means_humans.csv", row.names = FALSE)


explicit_means_long <- explicit_data %>%
  pivot_longer(
    cols = all_of(numeric_cols),
    names_to = "attribute",
    values_to = "score"
  ) %>%
  group_by(attribute, language_variation = lang_variety) %>%
  summarise(mean_score = mean(score, na.rm = TRUE), .groups = "drop")

write.csv2(explicit_means_long, "RR_means_humans_att.csv", row.names = FALSE)

