import sys
import csv
import random
import pandas as pd
from itertools import product

def create_prompt_csv(prompts_csv: str, words_csv: str, names_csv: str, output_file: str):
    """
    Add words and names to prompt templates and save in a CSV file.
    """
    # Read CSV files with prompts, words and names
    prompts_df = pd.read_csv(prompts_csv, sep=';', encoding='latin1')
    words_df   = pd.read_csv(words_csv,   sep=';', encoding='latin1')
    names_df   = pd.read_csv(names_csv,   sep=';', encoding='latin1')

    # Split names into ones associated with and without individuals with a migration background
    mig_names = names_df[names_df['ethnicity'] == 'MIG']
    nl_names  = names_df[names_df['ethnicity'] == 'NL' ]

    words_list = words_df['words'].tolist() 

    name_pairs = []

    for gender in ['m', 'f']:
        mig_gender = mig_names[mig_names['gender'] == gender]
        nl_gender  = nl_names[nl_names['gender'] == gender]
    
        # Create all possible pairs of NL-MIG names with same gender (using cartesian product)
        for mig_name, nl_name in product(mig_gender['name'], nl_gender['name']):
            name_pairs.append({
                'name1'     : mig_name,
                'ethnicity1': 'MIG',
                'name2'     : nl_name,
                'ethnicity2': 'NL',
                'gender'    : gender
            })

    # Convert wordpairs to data frame
    name_pairs_df = pd.DataFrame(name_pairs)

    all_prompts_rows = []

    for prompt_index, prompt_row in prompts_df.iterrows():

        prompt_text      = prompt_row['prompt']
        group_membership = prompt_row['group_membership']
        label_present    = prompt_row['labels']
    
        for _, pair_row in name_pairs_df.iterrows():

            # Randomize order of the two names
            if random.random() < 0.5:
                name1 = pair_row['name1']
                eth1  = pair_row['ethnicity1']
                name2 = pair_row['name2']
            else:
                name1 = pair_row['name2']
                eth1  = pair_row['ethnicity2']
                name2 = pair_row['name1']
        
            gender = pair_row['gender']
        
            # Randomize order of words and format nicely
            random.shuffle(words_list)
            words_string = ", ".join(words_list)

            # Create new prompt with the names added
            new_prompt = prompt_text.replace("NAME1", name1).replace("NAME2", name2).replace("WORDS", words_string)
        
            all_prompts_rows.append({
                "prompt"    : new_prompt,
                "name1"     : name1,
                "ethnicity1": eth1,
                "name2"     : name2,
                "gender"    : gender,
                "prompt_nr" : prompt_index,
                "group"     : group_membership,
                "labels"    : label_present
        })

    # Convert to df and save as CSV file
    output_df = pd.DataFrame(all_prompts_rows)
    output_df.to_csv(output_file, index=False, sep=';', quoting=csv.QUOTE_MINIMAL)

def create_prompt_csv_sep(prompts_csv: str, words_csv: str, names_csv: str, output_file: str):
    """
    Add words and names to prompt templates and save in a CSV file.
    """

    # Read CSV files with prompts, words and names
    prompts_df = pd.read_csv(prompts_csv, sep=';', encoding='utf-8-sig')
    words_df   = pd.read_csv(words_csv,   sep=';', encoding='utf-8-sig')
    names_df   = pd.read_csv(names_csv,   sep=';', encoding='latin1')

    all_prompts_rows = []

    # For the name combinations and orders, create prompts for each word seperately
    for _, name_row in names_df.iterrows():

        # Extract name combination and order from name file
        name1     = name_row['name1']
        name2     = name_row['name2']
        eth1      = name_row['ethnicity1']
        gender    = name_row['gender']
        prompt_id = name_row['prompt_nr']

        for _, word_row in words_df.iterrows():

            word = word_row['words']
            prompt_text = prompts_df.iloc[prompt_id]['prompt']

            # Add names and word to prompt template to create new prompt
            new_prompt = prompt_text.replace("NAME1", name1).replace("NAME2", name2).replace("WORD", word)

            all_prompts_rows.append({
                "prompt"     : new_prompt,
                "name1"      : name1,
                "ethnicity1" : eth1,
                "name2"      : name2,
                "gender"     : gender,
                "prompt_nr"  : prompt_id
            })

    # Convert to df and save as CSV file
    output_df = pd.DataFrame(all_prompts_rows)
    output_df.to_csv(output_file, index=False, sep=';', quoting=csv.QUOTE_MINIMAL)

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: python create_llm-wat_prompts.py <input_file_prompts> <input_file_words>"
              "<input_file_names> <output_file_name> <seperated?>")
        sys.exit(1)

    input_file_prompts = sys.argv[1] # CSV file with prompts
    input_file_words   = sys.argv[2] # CSV file with words
    input_file_names   = sys.argv[3] # CSV file with names, including information about gender and ethnicity
    output_file        = sys.argv[4] # Name of the file where created prompts will be saved
    seperated          = sys.argv[5] # Bool whether seperate prompts for each word are to be created

    if seperated.lower() == 'true':
        create_prompt_csv_sep(input_file_prompts, input_file_words, input_file_names, output_file)
    else:
        create_prompt_csv(input_file_prompts, input_file_words, input_file_names, output_file)
