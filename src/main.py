import sniffer
import baseline_sniffer
from glob import glob

OUTPUT_BASELINE_FILE = "output_baseline.csv"
OUTPUT_SNIFFER_FILE = "output_sniffer.csv"

def make_csv(smells: list[str], file: str):
    items = ["REPO"] + smells
    items = [x.upper() for x in items]
    with open(file, "w") as f:
        f.write(", ".join(items) + "\n")

def main():
    path = "./terraform/"
    directories = glob(path + "*/")

    make_csv(baseline_sniffer.SMELL_NAMES, OUTPUT_BASELINE_FILE)
    make_csv(sniffer.SMELL_NAMES, OUTPUT_SNIFFER_FILE)

    for dir in directories:
        print(dir)
        sniff = sniffer.Sniffer(dir)
        baseline_sniff = baseline_sniffer.Baseline_Sniffer(dir)

        sniff.get_smells()
        baseline_sniff.get_smells()

        with open(OUTPUT_SNIFFER_FILE, "a") as f:
            f.write(", ".join(sniff.make_results()))
            f.write("\n")

        with open(OUTPUT_BASELINE_FILE, "a") as f:
            f.write(", ".join(baseline_sniff.make_results()))
            f.write("\n")

        print()
    
if __name__ == "__main__":
    main()
