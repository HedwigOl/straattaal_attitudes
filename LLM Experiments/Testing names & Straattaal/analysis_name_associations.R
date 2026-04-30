library(tidyverse)
library(readr)

folder_path <- "responses_matched"

# Files with name association output
csv_files <- list.files(folder_path, pattern = "\\.(csv|tsv)$", full.names = TRUE)

numeric_tests <- c("Age", "Class", "Ethnicity")

process_file <- function(file_path) {
  
  df <- read_tsv(file_path, na = c("", "NA")) %>%
    mutate(
      response_numeric = case_when(
        test %in% numeric_tests ~ suppressWarnings(as.numeric(pattern_match)),
        TRUE ~ NA_real_
      )
    )
  
  # Summary for numeric ratings (age, social class and ethnicity)
  numeric_summary <- df %>%
    filter(test %in% numeric_tests) %>%
    group_by(naam, test) %>%
    summarise(
      llm_mean = mean(response_numeric, na.rm = TRUE),
      llm_sd   = sd(response_numeric, na.rm = TRUE),
      n_valid  = sum(!is.na(response_numeric)),
      n_total  = n(),
      .groups = "drop"
    ) %>%
    pivot_wider(
      names_from = test,
      values_from = c(llm_mean, llm_sd, n_valid, n_total)
    )
  
  # Gender summary
  gender_summary <- df %>%
    filter(test == "Gender", !is.na(pattern_match)) %>%
    count(naam, pattern_match) %>%
    group_by(naam) %>%
    mutate(
      n_valid_Gender = sum(n),
      prop = n / n_valid_Gender
    ) %>%
    select(-n) %>%
    pivot_wider(
      names_from = pattern_match,
      values_from = prop,
      values_fill = 0
    )
  
  # Combine and save summaries for all four attributes
  output <- numeric_summary %>%
    left_join(gender_summary, by = "naam") %>%
    rename(name = naam)
  
  write.csv2(
    output,
    file.path(
      folder_path,
      paste0(tools::file_path_sans_ext(basename(file_path)), "_summary.csv")
    ),
    row.names = FALSE
  )
  output
}

# Run for all files
all_summaries <- map(csv_files, process_file)
