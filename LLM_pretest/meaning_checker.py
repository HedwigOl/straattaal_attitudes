import sys
import pandas as pd
import wn         # not supported by newest version of Python, run in 3.11.7

# Download Dutch extension of WordNet if not present
try:
    lexicon = wn.Wordnet(lang='nl')
except:
    wn.download('omw-nl:1.4')
    lexicon = wn.Wordnet(lang='nl')

def get_synonyms(word: str):
    """
    Returns a set of synonyms for a word using WordNet.
    """
    synonyms = {word.lower()}

    synsets = lexicon.synsets(word.lower())
    for syn in synsets:
        for lemma in syn.lemmas():
            synonyms.add(lemma.lower())

    return synonyms


def check_response(file_name: str, output_file: str):
    """
    Creates CSV file with columns on the presence of the plain meaning words 
    and the presence on the meaning with WordNet synonyms added.
    """
    df = pd.read_csv(file_name, sep="\t", encoding="latin1")

    def build_keywords(meanings):
        """
        Create a list of meaning keywords given 
        """
        return [word.strip().lower() for word in str(meanings).split(",") if word.strip()]

    def build_keywords_wordnet(meanings):
        """
        Create a list of meaning keywords including WordNet synonyms
        """
        keywords = set()
        for word in str(meanings).split(","):
            word = word.strip().lower()
            for synonym in get_synonyms(word):
                keywords.add(synonym.lower())
        return list(keywords)

    def check_presence(row, meaning_column):
        """
        Check if meaning keywords are present in response
        """
        word = str(row["word"]).lower().strip()
        response = str(row["response"]).lower()

        # temporarily remove the streetword so it doesn't match itself (f.e. voetoe and voet)
        response_clean = response.replace(word, "")

        # Check if one of the keywords is in the response
        for keyword in row[meaning_column]:
            if keyword and keyword in response_clean:
                return 1
        return 0

    # Add the meaning lists as columns to the dataframe
    df["keywords"]         = df["meaning"].apply(build_keywords)
    df["keywords_wordnet"] = df["meaning"].apply(build_keywords_wordnet)

    # Complete the check
    df["check_meaning"]         = df.apply(lambda r: check_presence(r, "keywords"),         axis=1)
    df["check_meaning_WordNet"] = df.apply(lambda r: check_presence(r, "keywords_wordnet"), axis=1)

    # Save output to output CSV
    df.to_csv(output_file, sep=";", index=False, encoding="latin1")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python betekenis_checker.py <response file name> <output name>")
        sys.exit(1)

    input_file      = sys.argv[1]  # CSV file with responses
    output_file     = sys.argv[2]  # Name of the file where all information will be saved

    check_response(input_file, output_file)

