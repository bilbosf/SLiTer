# Terraform SLIC

This is a static analysis tool to detect security smells in Terraform scripts. It is based on A. Rahman, C. Parnin and L. Williams' Security Linter for Infrastructure as Code scripts (SLIC) tool introduced in the article "The Seven Sins: Security Smells in Infrastructure as Code Scripts", available in [IEEE](https://ieeexplore.ieee.org/document/8812041). The original SLIC is meant for Puppet scripts, and this version aims to port the functionality to Terraform scripts, while also making some improvements.

The 7 Security smells that this tool aims to detect, as described by the original authors, are the following:

1. **Admin by default:** Specifying default users as administrative users, violating the "principle of least privilege".
2. **Empy password:** Using a string of length zero for a password, which makes it very easy to guess. This is different from using no passwords.
3. **Hard-coded secret:** Leaving sensitive information, such as user names, passwords and private keys, hard-coded in IaC scripts.
4. **Invalid IP address binding:** Assigning the address 0.0.0.0 for a service, server or instance. This may cause security problems by exposing the service to every possible network.
5. **Suspicious comment:** Putting information in comments about the presence of missing functionality or other problems with the system. The use of keywords like "TODO", "FIXME" and "HACK" are indicative of this smell.
6. **Use of HTTP without TLS:** Using pure HTTP with no TLS. HTTP is susceptible to man-in-the-middle attacks due to lack of in-transit encryption.
7. **Use of weak cryptography algorithms:** Using algorithms such as MD4, MD5 and SHA-1 for encryption purposes.

## Architecture
The Python scripts are all in the `src/` directory. The `src/main.py` file is the program entrypoint and is also responsible for iterating over the test directories and creating the output files. The `src/baseline_sniffer.py` file contains the `BaselineSniffer` class, which aims to closely follow the rules defined in the original SLIC program for comparison purposes. The `src/sniffer.py` file contains the `Sniffer` class, which contains the changes made to improve the performance compared to the baseline. The `src/hclparser.py` file contains the `HCLParser` class, which uses [docker-py](https://github.com/docker/docker-py) and [hcl2json](https://github.com/tmccombs/hcl2json) to parse the Terraform files into Python dictionaries.

The program iterates over all subdirectories in the `terraform/` directory to create its output CSV files.

## Output
The program outputs 4 CSV files:

- `output_baseline.csv`: How many occurrences of each smell were found in each test repository by the baseline sniffer.
- `output_sniffer.csv`: How many occurrences of each smell were found in each test repository by the modified sniffer.
- `log_baseline.csv`: Where each smell found by the baseline sniffer is located.
- `log_sniffer.csv`:  Where each smell found by the modified sniffer is located.

## Test repositories

Terraform configuration files have been aggregated from several different sources in order to test this project. The test directories are present in the `terraform/` directory, along with a README file detailing the sources and the specific commits that were pulled.
