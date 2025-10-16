library(dplyr)
library(tidyr)
library(irr)
library(psych)
library(tibble)
library(lmertest)

# Read cleaned data and only select name columns
data      <- read.csv("data/cleaned_data_pretest.csv", stringsAsFactors = FALSE)
name_cols <- grep("^(ethnicity_|age_|gender_|class_)", names(data), value = TRUE)
data      <- data[, name_cols]

# Select the columns for the different tasks
ethnicity_cols <- grep("^ethnicity_", names(data), value = TRUE)
class_cols     <- grep("^class_", names(data), value = TRUE)
age_cols       <- grep("^age_", names(data), value = TRUE)
gender_cols    <- grep("^gender_", names(data), value = TRUE)

# Delete age answers that are not purely numerical
data[age_cols] <- lapply(data[age_cols], function(x) {x[!grepl("^\\d+$", x)] <- NA; x})

# Function to check for straight lining
check_straightlining <- function(data, cols_to_check) {
  for (i in seq_len(nrow(data))) {
    row_values <- unlist(data[i, cols_to_check])
    row_values <- row_values[!is.na(row_values)]
    if (length(unique(row_values)) == 1) {
      cat("Row", i, "\n")
      data[i, cols_to_check] <- NA
    }
  }
  return(data)
}

# Apply check for the different tasks
for (cols in list(ethnicity_cols, class_cols, age_cols, gender_cols)) {
  data <- check_straightlining(data, cols)
}

# Calculate Krippendorf's alpha for ethnicity, class and gender
kripp_ethnicity <- kripp.alpha(as.matrix(data[ , ethnicity_cols]), method = "ordinal")
kripp_class     <- kripp.alpha(as.matrix(data[ , class_cols]), method = "ordinal")
kripp_gender    <- kripp.alpha(as.matrix(data[ , gender_cols]), method = "nominal")
kripp_age       <- kripp.alpha(as.matrix(data[ , age_cols]), method = "ratio")

# Calculate ICC for age
data[, age_cols] <- lapply(data[, age_cols], as.numeric)
icc_result <- ICC(t(as.matrix(data[ , age_cols])))
print(icc_result)

# Function to create a summary of perceived ethnicity, age, gender and class
summary_names <- function(data) {
  
  relevant_cols <- grep("^(age_|gender_|class_|eth_)", names(data), value = TRUE)
  col_groups    <- unique(gsub("^(ethnicity_|age_|gender_|class_)", "", relevant_cols))
  
  results <- lapply(col_groups, function(name) {
    
    ethnicity_col <- paste0("ethnicity_", name)
    age_col       <- paste0("age_", name)
    class_col     <- paste0("class_", name)
    gender_col    <- paste0("gender_", name)
    
    # Ethnicity
    ethnicity_values <- as.numeric(data[[ethnicity_col]])
    ethnicity_mean   <- round(mean(ethnicity_values, na.rm = TRUE), 2)
    ethnicity_sd     <- round(sd(ethnicity_values, na.rm = TRUE), 2)
    
    # Age
    age_values <- as.numeric(data[[age_col]])
    age_mean   <- round(mean(age_values, na.rm = TRUE), 1)
    age_sd     <- round(sd(age_values, na.rm = TRUE), 1)
    
    # Class
    class_values <- as.numeric(data[[class_col]])
    class_mean   <- round(mean(class_values, na.rm = TRUE), 2)
    class_sd     <- round(sd(class_values, na.rm = TRUE), 2)
    
    # Gender
    gender_values      <- data[[gender_col]]
    gender_proportions <- as.list(round(prop.table(table(gender_values)), 2))

    c(name = name, ethnicity_mean = ethnicity_mean, ethnicity_sd = ethnicity_sd,
      age_mean = age_mean, age_sd = age_sd, class_mean = class_mean, 
      class_sd = class_sd, gender_proportions)
  })
  
  # Combine information into one data frame
  combined <- bind_rows(results)
  
  return(combined)
}

summary_names_all <- summary_names(data)


# Add participant ID
data <- data %>% mutate(participant_id = row_number()) 

# Create df for responses per participant and name
numeric_long <- data %>%
  select(participant_id, starts_with("age_"), starts_with("class_"), starts_with("ethnicity_")) %>%
  pivot_longer(
    cols = -participant_id,
    names_to = c("variable", "name"),
    names_sep = "_",
    values_to = "value"
  ) %>%
  pivot_wider(
    names_from = variable,
    values_from = value
  )

gender_long <- data %>%
  select(participant_id, starts_with("gender_")) %>%
  pivot_longer(
    cols = -participant_id,
    names_to = "name",
    names_prefix = "gender_",
    values_to = "gender"
  )

data_response <- numeric_long %>%
  left_join(gender_long, by = c("participant_id", "name")) %>%
  select(name, participant_id, age, class, gender, ethnicity)


# Age predicted by class, ethnicity, and gender
lmer_age <- lmer(age ~ class + ethnicity + gender + (1 | participant_id), data = data_response)
summary(lmer_age)

# Class predicted by age, ethnicity, and gender
lmer_class <- lmer(class ~ age + ethnicity + gender + (1 | participant_id), data = data_response)
summary(lmer_class)

# Ethnicity predicted by age, class, and gender
lmer_ethnicity <- lmer(ethnicity ~ age + class + gender + (1 | participant_id), data = data_response)
summary(lmer_ethnicity)

