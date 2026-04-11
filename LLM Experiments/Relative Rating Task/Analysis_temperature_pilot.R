library(dplyr)
library(tidyr)
library(purrr)
library(stringr)

# Path to folder with LLM reponses
folder <- "C:\\Users\\hedwi\\Documents\\RR_cor_temp"

# Read file and parse temperature + LLM from file name
read_model_file <- function(file) {
  
  name <- basename(file) %>%
    str_remove("^parsed_answers_") %>%
    str_remove("\\.csv$")
  
  parts <- str_split(name, "_")[[1]]
  temperature <- parts[length(parts)]
  model <- paste(parts[-length(parts)], collapse = "_")
  
  read.delim(file, sep = ",", stringsAsFactors = FALSE) %>%
    mutate(
      model = model,
      temperature = temperature
    )
}

# Read all files in folder
all_data <- list.files(folder, pattern = "\\.csv$", full.names = TRUE) %>%
  map_dfr(read_model_file)

# Create wide data frame for each prompt
wide_scores <- all_data %>%
  select(model, prompt, temperature, response) %>%
  pivot_wider(names_from = temperature, values_from = response)

# Columns with the two temperatures
temp_cols <- c("0.001", "1.0")

# Compute correlations per model
cor_results <- wide_scores %>%
  group_by(model) %>%
  summarise(
    correlation = {
      df <- select(cur_data(), all_of(temp_cols))
      df <- df[complete.cases(df), ]
      if (nrow(df) > 1) cor(df[[1]], df[[2]]) else NA_real_
    },
    .groups = "drop"
  )
