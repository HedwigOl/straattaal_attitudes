library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)

# Folders containing in- and outgroup responses
data_folder_outgroup <- "outgroup_responses"
data_folder_ingroup  <- "ingroup_responses"

files_outgroup <- list.files(data_folder_outgroup, pattern = "\\.csv$", full.names = TRUE)
files_ingroup  <- list.files(data_folder_ingroup,  pattern = "\\.csv$", full.names = TRUE)

# Function to create data frame with just demographic information
clean_demographics <- function(file){
  
  df <- read_csv(file, show_col_types = FALSE)
  
  # Extract trials related to questions
  question_trials <- df[df$trial_type %in% c("survey-html-form", "survey-text"), ]
  
  extract_field <- function(x, field) {
    m <- regexec(paste0("'", field, "'\\s*:\\s*'([^']*)'"), x)
    out <- regmatches(x, m)
    sapply(out, function(z) if (length(z) > 1) z[2] else NA)
  }
  
  dem_df <- data.frame(
    subject_ID       = question_trials$subject_ID,
    age              = extract_field(question_trials$response, "age"              ),
    gender           = extract_field(question_trials$response, "gender"           ),
    education        = extract_field(question_trials$response, "education"        ),
    randstad         = extract_field(question_trials$response, "randstad"         ),
    randstad_other   = extract_field(question_trials$response, "randstad_other"   ),
    born_nl          = extract_field(question_trials$response, "born_nl"          ),
    born_other       = extract_field(question_trials$response, "born_nl_other"    ),
    parents_nl       = extract_field(question_trials$response, "parents_nl"       ),
    parents_other    = extract_field(question_trials$response, "parents_nl_other" ),
    straattaal_user  = extract_field(question_trials$response, "Straattaalspreker"),
    iat_experience   = extract_field(question_trials$response, "IAT_experience"   ),
    home_languages   = extract_field(question_trials$response, "languages"        ),
    disturbed        = extract_field(question_trials$response, "disturbed"        ),
    stringsAsFactors = FALSE
  )
  
  demographics <- as.data.frame(t(sapply(dem_df, function(x) x[!is.na(x)][1])), stringsAsFactors = FALSE)
  
  return(demographics)
}

# Add group membership and combine into one df
iat_outgroup <- bind_rows(lapply(files_outgroup, clean_demographics)) %>%
  mutate(group_membership = "outgroup")
iat_ingroup  <- bind_rows(lapply(files_ingroup,  clean_demographics)) %>%
  mutate(group_membership = "ingroup")

demographic_data <- bind_rows(iat_outgroup, iat_ingroup)

demographic_data <- demographic_data %>%
  filter(grepl("nee|niet", disturbed, ignore.case = TRUE))

# Write demographic df to csv file
write.csv(demographic_data, file = "demographics.csv", row.names = FALSE)

# Make sure age is numeric
demographic_data$age <- as.numeric(as.character(demographic_data$age))

# Plot age distribution across the two groups (with normal curves)
stats <- demographic_data %>%
  group_by(group_membership) %>%
  summarise(
    mean_age = mean(age, na.rm = TRUE),
    sd_age   = sd(age, na.rm = TRUE),
    .groups = "drop"
  )

ggplot(demographic_data, aes(x = age, fill = group_membership)) +
  geom_histogram(aes(y = ..density..),
                 position = "identity",
                 alpha = 0.4,
                 bins = 20) +
  
  stat_function(
    fun = dnorm,
    args = list(
      mean = stats$mean_age[stats$group_membership == "ingroup"],
      sd   = stats$sd_age[stats$group_membership == "ingroup"]
    ),
    inherit.aes = FALSE,
    aes(x = age),
    linewidth = 1
  ) +
  
  stat_function(
    fun = dnorm,
    args = list(
      mean = stats$mean_age[stats$group_membership == "outgroup"],
      sd   = stats$sd_age[stats$group_membership == "outgroup"]
    ),
    inherit.aes = FALSE,
    aes(x = age),
    linewidth = 1
  ) +
  
  labs(
    title = "Age distribution per group",
    x = "Age",
    y = "Density",
    fill = "Group"
  ) +
  theme_minimal()

# Create overview of gender of participants per group
demographic_data %>%
  group_by(group_membership, gender) %>%
  summarise(count = n()) %>%
  arrange(group_membership, gender)

# Create overview of education of participants per group
demographic_data %>%
  group_by(group_membership, education) %>%
  summarise(count = n()) %>%
  arrange(group_membership, education)

# Create overview of randstad living of participants per group
demographic_data %>%
  group_by(group_membership, randstad) %>%
  summarise(count = n()) %>%
  arrange(group_membership, randstad)

# Create overview of straattaal response of participants per group
demographic_data %>%
  group_by(group_membership, straattaal_user) %>%
  summarise(count = n()) %>%
  arrange(group_membership, straattaal_user)
