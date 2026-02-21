library(readr)
library(dplyr)
library(lmerTest)
library(IAT)

# Folders containing in- and outgroup responses
data_folder_outgroup <- "outgroup_responses"
data_folder_ingroup  <- "ingroup_responses"

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

# Add demographic information to all rows
dem_df <- read_csv("demographics.csv", show_col_types = FALSE)
iat_combined$subject_ID <- as.character(iat_combined$subject_ID)
dem_df$subject_ID       <- as.character(dem_df$subject_ID)
iat_data <- left_join(iat_combined, dem_df, by = "subject_ID")

# Calculate d-scores per participant
iat_dscores <- cleanIAT(my_data       = iat_data, 
                        block_name    = "trial_block_iat", 
                        trial_blocks  = c(3,4,6,7), 
                        session_id    = "subject_ID",
                        trial_latency = "rt", 
                        trial_error   = "error_flag", 
                        v_error       = 2,  # 1= means are calculates for all rts, 2= mean calculated for error + 600ms
                        v_extreme     = 2,  # 1= no extreme value deletion, 2= delete trials under 400ms
                        v_std         = 1)  # 1= include error trials in SD, 2= no error trials in SD

# Add group membership etc to iat df
group_df <- iat_data %>%
  select(subject_ID, group_membership, group, disturbed, iat_experience, straattaal_user) %>%
  distinct() 

iat_dscores <- iat_dscores %>%
  left_join(group_df, by = "subject_ID")

# Filter out disturbed and IAT-experienced people 
iat_dscores <- iat_dscores %>%
  filter(grepl("nee|niet", disturbed, ignore.case = TRUE))

# Ensure it's a data frame
iat_data_df <- as.data.frame(iat_data)

# Write iat df to csv file
write.csv(iat_dscores, file = "IAT_dscores.csv", row.names = FALSE)

# Plot intraindividual variability of reaction time
plotIIV(my_data      = iat_data_df, 
        data_type    = "raw", 
        block_name   = "trial_block_iat",
        trial_blocks = c(3,4,6,7), 
        session_id   = "subject_ID", 
        trial_number = "trial_index",
        trial_latency = "rt")

# Plot individual variability in the IAT
plotIndVar(my_data       = iat_data_df, 
           block_name    = "trial_block_iat", 
           trial_blocks  = c(3,4,6,7),
           session_id    = "subject_ID", 
           trial_latency = "rt",
           trial_error   = "error_flag")

# Plot proportion of errors per item in the IAT
plotItemErr(my_data       = iat_data_df, 
            item_name     = "stimulus", 
            trial_latency = "rt", 
            trial_error   = "error_flag")

# Plot IAT item variability
plotItemVar(my_data       = iat_data_df, 
            block_name    = "trial_block_iat", 
            trial_blocks  = c(3,4,6,7), 
            item_name     = "stimulus", 
            trial_latency = "rt",
            trial_error   = "error_flag")

# T-test for d-score deviating from 0
t.test(iat_dscores$IAT, mu = 0)

boxplot(IAT ~ group_membership,
        data = iat_dscores,
        xlab = "Group membership",
        ylab = "IAT D-score",
        main = "IAT D-scores for In and Outgroup")

# Linear model with p-values for group membership and d-score
lmer_model <- lmer(IAT ~ group_membership + (1 | group), data = iat_dscores)
summary(lmer_model)

boxplot(IAT ~ straattaal_user,
        data = iat_dscores,
        xlab = "Straattaal user",
        ylab = "IAT D-score",
        main = "IAT D-scores for In and Outgroup")

# Linear model with p-values for answer straattaalvraag and d-score
lmer_model_q <- lmer(IAT ~ straattaal_user + (1 | group), data = iat_dscores)
summary(lmer_model_q)


### twijfelaars weglaten
iat_dscores <- iat_dscores %>%
  filter(!(group_membership == "ingroup" & grepl("^nee$", straattaal_user, ignore.case = TRUE)))

lmer_model_soms <- lmer(IAT ~ straattaal_user + (1 | group), data = iat_dscores)
summary(lmer_model_soms)
