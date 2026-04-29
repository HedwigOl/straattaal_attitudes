library(tidyverse)
library(irr)
library(lme4)
library(broom.mixed)

folder_path <- "\\Straattaal_prompt_responses\\check-betekenis"

# List all CSV files
csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)

# Read, add information about LLM and label presence and combine csv files into one data frame
full_table <- csv_files %>%
  set_names() %>%
  map_df(~ read.csv2(.x), .id = "source") %>%
  mutate(
    file = str_remove(basename(source), "\\.csv$"), # Get file name
    LLM = str_split_fixed(file, "_", 4)[,3],        # Extract LLM from file name
    Straattaal_added = if_else(str_detect(prompt, "in Straattaal"), 1, 0) # Add 1 if Straattaal is included in prompt
  ) %>%
  select(-source, -file) 

# Create table of proportion of correct responses
proportion_table_all <- full_table %>%
  group_by(LLM, Straattaal_added) %>%
  summarise(
    n_total = n(),
    n_meaning_1 = sum(check_meaning),
    proportion = round(mean(check_meaning), 3)
  ) %>%
  ungroup()

# Calculate the proportion of correct responses for each word
proportion_per_word <- full_table %>%
  group_by(word, LLM) %>%
  summarise(
    n_total = n(),
    n_meaning_1 = sum(check_meaning, na.rm = TRUE),
    proportion = mean(check_meaning, na.rm = TRUE),
    .groups = "drop"
  )

# Create a table with proportions for each word
table_per_word <- proportion_per_word %>%
  select(word, LLM, proportion) %>%
  pivot_wider(
    names_from = LLM, 
    values_from = proportion,
    values_fn = mean   
  ) %>%
  mutate(
    # Mean across all LLMs 
    mean_recognition_rate = rowMeans(
      select(., -word),
      na.rm = TRUE
    ),
    
    # Mean across LLMs included in the LLM WAT
    mean_selected_llms = rowMeans(
      select(., any_of(c(
        "GEITje-7B-ultra",
        "GPT-5.1",
        "GPT-5-mini",
        "Gemma-3-27B",
        "Gemma-3-12B",
        "llama-4-Maverick",
        "Qwen3-30B-A3B",
        "Claude-4.5-sonnet"
      ))),
      na.rm = TRUE
    )
  )

# Fit glmer to investigate effect of 'in Straattaal' in prompt
model <- glmer(
  check_meaning ~ Straattaal_added + 
    (1 | word) + 
    (1 | LLM),
  data = full_table,
  family = binomial
)

# Split for each model
results <- full_table %>%
  split(.$LLM) %>%
  map(~ glmer(
    check_meaning ~ Straattaal_added + (1 | word),
    data = .x,
    family = binomial
  ))

# Create table with glmer results for each LLM
llm_effects <- map_df(
  results,
  ~ tidy(.x, effects = "fixed"),
  .id = "LLM"
) %>%
  filter(term == "Straattaal_added")
