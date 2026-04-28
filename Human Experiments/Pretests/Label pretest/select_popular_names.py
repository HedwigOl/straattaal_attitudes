import sys

def parse_names_file(filename):
    """
    Read file and create dictionary of name occurences
    """
    boys = {}
    girls = {}
    current_section = None

    with open(filename, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            if line.lower() == "jongens":
                current_section = "boys"
                continue
            elif line.lower() == "meisjes":
                current_section = "girls"
                continue

            parts = line.split("\t")
            if len(parts) == 3:
                _, name, count = parts
                try:
                    count = int(count)
                except ValueError:
                    continue

                if current_section == "boys":
                    boys[name] = boys.get(name, 0) + count
                elif current_section == "girls":
                    girls[name] = girls.get(name, 0) + count

    return boys, girls

def print_top_10(dictionary, title):
    """
    Print the ten most popular names
    """
    print(f"\nTop 10 {title}:")
    top10 = sorted(dictionary.items(), key=lambda x: x[1], reverse=True)[:10]
    for i, (name, count) in enumerate(top10, start=1):
        print(f"{i:2}. {name:15} {count}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python select_popular_names.py <filename>")
        sys.exit(1)

    filename = sys.argv[1]     # File with the occurences of names from De Voornamenbank

    boys, girls = parse_names_file(filename)

    print_top_10(boys, "Boys")
    print_top_10(girls, "Girls")
