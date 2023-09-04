import tfparse
import sniffer

def main():
    path = "./terraform/lacework-terraform-aws-iam-role/"

    sniff = sniffer.Sniffer(path)
    sniff.get_smells()

    print("HTTP without TLS:")
    for line in sniff.HTTP_without_TLS:
        print(f"Line {line['line_number']} @ {line['file']}")
    
    print("Suspicious comments:")
    for line in sniff.suspicious_comments:
        print(f"Line {line['line_number']} @ {line['file']}")

    print("Invalid IP binding:")
    for line in sniff.invalid_IP_binding:
        print(f"Line {line['line_number']} @ {line['file']}")

    print("Weak crypto algorithms:")
    for line in sniff.weak_crypto_algo:
        print(f"Line {line['line_number']} @ {line['file']}")

    
if __name__ == "__main__":
    main()
