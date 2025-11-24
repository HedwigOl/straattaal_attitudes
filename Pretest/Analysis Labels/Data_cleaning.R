# Read in the raw csv file
raw_data <- read.csv("pretest_labels.csv", 
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

# Check mean and median
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

# Check for outliers
data$Outlier_RT <- data$`Duration (in seconds)` < lower_bound | data$`Duration (in seconds)` > upper_bound
cat("Number of RT outliers:", sum(data$Outlier_RT, na.rm = TRUE), "\n")

# Create clearer names for elicitation questions
names(data) <- sub("Hoe zou de gemiddelde Nederlander.*fittie.*\\?+", "label_stWords", names(data))
names(data) <- sub("Hoe zou de gemiddelde Nederlander.*huis.*\\?+", "label_nlWords", names(data))
names(data) <- sub("Hoe noemt de gemiddelde Nederlander.*Ilias.*\\?+", "label_migNames", names(data))
names(data) <- sub("Hoe noemt de gemiddelde Nederlander.*Thomas.*\\?+", "label_nlNames", names(data))

# Lowercase all input names
cols_to_lower <- c("label_stWords", "label_nlWords", "label_migNames", "label_nlNames")

for (col in cols_to_lower) {
  if (col %in% names(data)) {
    data[[col]] <- tolower(data[[col]])
  }
}

# Create clearer names for approval questions
question_nl_names  <- "Zou de gemiddelde Nederlander de volgende benamingen gebruiken voor de bevolkingsgroep die wordt geassocieerd met namen als Anne, Esther, Julia, Laura, Martijn, Dennis, Jesse en Thomas\\? - "
question_mig_names <- "Zou de gemiddelde Nederlander de volgende benamingen gebruiken voor de bevolkingsgroep die wordt geassocieerd met namen als Amira, Fatma, Samira, Salma, Mohamed, Ayoub, Murat en Ilias\\? - "
question_st_words  <- "Zou de gemiddelde Nederlander de volgende benamingen gebruiken om te verwijzen naar het soort taal met woorden zoals doekoe, patta, pokoe, waggie, osso, fittie\\? - "
question_nl_words  <- "Zou de gemiddelde Nederlander de volgende benamingen gebruiken om te verwijzen naar het soort taal met woorden zoals liedje, auto, geld, huis, ruzie, schoen\\? - "

cols_nl_names  <- grep(question_nl_names,  names(data))
cols_mig_names <- grep(question_mig_names, names(data))
cols_st_words  <- grep(question_st_words,  names(data))
cols_nl_words  <- grep(question_nl_words,  names(data))

names(data)[cols_nl_names]  <- paste0("nlNames_",  sub(question_nl_names,  "", names(data)[cols_nl_names]))
names(data)[cols_mig_names] <- paste0("migNames_", sub(question_mig_names, "", names(data)[cols_mig_names]))
names(data)[cols_st_words]  <- paste0("stWords_",  sub(question_st_words,  "", names(data)[cols_st_words]))
names(data)[cols_nl_words]  <- paste0("nlWords_",  sub(question_nl_words,  "", names(data)[cols_nl_words]))


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
  "Beschouwt u uzelf als een gebruiker van Straattaal?" = "straattaal_use"
)
names(data)[names(data) %in% names(new_names)] <- new_names[names(data)[names(data) %in% names(new_names)]]

# Add NA to all empty cells
data[] <- lapply(data, function(x) { x[x == ""] <- NA; x })

# Save cleaned data to file
write.csv(data, "data/cleaned_data_pretest_labels.csv", row.names = FALSE)
