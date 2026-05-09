library(tidyverse)

### Calculate correlations difference ratings

# Load files
RR_scores_llm <- read.csv2("LLM_diffs_RR_at.csv",stringsAsFactors = FALSE
) %>%
  mutate(
    attribute = recode(
      attribute,
      "social_class" = "class"
    )
  )

RR_scores_human <- read.csv2("RR_means_humans.csv", stringsAsFactors = FALSE)

# Calculate correlations
df_scores <- inner_join(
  RR_scores_llm,
  RR_scores_human,
  by = "attribute",
  suffix = c("_llm", "_human")
)

correlations <- df_scores %>%
  group_by(model) %>%
  summarise(
    correlation = cor(
      mean_value,
      mean_rating,
      use = "complete.obs",
      method = "spearman"
    ),
    .groups = "drop"
  )

### Calculate correlations mean ratings

# Load files
RR_means_llm <- read.csv2(
  "LLM_means_RR.csv",
  stringsAsFactors = FALSE
) %>%
  mutate(
    attribute = recode(
      attribute,
      "social_class" = "class"
    )
  )

RR_means_human <- read.csv2(
  "RR_means_humans_att.csv",
  stringsAsFactors = FALSE
) %>%
  mutate(
    variety = recode(
      language_variation,
      "STANDAARD NEDERLANDS" = "Standaardnederlands",
      "STRAATTAAL" = "Straattaal"
    )
  )

# Calculate correlations
df_means <- inner_join(
  RR_means_llm,
  RR_means_human,
  by = c("attribute", "variety"),
  suffix = c("_llm", "_human")
)

correlations_means <- df_means %>%
  group_by(model) %>%
  summarise(
    correlation = cor(
      mean_score_llm,
      mean_score_human,
      use = "complete.obs",
      method = "spearman"
    ),
    .groups = "drop"
  )
