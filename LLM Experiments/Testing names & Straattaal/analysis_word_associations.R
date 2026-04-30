library(tidyverse)
library(lme4)
library(broom.mixed)

folder_path <- "check_associations"

# Read and combine data
full_table <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE) %>%
  set_names() %>%
  map_df(
    ~ read.csv2(.x, stringsAsFactors = FALSE, colClasses = "character"),
    .id = "source"
  ) %>%
  mutate(
    LLM = str_remove(basename(source), "^association-check_|\\.csv$"),
    Straattaal_added = as.numeric(str_detect(old_prompt, "in Straattaal"))
  ) %>%
  select(-source)

# General function to fit model for each attribute
fit_glmer_by_llm <- function(data, outcome) {
  data %>%
    split(.$LLM) %>%
    map(~ {
      .x[[outcome]] <- as.numeric(.x[[outcome]])
      .x$Straattaal_added <- as.numeric(.x$Straattaal_added)
      
      if (length(unique(.x[[outcome]])) < 2) return(NULL)
      
      glmer(
        reformulate("Straattaal_added", response = outcome),
        data = .x,
        family = binomial,
        control = glmerControl(
          optimizer = "bobyqa",
          optCtrl = list(maxfun = 2e5)
        ),
        random = ~ (1 | word)
      )
    }) %>%
    map_df(
      ~ tidy(.x, effects = "fixed"),
      .id = "LLM"
    ) %>%
    filter(term == "Straattaal_added")
}

# Run linear model for all attributes
outcomes <- c("drugs", "seks", "crimineel")

results <- set_names(outcomes) %>%
  map(~ fit_glmer_by_llm(full_table, .x))
