library(ggplot2)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(readr)

# Extract model and temperature from file name
parse_filename <- function(filename) {
  
  base <- basename(filename) %>%
    sub("^RR-pilot_", "", .) %>% # File name structure is RR-pilot_model_temperature
    sub("\\.csv$", "", .)
  
  parts <- strsplit(base, "_")[[1]]
  
  list(
    model            = parts[1],
    temperature      = if (length(parts) >= 2) parts[2] else NA_character_
  )
}

# Extract scores from LLM responses
create_parsed_csv_full <- function(file) {
  
  # Get meta information from file name
  meta <- parse_filename(file)
  
  df <- read_tsv(file, show_col_types = FALSE)
  
  df_parsed <- df %>%
    mutate(
      response = str_trim(as.character(response)),
      # Only keep prompt variation part of the prompt
      prompt = str_replace(prompt, "(?s)^.*?\\?.*?\\?\\s*", "") %>% 
        str_trim()
    ) %>%
    
    # Extract score if one number is provided between 0 and 100
    filter(str_detect(response, "^\\d+$")) %>%
    mutate(response = as.integer(response)) %>%
    filter(response >= 0 & response <= 100) %>%
    
    # Add meta information to data frame
    mutate(
      model            = meta$model,
      temperature      = meta$temperature
      
    ) %>%
    select(prompt, attribute, language_variety, response, model, temperature)
  
  return(df_parsed)
}

# Process all CSV files and create an answer-extracted data frame with meta information (model, temperature)
parse_all_files <- function(folder_path) {
  
  files      <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)
  parsed_all <- map_dfr(files, create_parsed_csv_full)
  
  return(parsed_all)
}

# Calculate the difference between the ratings for Standard Dutch and Straattaal
compute_rating_differences <- function(df) {
  
  df %>%
    select(attribute, model, temperature, prompt, language_variety, response) %>%
    
    # Summarize to ensure unique numeric values per combination
    group_by(attribute, model, temperature, prompt, language_variety) %>%
    summarise(response = mean(response, na.rm = TRUE), .groups = "drop") %>%
    
    pivot_wider(
      names_from = language_variety,
      values_from = response
    ) %>%
    
    # Standard Dutch rating - Straattaal score if ratings for both exist
    mutate(
      score = ifelse(
        !is.na(Straattaal) & !is.na(Standaardnederlands),
        Standaardnederlands - Straattaal,
        NA_real_
      ),
      
      # Ensure sign of location is flipped to ensure stereotypical associations are positive
      score = ifelse(attribute == "location", -score, score)
    ) %>%
    
    select(model, temperature, prompt, attribute, score)
}

# Folder with LLM responses
folder <- "C:\\Users\\hedwi\\Documents\\RR-pilot_LLMs"

# Parse all files and compute all rating differences
parsed_data <- parse_all_files(folder)
all_diffs   <- compute_rating_differences(parsed_data)

# Create summary data frame with mean rating differences and 95% confidence intervals
summary_df <- all_diffs %>%
  mutate(attribute = ifelse(attribute == "social_class", "social class", attribute)) %>%
  group_by(attribute, model, temperature) %>%
  summarise(
    mean_score = mean(score, na.rm = TRUE),
    sd_score   = sd(score, na.rm = TRUE),
    n          = sum(!is.na(score)),
    .groups = "drop"
  ) %>%
  mutate(
    se       = sd_score / sqrt(n),
    ci_lower = mean_score - 1.96 * se,
    ci_upper = mean_score + 1.96 * se
  )

# Plot difference scores and 95% CI for each model and each attribute
ggplot(
  summary_df,
  aes(x = attribute, y = mean_score, color = temperature)
) +
  geom_point(size = 2, position = position_dodge(width = 0.6)) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                width = 0.2, position = position_dodge(width = 0.6)) +
  facet_wrap(~ model) +
  geom_hline(yintercept = 0, color = "grey40", linetype = "dashed") +
  scale_y_continuous(limits = c(-100, 100)) +
  scale_color_manual(values = c("NA" = "grey40", "0.001" = "red", "1.0" = "blue")) +
  labs(
    x     = "Attribute",
    y     = "Rating Difference (Standard Dutch - Straattaal)",
    color = "Temperature"
  ) +
  theme_minimal(base_family = "Times New Roman") +
  theme(
    text = element_text(family = "Times New Roman"),
    axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
    panel.grid.major.x = element_blank()
  )

# Create a wide table with columns for each temperature per prompt
scores_wide <- all_diffs %>%
  filter(temperature %in% c("0.001", "1.0")) %>%
  select(model, prompt, attribute, temperature, score) %>%
  pivot_wider(
    names_from = temperature,
    values_from = score
  )

# Compute correlation for temperature setting per model
correlation_results <- scores_wide %>%
  group_by(model) %>%
  summarise(
    cor_temp = if (all(c("0.001", "1.0") %in% names(.))) {
      cor(`0.001`, `1.0`, use = "pairwise.complete.obs")
    } else {
      NA_real_
    },
    n = sum(!is.na(`0.001`) & !is.na(`1.0`)),
    .groups = "drop"
  )
