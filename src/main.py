import tfparse
import sniffer

def main():
    path = "./terraform/babbel-terraform-aws-lambda-with-inline-code/"

    HTTP_without_TLS = sniffer.get_HTTP_without_TLS(path)
    suspicious_comments = sniffer.get_suspicious_comments(path)

    print("HTTP without TLS:")
    for line in HTTP_without_TLS:
        print(f"Line {line['line_number']} @ {line['file']}")
    
    print("Suspicious comments:")
    for line in suspicious_comments:
        print(f"Line {line['line_number']} @ {line['file']}")

    pass
    
if __name__ == "__main__":
    main()
