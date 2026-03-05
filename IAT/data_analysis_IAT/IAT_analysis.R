library(readr)
library(dplyr)
library(lmerTest)
library(IAT)
library(ggplot2)
library(emmeans)

# Folders containing in- and out-group responses
data_folder_outgroup <- "outgroup_responses"
data_folder_ingroup  <- "ingroup_responses"

# Get all files from folders
files_outgroup <- list.files(data_folder_outgroup, pattern = "\\.csv$", full.names = TRUE)
files_ingroup  <- list.files(data_folder_ingroup,  pattern = "\\.csv$", full.names = TRUE)

# Prepare data file by cleaning and adding all needed information
prepare_file <- function(file){
  
  # Read file
  df <- read_csv(file, show_col_types = FALSE)
  
  # Select IAT trials
  iat_trials <- df[df$trial_type == "iat-html" & df$stimulus != "fixation", ]
  
  # Add response time till correct answer (not used now)
  iat_trials <- iat_trials %>%
    mutate(trial_time = time_elapsed - lag(time_elapsed))
  
  # Make response times numeric
  iat_trials <- iat_trials %>%
    mutate(
      trial_time = as.numeric(trial_time),
      rt = as.numeric(rt)
    )
  
  #Add trial number
  iat_trials <- iat_trials %>%
    mutate(
      trial_index = (as.numeric(as.character(trial_index)) - 
                       as.numeric(as.character(trial_block)) - 4) / 2
    )
  
  # Add info on correctness of response
  iat_trials$error_flag <- ifelse(iat_trials$correct == "FALSE", 1, 0)
  
  # Change block names to match traditional 7-block IAT, make block 3+4 congruent and 6+7 incongruent
  subject_group <- na.omit(df$group)[1]
  swap <- subject_group %in% c('group2', 'group3') # Group 1+4 have the same order and group 2+3
  
  iat_trials <- iat_trials %>%
    group_by(trial_block) %>%
    mutate(
      trial_in_block = row_number(),
      n_trials = n(),
      
      trial_block_iat = case_when(
        
        trial_block %in% c(1, 2) ~ trial_block,
        trial_block == 4 ~ 5,
        
        # block 3 becomes either 3 + 4 or 6 + 7 (based on group assignment)
        trial_block == 3 & trial_in_block <= n_trials/2 ~ if_else(swap, 6, 3),
        trial_block == 3 & trial_in_block >  n_trials/2 ~ if_else(swap, 7, 4),
        
        # block 5 becomes either 6 + 7 or 3 + 4 (based on group assignment)
        trial_block == 5 & trial_in_block <= n_trials/2 ~ if_else(swap, 3, 6),
        trial_block == 5 & trial_in_block >  n_trials/2 ~ if_else(swap, 4, 7)
      )
    ) %>%
    ungroup() %>%
    select(-trial_in_block, -n_trials)
  
  return(iat_trials)
}

# Add group membership and combine into one df
iat_outgroup <- bind_rows(lapply(files_outgroup, prepare_file)) 
iat_ingroup  <- bind_rows(lapply(files_ingroup,  prepare_file)) 
iat_combined <- bind_rows(iat_outgroup, iat_ingroup)

# Add demographic information to all rows and delete disturbed participants
dem_df <- read_csv("demographics.csv", show_col_types = FALSE)
iat_combined$subject_ID <- as.character(iat_combined$subject_ID)

# Correct specific subject_ID
iat_combined <- iat_combined %>%
  mutate(subject_ID = if_else(subject_ID == "7070" & group == "group4", "7171", subject_ID))

# Ensure subject_ID is character for joining
dem_df <- dem_df %>%
  mutate(subject_ID = as.character(subject_ID))

# Merge IAT data with demographics in one step
iat_data <- inner_join(iat_combined, dem_df, by = "subject_ID")
iat_data <- as.data.frame(iat_data)

# Calculate d-scores per participant
iat_dscores <- cleanIAT(
  my_data       = iat_data, 
  block_name    = "trial_block_iat", 
  trial_blocks  = c(3,4,6,7), 
  session_id    = "subject_ID",
  trial_latency = "rt", 
  trial_error   = "error_flag", 
  v_error       = 2,  # 1= means are calculates for all rts, 2= mean calculated for error + 600ms
  v_extreme     = 2,  # 1= no extreme value deletion, 2= delete trials under 400ms
  v_std         = 1   # 1= include error trials in SD, 2= no error trials in SD
)

# Add demographic/group info to d-scores in one step
iat_dscores <- iat_dscores %>%
  left_join(dem_df %>% 
              select(subject_ID, group_membership, group, disturbed, iat_experience, straattaal_user),
            by = "subject_ID")

# Write IAT data frame to csv file
write.csv(iat_dscores, file = "IAT_dscores.csv", row.names = FALSE)

# Plot intra-individual variability of reaction time
intra_individual_var_plot <- plotIIV(
  my_data       = iat_data, 
  data_type     = "raw", 
  block_name    = "trial_block_iat",
  trial_blocks  = c(3,4,6,7), 
  session_id    = "subject_ID", 
  trial_number  = "trial_index",
  trial_latency = "rt"
)

# Make APA plot
intra_individual_var_plot + 
  labs(
    x = "IAT Block",
    y = "Reaction Time (ms)"
  ) +
  theme_minimal(base_family = "Times New Roman") +
  theme(
    text = element_text(size = 12),           
    axis.title = element_text(face = "bold"),      
    axis.text = element_text(size = 11),  
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray80"), 
    legend.title = element_text(face = "bold"),
    
legend.text = element_text(size = 11)
  )

# Plot individual variability in the IAT
individual_var_plot <- plotIndVar(
  my_data       = iat_data, 
  block_name    = "trial_block_iat", 
  trial_blocks  = c(3,4,6,7),
  session_id    = "subject_ID", 
  trial_latency = "rt",
  trial_error   = "error_flag"
)

# Make APA plot
individual_var_plot +
  labs(
    x = "Subject ID",
    y = "Reaction Time (ms)"
  ) +
  theme_minimal(base_family = "Times New Roman") +
  theme(
    text = element_text(size = 12),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(size = 11),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey80"),
    legend.title = element_text(face = "bold")
  )

# Plot IAT item reaction time variability
rt_variability <- plotItemVar(
  my_data       = iat_data, 
  block_name    = "trial_block_iat", 
  trial_blocks  = c(3,4,6,7), 
  item_name     = "stimulus", 
  trial_latency = "rt",
  trial_error   = "error_flag"
)

# Make APA plot
rt_variability +
  labs(
    x = "IAT Stimulus",
    y = "Reaction Time Variability (ms)"
  ) +
  theme_minimal(base_family = "Times New Roman") +
  theme(
    text = element_text(size = 12),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(size = 11),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey80")
  )

# Plot proportion of errors per stimulus
error_prop <- plotItemErr(
  my_data       = iat_data, 
  item_name     = "stimulus", 
  trial_latency = "rt", 
  trial_error   = "error_flag"
)

# Make APA plot
error_prop +
  labs(
    x = "IAT Stimulus",
    y = "Proportion of Errors"
  ) +
  theme_minimal(base_family = "Times New Roman") +
  theme(
    text = element_text(size = 12),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(size = 11),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey80")
  )

# T-test for d-score deviating from 0
t.test(iat_dscores$IAT, mu = 0)

# Plot all d-scores
ggplot(iat_dscores, aes(y = IAT)) +
  geom_boxplot(fill = "white", color = "black", width = 0.3) +
  labs(
    x = "",
    y = "IAT D-score"
  ) +
  theme_classic(base_size = 12) +
  theme(
    axis.title = element_text(face = "plain"),
    axis.text = element_text(color = "black"),
    plot.title = element_blank()
  )

# Rename groups to have 1 + 2 and 3 + 4 matching test block orders
iat_dscores$group <- recode(iat_dscores$group,
                            "group1" = "Version 1",
                            "group2" = "Version 4",
                            "group3" = "Version 3",
                            "group4" = "Version 2")

# Create order variable
iat_dscores$order <- ifelse(iat_dscores$group %in% c("Version 1", "Version 2"),
                            "Order 1",
                            "Order 2")

# Ensure correct order of versions
iat_dscores$group <- factor(iat_dscores$group,
                            levels = c("Version 1", "Version 2", "Version 3", "Version 4"))

# Create box plot for four versions of the IAT
my_colors <- c("grey70", "grey70", "grey40", "grey40")

boxplot(IAT ~ group,
        data = iat_dscores,
        col = my_colors,
        xlab = "IAT Version",
        ylab = "IAT D-score",
        cex.axis = 0.8, 
        cex.lab = 0.9)    
legend("topright",
       legend = c("Congruent block first", "Incongruent block first"),
       fill = c("grey70", "grey40"),
       bty = "n",
       cex = 0.8)

# T-test for effect of IAT version on d-score
t.test(IAT ~ order, data = iat_dscores)
aggregate(IAT ~ order, data = iat_dscores, 
          FUN = function(x) c(mean = mean(x), sd = sd(x)))

# Create overview table on versions for straattaal_users
groups_table <- iat_dscores %>%
  count(straattaal_user, group) %>%
  pivot_wider(
    names_from = group,
    values_from = n,
    values_fill = 0
  )

# Chi-square test on versions for straattaal_users
chisq.test(groups_table %>% select(-straattaal_user))

iat_dscores$group_membership <- recode(iat_dscores$group_membership,
                                      "ingroup"  = "In-group",
                                      "outgroup" = "Out-group")

# Create box plots for group membership based on pre-screening question
par(family = "Times New Roman")
boxplot(IAT ~ group_membership,
        data = iat_dscores,
        xlab = "Group membership",
        ylab = "IAT D-score")

# Linear model with p-values for group membership (pre-screening) and d-score
lmer_model <- lmer(IAT ~ group_membership + (1 | group), data = iat_dscores)
summary(lmer_model)

iat_dscores$straattaal_user <- recode(iat_dscores$straattaal_user,
                            "Ja"  = "In-group",
                            "Nee" = "Out-group")

# Create box plots for group membership based on question after IAT
boxplot(IAT ~ straattaal_user,
        data = iat_dscores,
        xlab = "Group membership",
        ylab = "IAT D-score")

# Linear model with p-values for group membership (after experiment) and d-score
lmer_model_q <- lmer(IAT ~ straattaal_user + (1 | group), data = iat_dscores)
summary(lmer_model_q)

# Create new column with group membership based on responses to both questions
iat_dscores$combined_group <- with(iat_dscores,
                                   ifelse(group_membership == "In-group" & straattaal_user == "In-group", "Ingroup",
                                          ifelse(group_membership == "Out-group" & straattaal_user == "Out-group", "Outgroup",
                                                 "Inconsistent"))
)

# Convert to factor to preserve order
iat_dscores$combined_group <- factor(iat_dscores$combined_group, levels = c("Ingroup", "Outgroup", "Inconsistent"))

# Box plot for the d-scores for the three Straattaal groups
boxplot(IAT ~ combined_group,
        data = iat_dscores,
        xlab = "Group membership",
        ylab = "IAT D-score")

# Linear mixed model with p-values for group membership (both questions) and d-score
lmer_model_combined <- lmer(IAT ~ combined_group + (1 | group), data = iat_dscores)
summary(lmer_model_combined)
emmeans(lmer_model_combined, pairwise ~ combined_group)

# Create overview table on versions of the IAT
groups_table <- iat_dscores %>%
  count(combined_group, group) %>%
  pivot_wider(
    names_from = group,
    values_from = n,
    values_fill = 0
  )

# Chi-square test on versions of the IAT
chisq.test(groups_table %>% select(-combined_group))
