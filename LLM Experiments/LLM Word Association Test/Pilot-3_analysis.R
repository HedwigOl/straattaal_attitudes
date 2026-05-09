library(ggplot2)
library(dplyr)
library(tidyr)
library(lme4)
library(lmerTest)

parse_filename <- function(f) {
  core <- sub("^LLMWAT-pilot3?_", "", basename(f))
  core <- sub("\\.csv$", "", core)
  parts <- strsplit(core, "_")[[1]]
  list(model = parts[1])
}

# Path to folder with response files
folder <- "pilot3_llmWAT"

all_files <- list.files(folder, pattern = "\\.csv$", full.names = TRUE)

pilot3_files <- grep("LLMWAT-pilot3_", all_files, value = TRUE)
pilot_files  <- grep("LLMWAT-pilot_", all_files, value = TRUE)

# Function to read pilot files and add group/labels
read_pilot_file <- function(file) {
  read.csv2(file, stringsAsFactors = FALSE) %>%
    mutate(
      group  = "none",
      labels = 0,
      model  = parse_filename(file)$model 
    )
}

read_pilot3_file <- function(file) {
  read.csv2(file, stringsAsFactors = FALSE) %>%
    mutate(
      model = parse_filename(file)$model
    )
}

# Read and merge all files
pilot_data  <- do.call(rbind, lapply(pilot_files, read_pilot_file))
pilot3_data <- do.call(rbind, lapply(pilot3_files, read_pilot3_file))

# Merge together
all_data <- bind_rows(pilot_data, pilot3_data)
all_data <- all_data %>%
  mutate(labels = factor(labels, levels = c(0,1), labels = c("Without labels", "With labels")))

# Function to calculate bias on a dataframe (not per file anymore)
calculate_bias_df <- function(data) {
  data %>%
    mutate(
      base_prompt_nr = ifelse(prompt_nr <= 2, prompt_nr, prompt_nr - 3),
      version        = ifelse(prompt_nr <= 2, "no_newline", "newline")
    ) %>%
    group_by(prompt_nr, version, prompt, name1, name2, group, labels, model
    ) %>%
    summarise(
      nr_mig        = sum(ass_ethnicity == "MIG", na.rm = TRUE),
      nr_nl         = sum(ass_ethnicity == "NL",  na.rm = TRUE),
      nr_stereo_mig = sum(ass_ethnicity == "MIG" & stereotypical_ass == 1, na.rm = TRUE),
      nr_stereo_nl  = sum(ass_ethnicity == "NL"  & stereotypical_ass == 1, na.rm = TRUE),
      bias          = (nr_stereo_mig / nr_mig) + (nr_stereo_nl / nr_nl) - 1,
      .groups = "drop"
    ) %>%
    filter(nr_mig + nr_nl >= 6) %>% # keep only valid counts
    mutate(prompt_id = as.integer(factor(prompt, levels = unique(prompt))))
}

# Calculate bias on merged data
bias_results <- calculate_bias_df(all_data)

# Create df with mean bias and confidence interval for each model and temperature
bias_summary_labels <- bias_results %>%
  group_by(model, labels) %>%
  summarise(
    avg_bias = mean(bias, na.rm = TRUE),
    se_bias  = sd(bias, na.rm = TRUE) / sqrt(sum(!is.na(bias))),
    .groups = "drop"
  ) %>%
  mutate(
    ci_lower = avg_bias - 1.96 * se_bias,
    ci_upper = avg_bias + 1.96 * se_bias
  )

windowsFonts(Times = windowsFont("Times New Roman"))

# APA-style plot
ggplot(bias_summary_labels, aes(x = model, y = avg_bias, color = labels)) +
  geom_point(position = position_dodge(width = 0.4), size = 2.5) +
  geom_errorbar(
    aes(ymin = ci_lower, ymax = ci_upper),
    width = 0.2,
    position = position_dodge(width = 0.4)
  ) +
  scale_color_manual(
    values = c(
      "With labels" = "#D55E00",
      "Without labels" = "#0072B2"
    ),
    breaks = c("With labels", "Without labels"),
    drop = FALSE
  ) +
  coord_cartesian(ylim = c(-1, 1)) +
  scale_y_continuous(
    breaks = seq(-1, 1, 0.25)  # only show horizontal lines at -1, -0.75, ..., 1
  ) +
  geom_hline(yintercept = 0, color = "red", size = 0.8) +  # red 0 line
  theme_minimal(base_family = "Times") +
  labs(
    title = NULL,
    x = "Model",
    y = "Average Bias (± 95% CI)",
    color = "Explicitly mentioning variety and ethnic groups:"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, family = "Times", size = 10),
    axis.text.y = element_text(family = "Times", size = 10),
    axis.title.x = element_text(family = "Times", size = 11),
    axis.title.y = element_text(family = "Times", size = 11),
    legend.position = "top",
    legend.title = element_text(family = "Times", size = 10),
    legend.text = element_text(family = "Times", size = 10),
    panel.grid.major.y = element_line(color = "grey80"),   # only horizontal grid lines
    panel.grid.major.x = element_blank(),                  # remove vertical lines
    panel.grid.minor = element_blank(),
    plot.margin = margin(5, 5, 5, 5)
  )

# Create summary of bias results
bias_summary_group <- bias_results %>%
  group_by(model, group) %>%
  summarise(
    avg_bias = mean(bias, na.rm = TRUE),
    se_bias  = sd(bias, na.rm = TRUE) / sqrt(sum(!is.na(bias))),
    .groups = "drop"
  ) %>%
  mutate(
    ci_lower = avg_bias - 1.96 * se_bias,
    ci_upper = avg_bias + 1.96 * se_bias
  )

windowsFonts(Times = windowsFont("Times New Roman"))

# APA-style plot
ggplot(bias_summary_group, aes(x = model, y = avg_bias, color = group)) +
  geom_point(position = position_dodge(width = 0.4), size = 2.5) +
  geom_errorbar(
    aes(ymin = ci_lower, ymax = ci_upper),
    width = 0.2,
    position = position_dodge(width = 0.4)
  ) +
  scale_color_manual(
    values = c(
      "ingroup"  = "#D55E00",
      "outgroup" = "#0072B2",
      "none"     = "#999999"
    ),
    breaks = c("ingroup", "outgroup", "none"),
    drop = FALSE
  ) +
  coord_cartesian(ylim = c(-1, 1)) +
  scale_y_continuous(
    breaks = seq(-1, 1, 0.25) 
  ) +
  geom_hline(yintercept = 0, color = "red", size = 0.8) +  # red 0 line
  theme_minimal(base_family = "Times") +
  labs(
    title = NULL,
    x = "Model",
    y = "Average Bias (± 95% CI)",
    color = "Group membership instruction:"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, family = "Times", size = 10),
    axis.text.y = element_text(family = "Times", size = 10),
    axis.title.x = element_text(family = "Times", size = 11),
    axis.title.y = element_text(family = "Times", size = 11),
    legend.position = "top",
    legend.title = element_text(family = "Times", size = 10),
    legend.text = element_text(family = "Times", size = 10),
    panel.grid.major.y = element_line(color = "grey80"),   # only horizontal grid lines
    panel.grid.major.x = element_blank(),                  # remove vertical lines
    panel.grid.minor = element_blank(),
    plot.margin = margin(5, 5, 5, 5)
  )

# Fit model for effect of labels and group membership instructions
model <- lmer(bias ~ labels * group + (1 | model), data = bias_results)
summary(model)


