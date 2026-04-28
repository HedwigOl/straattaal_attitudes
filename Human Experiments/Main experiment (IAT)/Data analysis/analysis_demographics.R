library(dplyr)
library(tidyr)
library(readr)

# File paths
files_outgroup <- list.files("outgroup_responses", "\\.csv$", full.names = TRUE)
files_ingroup  <- list.files("ingroup_responses",  "\\.csv$", full.names = TRUE)

# Extract demographic information
clean_demographics <- function(file){
  
  df <- read_csv(file, show_col_types = FALSE)
  
  question_trials <- df %>%
    filter(trial_type %in% c("survey-html-form", "survey-text"))
  
  extract_field <- function(x, field) {
    m <- regexec(paste0("'", field, "'\\s*:\\s*'([^']*)'"), x)
    sapply(regmatches(x, m), function(z) ifelse(length(z) > 1, z[2], NA))
  }
  
  dem_df <- data.frame(
    subject_ID      = question_trials$subject_ID,
    group           = question_trials$group,
    age             = extract_field(question_trials$response, "age"),
    gender          = extract_field(question_trials$response, "gender"),
    education       = extract_field(question_trials$response, "education"),
    randstad        = extract_field(question_trials$response, "randstad"),
    randstad_other  = extract_field(question_trials$response, "randstad_other"),
    born_nl         = extract_field(question_trials$response, "born_nl"),
    born_other      = extract_field(question_trials$response, "born_nl_other"),
    parents_nl      = extract_field(question_trials$response, "parents_nl"),
    parents_other   = extract_field(question_trials$response, "parents_nl_other"),
    straattaal_user = extract_field(question_trials$response, "Straattaalspreker"),
    iat_experience  = extract_field(question_trials$response, "IAT_experience"),
    home_languages  = extract_field(question_trials$response, "languages"),
    disturbed       = extract_field(question_trials$response, "disturbed"),
    stringsAsFactors = FALSE
  )
  
  as.data.frame(t(sapply(dem_df, function(x) x[!is.na(x)][1])))
}

# Combine ingroup and outgroup data
iat_outgroup <- bind_rows(lapply(files_outgroup, clean_demographics)) %>%
  mutate(group_membership = "outgroup")

iat_ingroup <- bind_rows(lapply(files_ingroup, clean_demographics)) %>%
  mutate(group_membership = "ingroup")

demographic_data <- bind_rows(iat_outgroup, iat_ingroup) %>%
  filter(grepl("nee|niet|geen", disturbed, ignore.case = TRUE)) %>%
  mutate(
    subject_ID = if_else(subject_ID == "7070" & age == 28, "7171", subject_ID),
    age = as.numeric(as.character(age)),
    education_grouped = case_when(
      education %in% c("HBO", "WO") ~ "higher",
      education %in% c("Middelbaar onderwijs", "MBO") ~ "vocational"
    ),
    randstad = if_else(randstad == "Ik twijfel", "Nee", randstad),
    combined_group = case_when(
      group_membership == "ingroup" & straattaal_user == "Ja" ~ "Ingroup",
      group_membership == "outgroup" & straattaal_user == "Nee" ~ "Outgroup",
      TRUE ~ "Inconsistent"
    )
  )

# save demographic data for later use
write.csv(demographic_data, "demographics.csv", row.names = FALSE)

# Function for demographic analyses (age, gender, education etc.)
demographic_analysis <- function(data, group_var, iat_data = NULL) {
  
  group_var <- rlang::ensym(group_var)
  group_name <- rlang::as_string(group_var)
  
  cat("Analysis for:", group_name, "\n")
  cat("====================\n")
  
  # Age descriptives
  print(
    data %>%
      group_by(!!group_var) %>%
      summarise(mean = mean(age, na.rm = TRUE),
                sd   = sd(age, na.rm = TRUE),
                .groups = "drop")
  )
  
  # Test distinctness age
  n_groups <- n_distinct(pull(data, !!group_var))
  
  if (n_groups == 2) {
    print(t.test(reformulate(group_name, "age"), data = data))
  } else {
    print(summary(aov(reformulate(group_name, "age"), data = data)))
  }
  
  # chi square helper function
  make_test <- function(var){
    tab <- data %>%
      count(!!group_var, .data[[var]]) %>%
      pivot_wider(names_from = all_of(var), values_from = n, values_fill = 0)
    
    list(
      variable = var,
      table = tab,
      chisq = chisq.test(select(tab, -1))
    )
  }
  
  vars <- c("gender", "education_grouped", "randstad", "iat_experience")
  results <- lapply(vars, make_test)
  
  print(results)
  
  # Test for version distribution over groups
  if (!is.null(iat_data)) {
    tab <- iat_data %>%
      count(!!group_var, group) %>%
      pivot_wider(names_from = group, values_from = n, values_fill = 0)
    
    print(chisq.test(select(tab, -1)))
  }
}

# Run demographic analyses for three group membership approaches
demographic_analysis(demographic_data, group_membership, iat_dscores)
demographic_analysis(demographic_data, straattaal_user,  iat_dscores)
demographic_analysis(demographic_data, combined_group,   iat_dscores)
