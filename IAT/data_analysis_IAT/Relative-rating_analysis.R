library(lmerTest)
library(dplyr)
library(readr)

# Folders containing in- and outgroup responses
data_folder_outgroup <- "outgroup_responses"
data_folder_ingroup  <- "ingroup_responses"

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
    subject_ID     = question_trials$subject_ID,
    lang_variety   = sub(".*Ethnicity_([^']+)'.*", "\\1", question_trials$response),
    ethnicity      = extract_score("Ethnicity", question_trials$response),
    gender_rating  = extract_score("Gender",    question_trials$response),
    age_rating     = extract_score("Age",       question_trials$response),
    location       = extract_score("Location",  question_trials$response),
    class          = extract_score("Class",     question_trials$response),
    rating         = extract_score("Rating",    question_trials$response),
    order          = ifelse(question_order, 1, 2)
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

# Combine into one df
expl_outgroup <- bind_rows(lapply(files_outgroup, clean_explicit_questions))
expl_ingroup  <- bind_rows(lapply(files_ingroup,  clean_explicit_questions)) 
expl_all      <- bind_rows(expl_outgroup, expl_ingroup)

# Add demographic information to all rows
dem_df <- read_csv("demographics.csv", show_col_types = FALSE)
expl_all$subject_ID <- as.character(expl_all$subject_ID)
dem_df$subject_ID   <- as.character(dem_df$subject_ID)
explicit_data <- left_join(expl_all, dem_df, by = "subject_ID")

# Exclude disturbed and experienced participants
explicit_data <- explicit_data %>%
  filter(grepl("nee|niet", disturbed, ignore.case = TRUE))

# List of attributes
numeric_cols <- c("ethnicity", "gender_rating", "age_rating", "location", "class", "rating") 

# Calculate difference between Standard Dutch and Straattaal score
explicit_data_diff <- explicit_data %>%
  group_by(subject_ID, group_membership, order, straattaal_user) %>%
  summarise(
    across(all_of(numeric_cols),
           ~ .[lang_variety == "STANDAARD NEDERLANDS"] - .[lang_variety == "STRAATTAAL"]),
    .groups = "drop"
  )

write.csv(explicit_data_diff, file = "explicit_ratings.csv", row.names = FALSE)

# Plot ethnicity difference score
boxplot(ethnicity ~ group_membership,
        data = explicit_data_diff,
        xlab = "Group membership",
        ylab = "Rating difference for ethnicity",
        main = "Difference in rating for ethnicity for In and Outgroup")

lm_ethnicity <- lmer(ethnicity ~ group_membership + (1|order), data = explicit_data_diff)
summary(lm_ethnicity)

boxplot(ethnicity ~ straattaal_user,
        data = explicit_data_diff,
        xlab = "Group membership",
        ylab = "Rating difference for ethnicity",
        main = "Difference in rating for ethnicity for In and Outgroup")

lm_ethnicity <- lmer(ethnicity ~ straattaal_user + (1|order), data = explicit_data_diff)
summary(lm_ethnicity)

# Plot gender difference score
boxplot(gender_rating ~ group_membership,
        data = explicit_data_diff,
        xlab = "Group membership",
        ylab = "Rating difference for gender",
        main = "Difference in rating for gender for In and Outgroup")

lm_gender <- lm(gender_rating ~ group_membership + (1|order), data = explicit_data_diff)
summary(lm_gender)

# Plot age difference score
boxplot(age_rating ~ group_membership,
        data = explicit_data_diff,
        xlab = "Group membership",
        ylab = "Rating difference for age",
        main = "Difference in rating for age for In and Outgroup")

lm_age <- lm(age_rating ~ group_membership + (1|order), data = explicit_data_diff)
summary(lm_age)

# Plot location difference score
boxplot(location ~ group_membership,
        data = explicit_data_diff,
        xlab = "Group membership",
        ylab = "Rating difference for location",
        main = "Difference in rating for location for In and Outgroup")

lm_location <- lm(location ~ group_membership + (1|order), data = explicit_data_diff)
summary(lm_location)

# Plot class difference score
boxplot(class ~ group_membership,
        data = explicit_data_diff,
        xlab = "Group membership",
        ylab = "Rating difference for class",
        main = "Difference in rating for class for In and Outgroup")

lm_class <- lm(class ~ group_membership + (1|order), data = explicit_data_diff)
summary(lm_class)

# Plot rating difference score
boxplot(rating ~ group_membership,
        data = explicit_data_diff,
        xlab = "Group membership",
        ylab = "Rating difference for rating",
        main = "Difference in rating for rating for In and Outgroup")

lm_rating <- lm(rating ~ group_membership + (1|order), data = explicit_data_diff)
summary(lm_rating)
