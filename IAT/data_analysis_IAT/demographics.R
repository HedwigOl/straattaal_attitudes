library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)

# Folders containing in- and outgroup responses
data_folder_outgroup <- "outgroup_responses"
data_folder_ingroup  <- "ingroup_responses"

# Get all files from the folders
files_outgroup <- list.files(data_folder_outgroup, pattern = "\\.csv$", full.names = TRUE)
files_ingroup  <- list.files(data_folder_ingroup,  pattern = "\\.csv$", full.names = TRUE)

# Function to create data frame with just demographic information
clean_demographics <- function(file){
  
  # Read csv file of one participant
  df <- read_csv(file, show_col_types = FALSE)
  
  # Extract trials related to questions
  question_trials <- df[df$trial_type %in% c("survey-html-form", "survey-text"), ]
  
  extract_field <- function(x, field) {
    m <- regexec(paste0("'", field, "'\\s*:\\s*'([^']*)'"), x)
    out <- regmatches(x, m)
    sapply(out, function(z) if (length(z) > 1) z[2] else NA)
  }
  
  # Create data frame with answers to demographics questions
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

# Add group membership and combine into one data frame for both groups
iat_outgroup <- bind_rows(lapply(files_outgroup, clean_demographics)) %>%
  mutate(group_membership = "outgroup")
iat_ingroup  <- bind_rows(lapply(files_ingroup,  clean_demographics)) %>%
  mutate(group_membership = "ingroup")

demographic_data <- bind_rows(iat_outgroup, iat_ingroup)

# Take care of subject_ID which was appointed twice
demographic_data <- demographic_data %>%
  mutate(subject_ID = if_else(subject_ID == "7070" & age == 28, "7171", subject_ID))

# Remove all participants who reported to be disturbed
demographic_data <- demographic_data %>%
  filter(grepl("nee|niet|geen", disturbed, ignore.case = TRUE))

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

# Get general descriptives for age
min(demographic_data$age)
max(demographic_data$age)
mean(demographic_data$age)
sd(demographic_data$age)

# t-test for age distribution in in- and out-group
t.test(age ~ group_membership, data = demographic_data)

# Get standard deviation for age per group
tapply(demographic_data$age, demographic_data$group_membership, sd, na.rm = TRUE)

# Create table gender
gender_table <- demographic_data %>%
  count(group_membership, gender) %>%
  pivot_wider(
    names_from = gender,
    values_from = n,
    values_fill = 0
  )

# Chi-square test on gender
chisq.test(gender_table %>% select(-group_membership))

# Recode education into vocational and higher
demographic_data <- demographic_data %>%
  mutate(education_grouped = case_when(
    education %in% c("HBO", "WO") ~ "higher",
    education %in% c("Middelbaar onderwijs", "MBO") ~ "vocational"
  ))

# Create table with grouped education
education_table <- demographic_data %>%
  count(group_membership, education_grouped) %>%
  pivot_wider(
    names_from = education_grouped,
    values_from = n,
    values_fill = 0
  )

# Chi-square test on education
chisq.test(education_table_grouped %>% select(-group_membership))

# Recode 'ik twijfel' to 'nee' based on CBS definition of Randstad
demographic_data <- demographic_data %>%
  mutate(randstad = if_else(randstad == "Ik twijfel", "Nee", randstad))

# Create table of residence location
randstad_table <- demographic_data %>%
  count(group_membership, randstad) %>%
  pivot_wider(
    names_from = randstad,
    values_from = n,
    values_fill = 0
  )

# Chi-square test on residence location
chisq.test(randstad_table %>% select(-group_membership))

# Create overview table 
iat-experience_table <- demographic_data %>%
  count(group_membership, iat_experience) %>%
  pivot_wider(
    names_from = iat_experience,
    values_from = n,
    values_fill = 0
  )

chisq.test(iat-experience_table %>% select(-group_membership))


##### Run same analysis with straattaal_user as grouping 

# t-test for age distribution in groups
t.test(age ~ straattaal_user, data = demographic_data)
tapply(demographic_data$age, demographic_data$straattaal_user, sd, na.rm = TRUE)


# Create overview table gender
gender_table_user <- demographic_data %>%
  count(straattaal_user, gender) %>%
  pivot_wider(
    names_from = gender,
    values_from = n,
    values_fill = 0
  )

# Chi-square test on gender
chisq.test(gender_table_user %>% select(-straattaal_user))

# Create overview table education
education_table_user <- demographic_data %>%
  count(straattaal_user, education_grouped) %>%
  pivot_wider(
    names_from = education_grouped,
    values_from = n,
    values_fill = 0
  )

# Chi-square test on education
chisq.test(education_table_user %>% select(-straattaal_user))


# Create overview table residence location
randstad_table_user <- demographic_data %>%
  count(straattaal_user, randstad) %>%
  pivot_wider(
    names_from = randstad,
    values_from = n,
    values_fill = 0
  )

# Chi-square test on residence location
chisq.test(randstad_table_user %>% select(-straattaal_user))

# Create overview table 
iat_exp_table_user <- demographic_data %>%
  count(straattaal_user, iat_experience) %>%
  pivot_wider(
    names_from = iat_experience,
    values_from = n,
    values_fill = 0
  )

### Run same analysis for group membership based on responses to the two questions combined
demographic_data$combined_group <- with(demographic_data,
                                   ifelse(group_membership == "ingroup" & straattaal_user == "Ja", "Ingroup",
                                          ifelse(group_membership == "outgroup" & straattaal_user == "Nee", "Outgroup",
                                                 "Inconsistent"))
)

# anova for age distribution in groups
anova_result <- aov(age ~ combined_group, data = demographic_data)
summary(anova_result)
tapply(demographic_data$age, demographic_data$combined_group, sd, na.rm = TRUE)
tapply(demographic_data$age, demographic_data$combined_group, mean, na.rm = TRUE)


# Create overview table gender
gender_table_comb <- demographic_data %>%
  count(combined_group, gender) %>%
  pivot_wider(
    names_from = gender,
    values_from = n,
    values_fill = 0
  )

# Chi-square test on gender
chisq.test(gender_table_comb %>% select(-combined_group))

# Create overview table education
education_table_comb <- demographic_data %>%
  count(combined_group, education_grouped) %>%
  pivot_wider(
    names_from = education_grouped,
    values_from = n,
    values_fill = 0
  )

# Chi-square test on education
chisq.test(education_table_comb %>% select(-combined_group))


# Create overview table residence location
randstad_table_comb <- demographic_data %>%
  count(combined_group, randstad) %>%
  pivot_wider(
    names_from = randstad,
    values_from = n,
    values_fill = 0
  )

# Chi-square test on residence location
chisq.test(randstad_table_comb %>% select(-combined_group))

# Create overview table 
iat_exp_table_user <- demographic_data %>%
  count(combined_group, iat_experience) %>%
  pivot_wider(
    names_from = iat_experience,
    values_from = n,
    values_fill = 0
  )

# Create overview of straattaal response of participants per group
demographic_data %>%
  group_by(group_membership, straattaal_user) %>%
  summarise(count = n()) %>%
  arrange(group_membership, straattaal_user)
