library(tidyverse)

# Files of name pretest summaries
folder_path <- "Name_pretest/summaries"
csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)

# Ensure no issues arise from , being a .
safe_numeric <- function(x) as.numeric(gsub(",", ".", x))

# Human pretest associations
human_associations <- read.csv(
  "C:/Users/hedwi/Documents/Pretest/data/summary_names_all.csv",
  sep = ";", encoding = "latin1"
) %>%
  mutate(name  = str_trim(tolower(name)),
         man   = safe_numeric(man),
         vrouw = safe_numeric(vrouw))

# Function to process each LLM CSV
process_llms <- function(file_path) {
  llm_name <- tools::file_path_sans_ext(basename(file_path))
  
  # Read LLM CSV
  llm <- read.csv(file_path, sep = ";", encoding = "latin1") %>%
    mutate(name = str_trim(tolower(name)),
           n_valid_Class = as.numeric(n_valid_Class),
           man = safe_numeric(man)) 
  
  # Join with human data
  big_df <- human_associations %>%
    full_join(llm, by = "name", suffix = c("_human", "_llm"))
  
  # Safe numeric conversion for other numeric columns
  safe_numeric <- function(x) as.numeric(gsub(",", ".", x))
  
  numeric_cols <- c("age_mean", "class_mean", "ethnicity_mean", "llm_mean_Age", 
                    "llm_mean_Class", "llm_mean_Ethnicity")
  big_df[numeric_cols] <- lapply(big_df[numeric_cols], safe_numeric)
  
  # Compute gender for LLM and human
  big_df <- big_df %>%
    mutate(
      man_human    = replace_na(safe_numeric(man_human), 0),
      vrouw_human  = replace_na(safe_numeric(vrouw_human), 0),
      gender_llm   = man_llm,
      gender_human = man_human / (man_human + vrouw_human)
    )
  
  # Function to compute correlation and number of valid observations
  compute_cor <- function(x, y) {
    valid <- !is.na(x) & !is.na(y)
    list(cor = if(sum(valid) > 1) cor(x[valid], y[valid], method = "spearman") else NA_real_,
         n   = sum(valid))
  }
  
  # Compute correlations
  age_res       <- compute_cor(big_df$age_mean,       big_df$llm_mean_Age)
  class_res     <- compute_cor(big_df$class_mean,     big_df$llm_mean_Class)
  ethnicity_res <- compute_cor(big_df$ethnicity_mean, big_df$llm_mean_Ethnicity)
  gender_res    <- compute_cor(big_df$gender_human,   big_df$gender_llm)
  
  # Return summary tibble
  tibble(
    LLM = llm_name,
    age_pearson = age_res$cor, n_age = age_res$n,
    class_pearson = class_res$cor, n_class = class_res$n,
    ethnicity_pearson = ethnicity_res$cor, n_ethnicity = ethnicity_res$n,
    gender_pearson = gender_res$cor, n_gender = gender_res$n
  )
}

# Apply to all CSVs
ch_results <- map_df(csv_files, process_llms)
