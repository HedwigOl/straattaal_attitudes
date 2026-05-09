library(ggplot2)
library(dplyr)
library(tidyr)
library(lme4)
library(broom.mixed)
library(lmerTest)

# Path to folder with response files
folder <- "pilot2_llmwat"

# Parse file name to extract model and prompt_style
parse_filename <- function(f) {
  
  core  <- sub("^LLMWAT-pilot_", "", basename(f))
  core  <- sub("\\.csv$", "", core)
  parts <- strsplit(core, "_")[[1]]
  
  if (length(parts) >= 2) {
    model <- parts[1]
    extra <- paste(parts[-1], collapse = "_")
  } else {
    model <- parts[1]
    extra <- NA
  }
  
  list(model = model, prompt_style = extra)
}

# Calculate bias per prompt in the file
calculate_bias <- function(csv_file) {
  
  # Read CSV file and extract model and prompt format from file name
  data <- read.csv2(csv_file, stringsAsFactors = FALSE)
  meta <- parse_filename(csv_file)
  
  data %>%
    mutate(
      base_prompt_nr = ifelse(prompt_nr <= 2, prompt_nr, prompt_nr - 3)
    ) %>%
    group_by(prompt_nr, name1, name2
    ) %>%
    summarise(
      nr_mig = sum(ass_ethnicity == "MIG", na.rm = TRUE),
      nr_nl  = sum(ass_ethnicity == "NL",  na.rm = TRUE),
      nr_stereo_mig = sum(ass_ethnicity == "MIG" & stereotypical_ass == 1, na.rm = TRUE),
      nr_stereo_nl  = sum(ass_ethnicity == "NL"  & stereotypical_ass == 1, na.rm = TRUE),
      bias = (nr_stereo_mig / nr_mig) + (nr_stereo_nl / nr_nl) - 1,
      model = meta$model,
      prompt_style = meta$prompt_style,
      .groups = "drop"
    )
}

# Calculate the biases for all files in folder
calculate_bias_all_files <- function(folder_path) {
  
  files <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)
  
  # Get all average bias scores with confidence intervals
  results <- do.call(rbind, lapply(files, calculate_bias))
  
  results <- results %>%
    mutate(
      prompt_id = as.integer(
        factor(
          interaction(prompt_nr, name1, name2, drop = TRUE),
          levels = unique(interaction(prompt_nr, name1, name2, drop = TRUE))
        )
      )
    )
  
  results <- results %>%
    filter(nr_mig + nr_nl >= 6)
  
  return(results)
}

bias_results_sep_tog <- calculate_bias_all_files(folder)

# Create df with mean bias and confidence interval for each model and prompt_style
bias_summary_sep <- bias_results_sep_tog %>%
  group_by(model, prompt_style) %>%
  summarise(
    avg_bias = mean(bias, na.rm = TRUE),
    se_bias  = sd(bias, na.rm = TRUE) / sqrt(sum(!is.na(bias))),
    .groups = "drop"
  ) %>%
  mutate(
    ci_lower = avg_bias - 1.96 * se_bias,
    ci_upper = avg_bias + 1.96 * se_bias
  )

# Create table of (pearson) correlations between bias scores for different prompt_styles
temp_correlations_sep <- bias_results_sep_tog %>%
  group_by(model) %>%
  group_modify(~{
    df <- .x
    
    # Check if multiple prompt_styles were tested
    temps <- sort(unique(df$prompt_style))
    if(length(temps) < 2) return(tibble(temp_1 = NA, temp_2 = NA, correlation = NA_real_))
    
    # Calculate pearson correlation
    combn(temps, 2, function(tp) {
      df1 <- df[df$prompt_style == tp[1], c("prompt_id", "bias")]
      df2 <- df[df$prompt_style == tp[2], c("prompt_id", "bias")]
      merged <- merge(df1, df2, by = "prompt_id", suffixes = c("_t1", "_t2"))
      tibble(temp_1 = tp[1], temp_2 = tp[2],
             correlation = cor(merged$bias_t1, merged$bias_t2, use = "complete.obs"))
    }, simplify = FALSE) %>% bind_rows()
  }) %>%
  ungroup()

windowsFonts(Times = windowsFont("Times New Roman"))

# APA-style plot
ggplot(bias_summary_sep, aes(x = model, y = avg_bias, color = prompt_style)) +
  geom_point(position = position_dodge(width = 0.4), size = 2.5) +
  geom_errorbar(
    aes(ymin = ci_lower, ymax = ci_upper),
    width = 0.2,
    position = position_dodge(width = 0.4)
  ) +
  scale_color_manual(
    values = c(
      "combined" = "#D55E00",
      "separate" = "#0072B2"
    ),
    breaks = c("combined", "separate"),
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
    color = "Prompt format:"
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

# Linear mixef-effects model assessing the effect of prompting format (individual word vs. word list)
lmer_results <- bias_results_sep_tog %>%
  mutate(prompt_style = factor(prompt_style)) %>%
  split(.$model) %>%
  purrr::imap_dfr(~{
    
    df <- .x
    model_name <- .y
    
    if(length(unique(df$prompt_style)) < 2) return(NULL)
    
    df$name_pair <- apply(df[, c("name1", "name2")], 1, function(x) {
      paste(sort(x), collapse = "_")
    })
    
    # lmerTest automatically enables p-values
    m <- lmer(bias ~ prompt_style +
                (1 | name_pair) +
                (1 | prompt_id),
              data = df)
    
    broom.mixed::tidy(m, effects = "fixed") %>%
      filter(term != "(Intercept)") %>%
      transmute(
        model = model_name,
        term,
        estimate,
        std_error = std.error,
        statistic,
        p_value = p.value
      )
  })
