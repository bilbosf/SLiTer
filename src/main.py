import sniffer
from glob import glob

OUTPUT_FILE = "output.csv"

def make_csv(smells: list[str]):
    items = ["REPO"] + smells
    items = [x.upper() for x in items]
    with open(OUTPUT_FILE, "w") as f:
        f.write(", ".join(items) + "\n")

def main():
    path = "./terraform/"
    directories = glob(path + "*/")
    make_csv(sniffer.SMELL_NAMES)

    for dir in directories:
        print(dir)
        sniff = sniffer.Sniffer(dir)
        sniff.get_smells()

        with open(OUTPUT_FILE, "a") as f:
            f.write(", ".join(sniff.make_results()))
            f.write("\n")

        # print(f"Admin by default: {len(sniff.admin_by_default)}")
        # print(f"Empty password: {len(sniff.empty_password)}")
        # print(f"Hardcoded secret: {len(sniff.hard_coded_secret)}")
        # print(f"Invalid IP Binding: {len(sniff.invalid_IP_binding)}")
        # print(f"Suspicious comments: {len(sniff.suspicious_comments)}")
        # print(f"HTTP without TLS: {len(sniff.HTTP_without_TLS)}")
        # print(f"Weak crypto. algo.: {len(sniff.weak_crypto_algo)}")

        print()
    
if __name__ == "__main__":
    main()
