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
