import tfparse
import sniffer

def main():
    path = "./terraform/"

    sniffer.get_HTTP_without_TLS(path)
    pass
    
if __name__ == "__main__":
    main()
