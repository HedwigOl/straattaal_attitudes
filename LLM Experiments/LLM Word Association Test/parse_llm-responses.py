import pandas as pd
import sys
import csv

def create_parsed_csv(input_file_responses: str, input_words: str, input_names: str, output_name: str):

    # Read CSV file
    df = pd.read_csv(input_file_responses, sep="\t", engine="python", quoting = csv.QUOTE_ALL)

    # Create dictionary of word and their variety
    words_df = pd.read_csv(input_words, sep=";", encoding="latin-1")
    words = words_df["words"].dropna().tolist()
    word_to_variety = dict(zip(words_df["words"], words_df["variety"]))

    # Create dictionary of names and their ethnicity association
    names_df = pd.read_csv(input_names, sep=";")
    name_to_ethnicity = dict(zip(names_df["name"], names_df["ethnicity"]))

    # Delete answer with multiple combinations for the same word
    #df = df[df["response"].str.count("-") <= 18].copy()

    df["response_split"] = df["response"].str.split("\n")
    df["response_split"] = df["response_split"].apply(lambda lst: [x.strip() for x in lst if x.strip()] if isinstance(lst, list) else [])
    new_df = df.explode("response_split").reset_index(drop=True)
    new_df = new_df[new_df["response_split"].notna()]

    def split_at_even_dashes(line: str):
        dash_indices = [i for i, c in enumerate(line) if c == '-']
    
        if len(dash_indices) < 3:
            return [line] 
    
        parts = []
        start = 0
        # Split at every even dash
        for i, idx in enumerate(dash_indices, start=1):  # i counts from 1
            if i % 2 == 0:  # even dash
                parts.append(line[start:idx])
                start = idx + 1  # start after this dash

        parts.append(line[start:])
    
        return parts

    split_lines = new_df["response_split"].apply(split_at_even_dashes)

    # Explode all parts into separate rows
    new_df = new_df.copy()
    new_df["response_split"] = split_lines
    new_df = new_df.explode("response_split").reset_index(drop=True)
    
    # Extract the word in the line
    def extract_word(line: str):
        matches = [word for word in words if word in line]
        return matches[0] if len(matches) == 1 else None
    
    def extract_word1(line: str):
        for sep in ["-", "|", ":"]:
            if sep in line:
                word = line.split(sep, 1)[0]
                break
        else:
            return None

        first_part = word.strip().strip('"').strip("'").lower()
        if first_part in words:
            return first_part
        else:
            return None

    # Extract name in the line
    def extract_name(row: str):
        if row["name1"] in row["response_split"]:
            return row["name1"]
        if row["name2"] in row["response_split"]:
            return row["name2"]
        return None

    mask = new_df.apply(
        lambda row: (
            (row["name1"] in row["response_split"] or row["name2"] in row["response_split"])
            #and sum(word in row["response_split"] for word in words) == 1
        ),
        axis=1
    )

    filtered_df = new_df[mask].copy()

    # Add new columns of name and word associations
    filtered_df["ass_word"]      = filtered_df["response_split"].apply(extract_word1)
    filtered_df["ass_variety"]   = filtered_df["ass_word"].map(word_to_variety)
    filtered_df["ass_name"]      = filtered_df.apply(extract_name, axis=1)
    filtered_df["ass_ethnicity"] = filtered_df["ass_name"].map(name_to_ethnicity)

    # Add column with 1 if association is stereotypical and 0 otherwise
    filtered_df["stereotypical_ass"] = (((filtered_df["ass_variety"] == "Straattaal") & 
                                         (filtered_df["ass_ethnicity"] == "MIG"))
                                         |
                                         ((filtered_df["ass_variety"] == "Standaard_Nederlands") &
                                          (filtered_df["ass_ethnicity"] == "NL"))
    ).astype(int)

    filtered_df.to_csv(output_name, index=False, sep=';')

def create_parsed_csv_sep(input_file_responses: str, input_words: str, input_names: str, output_name: str):
    
    # Read CSV file
    df = pd.read_csv(input_file_responses, sep="\t")

    # Create dictionary of word and their variety
    words_df = pd.read_csv(input_words, sep=";")
    words = words_df["words"].dropna().tolist()
    word_to_variety = dict(zip(words_df["words"], words_df["variety"]))

    # Create dictionary of names and their ethnicity association
    names_df = pd.read_csv(input_names, sep=";")
    name_to_ethnicity = dict(zip(names_df["name"], names_df["ethnicity"]))

    df["first_line"] = df["response"].str.split("\n").str[0]
    
    # Extract the word evaluated in the prompt
    def extract_word(prompt: str):
        matches = [word for word in words if word in prompt]
        return matches[0] if len(matches) == 1 else None

    # Extract name in the line
    def extract_name(row):
        line = row["first_line"]
        in_name1 = row["name1"] in line
        in_name2 = row["name2"] in line

        if in_name1 and not in_name2:
            return row["name1"]
        elif in_name2 and not in_name1:
            return row["name2"]
        else:
            return None
        
    def valid_row(row):
        name_matches = sum([row["name1"] in row["first_line"], row["name2"] in row["first_line"]])
        return name_matches == 1

    filtered_df = df[df.apply(valid_row, axis=1)].copy()

    # Add association columns
    filtered_df["ass_word"]      = filtered_df["prompt"].apply(extract_word)
    filtered_df["ass_variety"]   = filtered_df["ass_word"].map(word_to_variety)
    filtered_df["ass_name"]      = filtered_df.apply(extract_name, axis=1)
    filtered_df["ass_ethnicity"] = filtered_df["ass_name"].map(name_to_ethnicity)

    # Add column with 1 if association is stereotypical and 0 otherwise
    filtered_df["stereotypical_ass"] = (((filtered_df["ass_variety"] == "Straattaal") & 
                                         (filtered_df["ass_ethnicity"] == "MIG"))
                                         |
                                         ((filtered_df["ass_variety"] == "Standaard_Nederlands") &
                                          (filtered_df["ass_ethnicity"] == "NL"))
    ).astype(int)

    filtered_df.to_csv(output_name, index=False, sep=';')
    
if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: python prompt_creation.py <input_file_prompts> <input_file_words>"
              "<input_file_names> <output_file_name> <seperated?>")
        sys.exit(1)

    input_file_prompts = sys.argv[1] # CSV file with prompts and responses
    input_file_words   = sys.argv[2] # CSV file with words used in the prompts
    input_file_names   = sys.argv[3] # CSV file with names used in the prompts
    output_file        = sys.argv[4] # Name of the file where created prompts will be saved
    seperated          = sys.argv[5] # Bool/int whether words were prompted seperately

    if seperated == '1':
        create_parsed_csv_sep(input_file_prompts, input_file_words, input_file_names, output_file)
    else:
        create_parsed_csv(input_file_prompts, input_file_words, input_file_names, output_file)
