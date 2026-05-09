# Load libraries
library(tidyverse)
library(lme4)
library(lmerTest)
library(emmeans)
library(broom)

# Extract model name from filename
parse_filename <- function(f) {
  core <- basename(f) %>%
    str_remove("^LLM-WAT_full_parsed_") %>%
    str_remove("\\.csv$")
  
  list(model = strsplit(core, "_")[[1]][1])
}

# Read and combine files
folder <- "C:/Users/hedwi/OneDrive/Documenten/LLM-WAT_full"

data <- list.files(folder, "\\.csv$", full.names = TRUE) %>%
  lapply(function(file) {
    read.csv2(file, stringsAsFactors = FALSE) %>%
      mutate(model = parse_filename(file)$model)
  }) %>%
  bind_rows() %>%
  filter(!is.na(ass_variety), ass_variety != "")

# Calculate bias scores
calculate_bias_df <- function(data) {
  data %>%
    mutate(
      base_prompt_nr = ifelse(prompt_nr <= 2, prompt_nr, prompt_nr - 3),
      version = ifelse(prompt_nr <= 2, "no_newline", "newline")
    ) %>%
    group_by(prompt_nr, version, prompt, name1, name2, group, labels, model) %>%
    summarise(
      nr_mig = sum(ass_ethnicity == "MIG", na.rm = TRUE),
      nr_nl = sum(ass_ethnicity == "NL", na.rm = TRUE),
      nr_stereo_mig = sum(ass_ethnicity == "MIG" & stereotypical_ass == 1, na.rm = TRUE),
      nr_stereo_nl = sum(ass_ethnicity == "NL" & stereotypical_ass == 1, na.rm = TRUE),
      bias = (nr_stereo_mig / nr_mig) + (nr_stereo_nl / nr_nl) - 1,
      .groups = "drop"
    ) %>%
    filter(nr_mig + nr_nl >= 6) %>%
    mutate(prompt_id = as.integer(factor(prompt)))
}

# Calculate bias for data
bias_results <- calculate_bias_df(data)

# Summary function
make_summary <- function(data, group_var) {
  data %>%
    group_by(model, {{ group_var }}) %>%
    summarise(
      avg_bias = mean(bias, na.rm = TRUE),
      se_bias = sd(bias, na.rm = TRUE) / sqrt(sum(!is.na(bias))),
      .groups = "drop"
    ) %>%
    mutate(
      ci_lower = avg_bias - 1.96 * se_bias,
      ci_upper = avg_bias + 1.96 * se_bias
    )
}

# Create summaries of labels and groups
bias_summary_labels <- make_summary(bias_results, labels) %>%
  mutate(labels = factor(labels, c(0, 1), c("Without labels", "With labels")))

bias_summary_group <- make_summary(bias_results, group)

# Set font
windowsFonts(Times = windowsFont("Times New Roman"))

# Plot function
plot_bias <- function(data, color_var, colors, legend_title) {
  ggplot(data, aes(x = model, y = avg_bias, color = {{ color_var }})) +
    geom_point(position = position_dodge(0.4), size = 2.5) +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                  width = 0.2,
                  position = position_dodge(0.4)) +
    scale_color_manual(values = colors, drop = FALSE) +
    coord_cartesian(ylim = c(-1, 1)) +
    scale_y_continuous(breaks = seq(-1, 1, 0.25)) +
    geom_hline(yintercept = 0, color = "red", size = 0.8) +
    theme_minimal(base_family = "Times") +
    labs(x = "Model", y = "Average Bias (± 95% CI)", color = legend_title) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
      legend.position = "top",
      panel.grid.major.y = element_line(color = "grey80"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank()
    )
}

# Plot labels
plot_bias(
  bias_summary_labels,
  labels,
  c("With labels" = "#D55E00", "Without labels" = "#0072B2"),
  "Labels present:"
)

# Plot groups
plot_bias(
  bias_summary_group,
  group,
  c(ingroup = "#D55E00", outgroup = "#0072B2", none = "#999999"),
  "Group Membership:"
)

# Fit mixed-effects model
model <- lmer(bias ~ labels * group + (1 | model), data = bias_results)

# Estimated marginal means
emm <- emmeans(model, ~ group)
pairs(emm)

# Save summary tables
write.csv(bias_summary_group, "bias_summary_full_llmwat.csv", row.names = FALSE)

bias_summary_full <- make_summary(bias_results, c(labels, group))

write.csv(bias_summary_full,
          "bias_summary_full_all_llmwat.csv",
          row.names = FALSE)

# One-sample t-tests
t_test_results <- bias_results %>%
  group_by(model) %>%
  summarise(
    mean_bias = mean(bias, na.rm = TRUE),
    sd_bias = sd(bias, na.rm = TRUE),
    t_test = list(t.test(bias, mu = 0)),
    .groups = "drop"
  ) %>%
  mutate(t_test_tidy = lapply(t_test, tidy)) %>%
  unnest(t_test_tidy) %>%
  select(model, mean_bias, sd_bias,
         t = statistic, p = p.value,
         conf.low, conf.high)

# Load recognition data from pretest
words_recog <- read.csv("table_per_word_LLMs.csv")

words_file <- read.csv("words_llmWAT.csv", sep = ";")

# Prepare recognized words
words_long_both <- words_recog %>%
  pivot_longer(-word, names_to = "LLM", values_to = "score") %>%
  mutate(
    LLM = str_replace_all(LLM, "\\.", "-"),
    LLM = str_replace(LLM, "^llama-4-Maverick", "Llama-4-Maverick")
  ) %>%
  filter(score == 1.0) %>%
  left_join(words_file, by = c("word" = "Straattaal")) %>%
  pivot_longer(c(word, StandardDutch), values_to = "ass_word") %>%
  select(LLM, ass_word) %>%
  distinct()

# Filter recognized words
data_filtered <- data %>%
  mutate(model = str_replace_all(model, "\\.", "-")) %>%
  inner_join(words_long_both, by = c("ass_word", "model" = "LLM"))

# Calculate bias for recognized words
bias_results_known <- calculate_bias_df(data_filtered) %>%
  mutate(
    model = str_replace(model, "^GPT-5-1", "GPT-5.1"),
    model = str_replace(model, "^Claude-4-5-sonnet", "Claude-4.5-sonnet"),
    condition = "Recognized words"
  )

bias_results$condition <- "All words"

# Combine data sets to get bias scores of recognized words
bias_combined <- bind_rows(bias_results, bias_results_known)

# Summarize combined data
bias_summary_combined <- make_summary(bias_combined, condition)

# Plot word recognition LLM WAT 
plot_bias(
  bias_summary_combined,
  condition,
  c("All words" = "#0072B2", "Recognized words" = "#D55E00"),
  "Bias calculated on:"
)

# Fit model comparing bias for all vs. recognized words
model <- lmer(bias ~ condition + (1 | model), data = bias_combined)
summary(model)
