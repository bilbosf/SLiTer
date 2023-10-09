import sniffer
import baseline_sniffer
from glob import glob

OUTPUT_BASELINE_FILE = "output_baseline.csv"
OUTPUT_SNIFFER_FILE = "output_sniffer.csv"
LOG_BASELINE_FILE = "log_baseline.csv"
LOG_SNIFFER_FILE = "log_sniffer.csv"

def make_csv(file: str, columns: list[str]):
    items = [x.upper() for x in columns]
    with open(file, "w") as f:
        f.write(", ".join(items) + "\n")

def write_csv_line(file: str, line: list[str]):
     with open(file, "a") as f:
            f.write(", ".join(line))
            f.write("\n")

def main():
    path = "./terraform/"
    directories = glob(path + "*/")

    make_csv(OUTPUT_BASELINE_FILE, ["REPO"] + baseline_sniffer.SMELL_NAMES)
    make_csv(OUTPUT_SNIFFER_FILE, ["REPO"] + sniffer.SMELL_NAMES)
    make_csv(LOG_BASELINE_FILE, baseline_sniffer.LOG_COLUMNS)
    make_csv(LOG_SNIFFER_FILE, sniffer.LOG_COLUMNS)

    for dir in directories:
        print(dir)
        sniff = sniffer.Sniffer(dir)
        baseline_sniff = baseline_sniffer.Baseline_Sniffer(dir)

        sniff.get_smells()
        baseline_sniff.get_smells()

        write_csv_line(OUTPUT_SNIFFER_FILE, sniff.make_results())
        write_csv_line(OUTPUT_BASELINE_FILE, baseline_sniff.make_results())

        for line in sniff.make_logs():
            write_csv_line(LOG_SNIFFER_FILE, line)
        for line in baseline_sniff.make_logs():
            write_csv_line(LOG_BASELINE_FILE, line)

        print()
    
if __name__ == "__main__":
    main()
