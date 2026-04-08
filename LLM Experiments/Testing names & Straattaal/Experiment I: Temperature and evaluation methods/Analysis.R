library(tidyverse)
library(irr)
library(lme4)

# Folder with all LLM responses
folder_path <- "LLM_responses_exp1"

# List all CSV files
csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)

# Read and combine CSV files into one data frame. Add information about LLM, temperature and the presence of 'in Straattaal'
big_table <- csv_files %>% 
  set_names() %>%
  map_df(~ read.csv2(.x), .id = "source") %>%
  mutate(
    file = str_remove(basename(source), "\\.csv$"),              # Get file name
    LLM = as.factor(str_split_fixed(file, "_", 4)[,3]),          # Extract LLM from file name
    temperature = as.factor(str_split_fixed(file, "_", 4)[,4]),  # Extract temperature from file name
    Straattaal_added = as.factor(if_else(str_detect(prompt, "in Straattaal"), 1, 0)) # Add 1 if 'in Straattaal' is included in prompt
  ) %>%
  select(-source, -file) 

# Summarize proportion of correct responses of manual evaluation for all LLMs and temperatures
proportion_table <- big_table %>%
  group_by(LLM, temperature, Straattaal_added) %>%
  summarise(
    n_total = n(),                        
    n_meaning_1 = sum(check_meaning_manual),     
    proportion = round(mean(check_meaning_manual), 3)     
  ) %>%
  ungroup()

# Calculate Cohen's Kappa between evaluation methods
kappa2(big_table[, c("check_meaning", "check_meaning_manual")])
kappa2(big_table[, c("check_meaning_WordNet", "check_meaning_manual")])

# Fit GLMM to investigate effect of temperature settings
glmm_model <- glmer(
  check_meaning_manual ~ temperature * Straattaal_added + (1 | LLM),
  data = big_table,
  family = binomial
)

summary(glmm_model)
