# Read cleaned data file
df <- read.csv("cleaned_data_pretest_labels.csv")

# Create tables of the answers to the open-ended questions
table_generation <- function(df, column_name) {
  print(table(df[[column_name]]))
}

table_generation(df, "label_stWords")
table_generation(df, "label_nlWords")
table_generation(df, "label_migNames")
table_generation(df, "label_nlNames")


# Create tables of the responses to the evaluaion task
table_evaluation <- function(string, df) {
  column_names <- grep(string, colnames(df), value = TRUE)
  
  print(
    t(sapply(column_names, function(x) {
      prop.table(table(factor(df[[x]], levels = c("Ja", "Nee", "Ik twijfel"))))
    }))
  )
}

table_evaluation("^stWords", df)
table_evaluation("^nlWords", df)
table_evaluation("^migNames", df)
table_evaluation("^nlNames", df)
