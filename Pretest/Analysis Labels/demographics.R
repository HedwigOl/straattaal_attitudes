# Read cleaned data file
df <- read.csv("cleaned_data_pretest_labels.csv")

# Create table of Straattaal use distribution
table(df$straattaal_use)

# Create seperate dfs for different Straattaal use groups
answers <- unique(df$straattaal_use)
straattaal_dfs <- lapply(answers, function(a) {subset(df, straattaal_use == a)})
names(straattaal_dfs) <- answers

# Gender distribution
table(df$gender)
gender_strttlgroups <- lapply(straattaal_dfs, function(df) {table(df$gender)})
gender_strttlgroups

# Age distribution
min_age <- min(df$age, na.rm = TRUE)
min_age
max_age <- max(df$age, na.rm = TRUE)
max_age
mean_age <- mean(df$age, na.rm = TRUE)
mean_age_strttlgroups <- sapply(straattaal_dfs, function(df) {mean(df$age, na.rm = TRUE)})
mean_age
mean_age_strttlgroups

sd_age <- sd(df$age, na.rm = TRUE)
sd_age_strttlgroups <- sapply(straattaal_dfs, function(df) {sd(df$age, na.rm = TRUE)})
sd_age
sd_age_strttlgroups

# Randstad distribution
table(df$randstad)
randstad_strttlgroups <- lapply(straattaal_dfs, function(df) {table(df$randstad)})
randstad_strttlgroups

# Education distribution
table(df$education)
education_strttlgroups <- lapply(straattaal_dfs, function(df) {table(df$education)})
education_strttlgroups

# Birth country distribution
table(df$born_nl)
birth_country_strttlgroups <- lapply(straattaal_dfs, function(df) {table(df$born_nl)})
birth_country_strttlgroups

# Birth country parents distribution
table(df$parents_born_nl)
birth_countryparents_strttlgroups <- lapply(straattaal_dfs, function(df) {table(df$parents_born_nl)})
birth_countryparents_strttlgroups
