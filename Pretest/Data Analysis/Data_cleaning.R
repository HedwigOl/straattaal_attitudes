# Read in the raw csv file
raw_data <- read.csv("data/pretest_25-9.csv", 
                     header = FALSE, 
                     stringsAsFactors = FALSE)

# Use the second row as header and remove first three rows
colnames(raw_data) <- as.character(unlist(raw_data[2, ]))
data <- raw_data[-c(1, 2, 3), ]

# Remove columns without data to be analysed
cols_to_remove <- c("Response Type", "IP Address", "Response ID", "Recipient Last Name", 
                    "Recipient First Name", "Recipient Email", "External Data Reference", 
                    "Location Latitude", "Location Longitude", "Distribution Channel", 
                    "User Language", "Wat is uw Prolific ID?", "Finished", "Start Date",
                    "End Date", "Recorded Date")
data <- data[ , !(names(data) %in% cols_to_remove) ]

# Remove unfinished survey answers
data <- subset(data, Progress == '100')
rownames(data) <- NULL


# Check mean and median of survey duration
data$`Duration (in seconds)` <- as.numeric(as.character(data$`Duration (in seconds)`))
mean(data$`Duration (in seconds)`, na.rm = TRUE)
median(data$`Duration (in seconds)`, na.rm = TRUE)

# Check outliers for response time using IQR
Q1 <- quantile(data$`Duration (in seconds)`, 0.25, na.rm = TRUE)
Q3 <- quantile(data$`Duration (in seconds)`, 0.75, na.rm = TRUE)
IQR_val <- Q3 - Q1

# Define lower and upper bounds
lower_bound <- Q1 - 1.5 * IQR_val
upper_bound <- Q3 + 1.5 * IQR_val

# Check for outliers based on duration
data$Outlier_RT <- data$`Duration (in seconds)` < lower_bound | data$`Duration (in seconds)` > upper_bound
cat("Number of RT outliers:", sum(data$Outlier_RT, na.rm = TRUE), "\n")


# Create more readable label names for the recognition task

# Recognition of Straattaal words
cols_to_rename_rec <- grep("^Geef voor elk van de onderstaande woorden aan of het straattaal is, Standaard Nederlands is of niet bestaat. - ", names(data))
new_names_rec <- paste0("rec_", sub("^Geef voor elk van de onderstaande woorden aan of het straattaal is, Standaard Nederlands is of niet bestaat. - ", "", names(data)[cols_to_rename_rec]))
names(data)[cols_to_rename_rec] <- new_names_rec

# Use of Straattaal words
cols_to_rename_use <- grep("^Gebruikt u onderstaande woorden\\? - ", names(data))
new_names_use <- paste0("use_", sub("^Gebruikt u onderstaande woorden\\? - ", "", names(data)[cols_to_rename_use]))
names(data)[cols_to_rename_use] <- new_names_use

# Perceived ethnicity names
cols_to_rename_eth <- grep(" - .*achtergrond.*", names(data))
new_names_eth <- paste0("ethnicity_", sub("^(.*?) - .*", "\\1", names(data)[cols_to_rename_eth]))
names(data)[cols_to_rename_eth] <- new_names_eth

# Perceived gender names
cols_to_rename_gender <- grep(" - .*man of een vrouw.*", names(data))
new_names_gender <- paste0("gender_", sub("^(.*?) - .*", "\\1", names(data)[cols_to_rename_gender]))
names(data)[cols_to_rename_gender] <- new_names_gender

# Perceived age names
cols_to_rename_age <- grep(" - .*leeftijd.*", names(data))
new_names_age <- paste0("age_", sub("^(.*?) - .*", "\\1", names(data)[cols_to_rename_age]))
names(data)[cols_to_rename_age] <- new_names_age

# Perceived social class names
cols_to_rename_class <- grep(" - .*klasse.*", names(data))
new_names_class <- paste0("class_", sub("^(.*?) - .*", "\\1", names(data)[cols_to_rename_class]))
names(data)[cols_to_rename_class] <- new_names_class

# Rename demographics labels
new_names <- c(
  "Wat is uw gender? - Selected Choice" = "gender",
  "Wat is uw gender? - Anders, namelijk: - Text" = "gender_other",
  "Wat is uw leeftijd?" = "age",
  "Wat is uw hoogste afgeronde opleiding? - Selected Choice" = "education",
  "Wat is uw hoogste afgeronde opleiding? - Anders, namelijk: - Text" = "education_other",
  "Woont u in de Randstad? - Selected Choice" = "randstad",
  "Woont u in de Randstad? - Ik twijfel, ik woon in - Text" = "randstad_uncertain",
  "Bent u in Nederland geboren? - Selected Choice" = "born_nl",
  "Bent u in Nederland geboren? - Nee, in: - Text" = "born_other",
  "Zijn uw beide ouders in Nederland geboren? - Selected Choice" = "parents_born_nl",
  "Zijn uw beide ouders in Nederland geboren? - Nee, ze zijn namelijk geboren in: - Text" = "parents_born_other",
  "Welke taal of talen beschouwt u als uw moedertaal?" = "mother_tongue",
  "Gebruikt u wel eens Straattaal?" = "straattaal_use"
)
names(data)[names(data) %in% names(new_names)] <- new_names[names(data)[names(data) %in% names(new_names)]]

# Rename Likert labels
data <- as.data.frame(lapply(data, function(x) {
  sub("^([0-9]+)\\..*", "\\1", x)
}), stringsAsFactors = FALSE)

# Add NA to all empty cells
data[] <- lapply(data, function(x) { x[x == ""] <- NA; x })

# Save cleaned data to file
write.csv(data, "data/cleaned_data_pretest.csv", row.names = FALSE)
