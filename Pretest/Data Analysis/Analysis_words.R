library(dplyr)
library(tidyr)

# Read cleaned data
data_all <- read.csv("data/cleaned_data_pretest.csv", stringsAsFactors = FALSE)

# Make responses of participant 8 where key error was made NA
data_all[8, which(names(data_all) == "use_tranga"):which(names(data_all) == "use_wurpjes")] <- NA

# Create data frames for the three different Straattaal groups
data_ja   <- data_all %>%
  filter(straattaal_use == "Ja, vaak")
data_soms <- data_all %>%
  filter(straattaal_use == "Soms")
data_nee  <- data_all %>%
  filter(straattaal_use == "Nee, nooit")

# Function to create table of raw counts and proportions for the word recognition and use
process_word_task <- function(data, pattern) {
  
  # Select use or recognition columns based on pattern
  select_cols <- grep(pattern, names(data), value = TRUE)
  
  # Create raw counts table
  counts_table <- data %>%
    select(all_of(select_cols)) %>%
    pivot_longer(
      everything(),
      names_to = "word",
      values_to = "answer",
      values_drop_na = TRUE
    ) %>%
    count(word, answer) %>%
    pivot_wider(names_from = answer, values_from = n, values_fill = 0)
  
  # Calculate the proportions of answers
  proportions_table <- counts_table %>%
    rowwise() %>%
    mutate(across(-word, ~ round(.x / sum(c_across(-word)), 2))) %>%
    ungroup()
  
  # Combine counts and proportions into one data frame
  prop_cols <- names(proportions_table)[-1]
  names(proportions_table)[-1] <- paste0(prop_cols, "_prop") #add '_prop' for clarity
  
  combined_df <- left_join(counts_table, proportions_table, by = "word")
  return(combined_df)
}

# Create data frames of the recognition task
word_rec_all  <- process_word_task(data_all, "^rec_")
word_rec_ja   <- process_word_task(data_ja, "^rec_")
word_rec_soms <- process_word_task(data_soms, "^rec_")
word_rec_nee  <- process_word_task(data_nee, "^rec_")

# Create data frames of the use task
word_use_all  <- process_word_task (data_all, "^use_")
word_use_ja   <- process_word_task (data_ja, "^use_")
word_use_soms <- process_word_task (data_soms, "^use_")
word_use_nee  <- process_word_task (data_nee, "^use_")
