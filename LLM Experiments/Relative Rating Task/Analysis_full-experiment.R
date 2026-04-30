library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(lme4)
library(lmerTest)
library(emmeans)
library(broom)

folder <- "Relative-rating-full"

# Parse meta information from filename
parse_filename <- function(filename) {
  
  base <- basename(filename) %>%
    sub("^RR-full_", "", .) %>%
    sub("\\.csv$", "", .)
  
  parts <- strsplit(base, "_")[[1]]
  
  list(
    model = parts[1],
    temperature = if (length(parts) >= 2) parts[2] else NA_character_,
    prompt_iteration = if (length(parts) >= 3) parts[3] else NA_character_
  )
}

# Parse LLM responses of a single file
create_parsed_csv_full <- function(file) {
  
  meta <- parse_filename(file)
  
  read_tsv(file, show_col_types = FALSE) %>%
    mutate(
      response = str_trim(as.character(response)),
      prompt = str_replace(prompt, "(?s)^.*?\\?.*?\\?\\s*", "") %>%
        str_trim()
    ) %>%
    filter(str_detect(response, "^\\d+$")) %>%
    mutate(response = as.integer(response)) %>%
    filter(between(response, 0, 100)) %>%
    mutate(
      model = meta$model,
      temperature = meta$temperature,
      prompt_iteration = meta$prompt_iteration
    ) %>%
    select(prompt, attribute, group_membership, language_variety,
           response, model, temperature, prompt_iteration)
}

# Parse all files
parse_all_files <- function(folder_path) {
  
  files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)
  
  do.call(rbind, lapply(files, create_parsed_csv_full))
}

# Compute rating differences
compute_rating_differences <- function(df) {
  
  df %>%
    select(attribute, model, temperature, prompt, prompt_iteration,
           language_variety, response, group_membership) %>%
    
    group_by(attribute, model, temperature, prompt, prompt_iteration,
             group_membership, language_variety) %>%
    summarise(response = mean(response, na.rm = TRUE), .groups = "drop") %>%
    
    pivot_wider(names_from = language_variety, values_from = response) %>%
    
    mutate(
      score = ifelse(
        !is.na(Straattaal) & !is.na(Standaardnederlands),
        Standaardnederlands - Straattaal,
        NA_real_
      ),
      score = ifelse(attribute == "location", -score, score)
    ) %>%
    
    select(model, temperature, prompt_iteration, prompt,
           attribute, group_membership, score)
}

parsed_data <- parse_all_files(folder)
all_diffs   <- compute_rating_differences(parsed_data)

# Summarize rating differences
summary_df <- all_diffs %>%
  mutate(
    attribute = recode(attribute,
                       "social_class" = "social class",
                       "rating" = "evaluation"
    )
  ) %>%
  group_by(attribute, model, temperature, group_membership) %>%
  summarise(
    mean_score = mean(score, na.rm = TRUE),
    sd_score   = sd(score, na.rm = TRUE),
    n          = sum(!is.na(score)),
    .groups = "drop"
  ) %>%
  mutate(
    se = sd_score / sqrt(n),
    ci_lower = mean_score - 1.96 * se,
    ci_upper = mean_score + 1.96 * se
  )

# Plot rating differences
ggplot(summary_df,
       aes(x = attribute, y = mean_score, color = group_membership)) +
  geom_point(size = 1.9, position = position_dodge(width = 0.6)) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                width = 0.2, position = position_dodge(width = 0.6)) +
  facet_wrap(~ model, ncol = 2) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_y_continuous(limits = c(-100, 100)) +
  scale_color_manual(values = c(
    "none"     = "grey40",
    "ingroup"  = "#D55E00",
    "outgroup" = "#0072B2"
  )) +
  labs(
    x = "Attribute",
    y = "Rating Difference (Standard Dutch - Straattaal)",
    color = "Group Membership"
  ) +
  theme_minimal(base_family = "Times New Roman") +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major.x = element_blank()
  )

# T-test for deviation from neutral 0
t_test_results <- all_diffs %>%
  group_by(model, attribute) %>%
  summarise(
    n    = sum(!is.na(score)),
    mean = mean(score, na.rm = TRUE),
    sd   = sd(score, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  rowwise() %>%
  mutate(
    test = list(
      if (n > 1 && sd > 0) t.test(score, mu = 0) else NULL
    ),
    tidy = list(
      if (is.null(test)) {
        tibble(statistic = NA_real_, p.value = NA_real_)
      } else {
        broom::tidy(test) %>%
          select(statistic, p.value)
      }
    )
  ) %>%
  unnest(tidy) %>%
  select(model, attribute, mean, sd, statistic, p.value)

# Evaluate effect of group membership on rating with lmer
model <- lmer(score ~ group_membership * attribute + (1 | model),
              data = all_diffs)

emm <- emmeans(model, ~ group_membership | attribute)
pairs(emm)

# Pairwise comparisons by attribute
results_df <- lapply(unique(all_diffs$attribute), function(a) {
  
  sub_data <- all_diffs %>%
    filter(attribute == a)
  
  fit <- lmer(score ~ group_membership + (1 | model), data = sub_data)
  
  emm <- emmeans(fit, ~ group_membership)
  
  pairs(emm, adjust = "tukey") %>%
    as.data.frame() %>%
    mutate(attribute = a)
  
}) %>%
  bind_rows()

write.csv(results_df,
          "pairwise_group_comparisons_by_attribute.csv",
          row.names = FALSE)

# Linear models per model & attribute
results_group <- lapply(unique(all_diffs$model), function(m) {
  
  lapply(unique(all_diffs$attribute), function(a) {
    
    sub_data <- all_diffs %>%
      filter(model == m, attribute == a)
    
    lm(score ~ group_membership, data = sub_data) %>%
      broom::tidy() %>%
      filter(term != "(Intercept)") %>%
      mutate(model = m, attribute = a)
    
  }) %>%
    bind_rows()
  
}) %>%
  bind_rows()

write.csv(results_group, "group_membership_by_model_attribute.csv", row.names = FALSE)
