library(readr)
library(dplyr)
library(lmerTest)
library(IAT)
library(ggplot2)
library(emmeans)

# Load & prepare IAT data
files_outgroup <- list.files("outgroup_responses", "\\.csv$", full.names = TRUE)
files_ingroup  <- list.files("ingroup_responses",  "\\.csv$", full.names = TRUE)

prepare_file <- function(file){
  df <- read_csv(file, show_col_types = FALSE)
  subject_group <- na.omit(df$group)[1]
  swap <- subject_group %in% c('group2','group3')
  
  df %>%
    filter(trial_type == "iat-html", stimulus != "fixation") %>%
    mutate(
      trial_time = as.numeric(time_elapsed - lag(time_elapsed)),
      rt = as.numeric(rt),
      trial_index = (as.numeric(trial_index) - as.numeric(trial_block) - 4)/2,
      error_flag = as.integer(correct == "FALSE")
    ) %>%
    group_by(trial_block) %>%
    mutate(
      i = row_number(), n = n(),
      trial_block_iat = case_when(
        trial_block %in% c(1,2) ~ trial_block,
        trial_block == 4 ~ 5,
        trial_block == 3 & i <= n/2 ~ if_else(swap,6,3),
        trial_block == 3 & i >  n/2 ~ if_else(swap,7,4),
        trial_block == 5 & i <= n/2 ~ if_else(swap,3,6),
        TRUE ~ if_else(swap,4,7)
      )
    ) %>%
    ungroup() %>%
    select(-i, -n)
}

iat_data <- bind_rows(
  bind_rows(lapply(files_outgroup, prepare_file)),
  bind_rows(lapply(files_ingroup,  prepare_file))
)

# Add demographic information to IAT data
dem_df <- read_csv("demographics.csv", show_col_types = FALSE) %>%
  mutate(subject_ID = as.character(subject_ID))

iat_data <- iat_data %>%
  mutate(subject_ID = as.character(subject_ID),
         subject_ID = if_else(subject_ID == "7070" & group == "group4","7171",subject_ID)) %>%
  inner_join(dem_df, by = "subject_ID") %>%
  as.data.frame()

# Compute D-scores for each participant
iat_dscores <- cleanIAT(
  my_data = iat_data,
  block_name = "trial_block_iat",
  trial_blocks = c(3,4,6,7),
  session_id = "subject_ID",
  trial_latency = "rt",
  trial_error = "error_flag",
  v_error = 2, v_extreme = 2, v_std = 1
) %>%
  left_join(select(dem_df, subject_ID, group_membership, group,
                   disturbed, iat_experience, straattaal_user),
            by = "subject_ID") %>%
  mutate(IAT = as.numeric(IAT))

write.csv(iat_dscores, "IAT_dscores.csv", row.names = FALSE)

# Recode versions to the original block order of Greenwald et al., 1998
iat_dscores <- iat_dscores %>%
  mutate(
    group = recode(group,
                   group1="Version 1", group2="Version 4",
                   group3="Version 3", group4="Version 2"),
    order = if_else(group %in% c("Version 1","Version 2"),"Order 1","Order 2"),
    group_membership = recode(group_membership,
                              ingroup="In-group", outgroup="Out-group"),
    straattaal_user = recode(straattaal_user,
                             Ja="In-group", Nee="Out-group"),
    combined_group = case_when(
      group_membership=="In-group" & straattaal_user=="In-group" ~ "Ingroup",
      group_membership=="Out-group" & straattaal_user=="Out-group" ~ "Outgroup",
      TRUE ~ "Inconsistent"
    )
  )

# T-test for d-scores deviating from zero
t.test(iat_dscores$IAT, mu = 0)
sd(iat_dscores$IAT, na.rm = TRUE)

# Analysis function for group membership
run_iat_analysis <- function(data, group_var){
  
  group_var <- rlang::ensym(group_var)
  group_name <- rlang::as_string(group_var)
  
  cat("IAT analysis for:", group_name, "\n")
  cat("====================\n")
  
  # Get descriptives
  print(
    data %>%
      group_by(!!group_var) %>%
      summarise(mean = mean(IAT, na.rm = TRUE),
                sd   = sd(IAT, na.rm = TRUE),
                .groups = "drop")
  )
  
  # Create boxplots for groups
  print(
    ggplot(data, aes(x = !!group_var, y = IAT)) +
      geom_boxplot() +
      geom_hline(yintercept = 0, color = "red") +
      labs(x = group_name, y = "IAT D-score") +
      theme_classic()
  )
  
  # Run linear mixed effects model for group on d-scores
  model <- lmer(reformulate(group_name, "IAT"), data = data)
  print(summary(model))
  
  # Post-hoc if more than two groups (case for combined analysis)
  if (n_distinct(pull(data, !!group_var)) > 2) {
    print(emmeans(model, pairwise ~ !!group_var))
  }
}

# Run analysis of group membership on D-scores for three grouping approaches
run_iat_analysis(iat_dscores, group_membership)
run_iat_analysis(iat_dscores, straattaal_user)
run_iat_analysis(iat_dscores, combined_group)
