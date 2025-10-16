from wuggy import WuggyGenerator

g = WuggyGenerator()
g.load("orthographic_dutch")

# Input words
words = [
    "appel", "fiets", "bloemen", "regen", "tafel", "stoel", "rivier", "vogel",
    "taart", "muziek", "lampion", "licht", "kantoor", "school", "klappen",
    "vlinder", "wolkjes", "aardbei", "huis", "straat", "boek", "auto", "kaars", "fles"]

pseudo_words = {}

# Generate pseudowords for each word in the list
for word in words:
    pseudo_words[word] = [match["pseudoword"] for match in g.generate_classic([word])]

# Print the pseudowords for all words
for woord, pseudo in pseudo_words.items():
    print(f"{woord}: {', '.join(pseudo)}")
