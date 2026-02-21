# Read csv files with d-scores and ratings
iat_df  <- read_csv("IAT_dscores.csv", show_col_types = FALSE)
expl_df <- read_csv("explicit_ratings.csv", show_col_types = FALSE)

# Merge data frames together
full_df <- full_join(iat_df, expl_df, by = "subject_ID")

# Calculate Spearman's rho for iat score and explicit rating
cor.test(full_df$ethnicity,
         full_df$IAT,
         method = "spearman",
         exact = FALSE)
