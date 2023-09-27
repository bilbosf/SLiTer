import sniffer
from glob import glob

OUTPUT_FILE = "output.csv"

def make_csv():
    with open(OUTPUT_FILE, "w") as f:
        f.write("REPO, ADMIN BY DEFAULT, EMPTY PASSWORD, HARDCODED SECRET, INVALID IP, SUSPICIOUS COMMENT, HTTP WITHOUT TLS, WEAK CRYPTO\n")

def main():
    path = "./terraform/"
    directories = glob(path + "*/")
    make_csv()

    for dir in directories:
        print(dir)
        sniff = sniffer.Sniffer(dir)
        sniff.get_smells()

        line = [dir]
        line.append(str(len(sniff.admin_by_default)))
        line.append(str(len(sniff.empty_password)))
        line.append(str(len(sniff.hard_coded_secret)))
        line.append(str(len(sniff.invalid_IP_binding)))
        line.append(str(len(sniff.suspicious_comments)))
        line.append(str(len(sniff.HTTP_without_TLS)))
        line.append(str(len(sniff.weak_crypto_algo)))

        with open(OUTPUT_FILE, "a") as f:
            f.write(", ".join(line))
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
