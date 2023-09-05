import sniffer
from glob import glob

def main():
    path = "./terraform/"
    directories = glob(path + "*/")

    for dir in directories:
        print(dir)
        sniff = sniffer.Sniffer(dir)
        sniff.get_smells()

        print(f"Admin by default: {len(sniff.admin_by_default)}")
        print(f"Empty password: {len(sniff.empty_password)}")
        print(f"Invalid IP Binding: {len(sniff.invalid_IP_binding)}")
        print(f"Suspicious comments: {len(sniff.suspicious_comments)}")
        print(f"HTTP without TLS: {len(sniff.HTTP_without_TLS)}")
        print(f"Weak crypto. algo.: {len(sniff.weak_crypto_algo)}")

        print()
    
if __name__ == "__main__":
    main()
