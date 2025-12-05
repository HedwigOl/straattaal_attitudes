import sys
import ast
import csv
import pandas as pd

def create_prompt_csv(stimuli_csv: str, prompts_templates: str, stimuli_name: str, meaning_names: list, 
                      prompt_name: str, output_file: str):
    """
    Replace # in prompts with stimuli and combine in a CSV file with Standard Dutch equivalents of the words.
    """

    # Read CSV file with prompt templates and stimuli
    stimuli_df = pd.read_csv(stimuli_csv,       sep=';', encoding='latin1')
    prompts_df = pd.read_csv(prompts_templates, sep=';', encoding='latin1')

    # Check for the existence of the columns in the files
    if stimuli_name not in stimuli_df.columns:
        raise ValueError(f"Stimuli column '{stimuli_name}' not found in stimuli file")
    if prompt_name not in prompts_df.columns:
        raise ValueError(f"Prompt column '{prompt_name}' not found in prompt file")
    for column in meaning_names:
        if column not in stimuli_df.columns:
            raise ValueError(f"Meaning column '{column}' not found in stimuli file")

    output_rows = []

    # Loop through prompts and stimuli and make all possible combinations
    for prompt in prompts_df[prompt_name]:
        for _, stim_row in stimuli_df.iterrows():
            new_prompt = prompt.replace('#', str(stim_row[stimuli_name]))

            # Combine the meanings in one column
            combined_meaning = ', '.join(
                str(stim_row[col]) for col in meaning_names if pd.notna(stim_row[col]) and str(stim_row[col]).strip() != ''
            )

            row = {
                'word'   : str(stim_row[stimuli_name]),
                'prompt' : new_prompt,
                'meaning': combined_meaning
            }

            output_rows.append(row)

    # Save to csv file
    output_df = pd.DataFrame(output_rows)
    output_df.to_csv(output_file, index=False, sep=';', quoting=csv.QUOTE_NONE, escapechar='\\')

if __name__ == "__main__":
    if len(sys.argv) != 7:
        print("Usage: python prompt_creation.py <stimuli_file> <prompt_file>"
              "<stimuli_column> <meaning_columns> <prompt_column> <output name>")
        sys.exit(1)

    input_file_stimuli = sys.argv[1] # CSV file with stimuli
    input_file_prompts = sys.argv[2] # CSV file with the prompts with spaces for the stimuli
    stimuli_column     = sys.argv[3] # Name of the column with stimuli
    meaning_columns    = ast.literal_eval(sys.argv[4]) # List of the columns with the meaning of the stimuli
    prompt_column      = sys.argv[5] # Name of the column with prompts
    output_file        = sys.argv[6] # Name of the file where created prompts will be saved

    create_prompt_csv(input_file_stimuli, input_file_prompts, stimuli_column, meaning_columns,
                      prompt_column, output_file)
