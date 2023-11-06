import sliter_ruleengine
import baseline_ruleengine
from glob import glob

OUTPUT_BASELINE_FILE = "output_baseline.csv"
OUTPUT_SLITER_FILE = "output_sliter.csv"
LOG_BASELINE_FILE = "log_baseline.csv"
LOG_SLITER_FILE = "log_sliter.csv"

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

    make_csv(OUTPUT_BASELINE_FILE, ["REPO"] + baseline_ruleengine.SMELL_NAMES)
    make_csv(OUTPUT_SLITER_FILE, ["REPO"] + sliter_ruleengine.SMELL_NAMES)
    make_csv(LOG_BASELINE_FILE, baseline_ruleengine.LOG_COLUMNS)
    make_csv(LOG_SLITER_FILE, sliter_ruleengine.LOG_COLUMNS)

    for dir in directories:
        print(dir)
        sliter_RE = sliter_ruleengine.SLiTer_RuleEngine(dir)
        baseline_RE = baseline_ruleengine.Baseline_RuleEngine(dir)

        sliter_RE.get_smells()
        baseline_RE.get_smells()

        write_csv_line(OUTPUT_SLITER_FILE, sliter_RE.make_results())
        write_csv_line(OUTPUT_BASELINE_FILE, baseline_RE.make_results())

        for line in sliter_RE.make_logs():
            write_csv_line(LOG_SLITER_FILE, line)
        for line in baseline_RE.make_logs():
            write_csv_line(LOG_BASELINE_FILE, line)

        print()
    
if __name__ == "__main__":
    main()
