import baseline_sniffer

SMELL_NAMES = baseline_sniffer.SMELL_NAMES
LOG_COLUMNS = baseline_sniffer.LOG_COLUMNS

class Sniffer(baseline_sniffer.Baseline_Sniffer):
    def __init__(self, path) -> None:
        super().__init__(path)

        self.BAD_COMMENT_WORDS = {"bug", "hack", "fixme", "later", "todo", "ticket", "to-do", "launchpad", "debug"}
        self.BAD_CRYPTO_ALGO_WORDS = {"md4", "md5", "rc4", "rc2", "blowfish", "sha1", "sha-1", "sha_1", " des ", "_des_", "-des-"}
        self.PASSWORD_WORDS = {"password", "pass", "pwd"}
        self.PRIVATE_KEY_WORDS = {"crypt", "secret", "cert", "ssh", "md5", "rsa", "ssl", "dsa"}

    def test_hard_coded_secret(self, s: str) -> bool:
        latest_key = self.latest_key()
        constant_s = self.remove_variables(s).lower()

        # Terraform's tls_private_key stores keys unencrypted in terraform state and should be
        # avoided in production enviroments.
        if ("resource.tls_private_key" in self.current_key) and latest_key == "algorithm":
            # Only triggering when latest_key == "algorithm" to avoid multiple triggers for single instance
            return True

        if len(constant_s) > 0 and latest_key != "description":
            is_secret = self.is_user(latest_key) or self.is_password(latest_key)
            is_secret = is_secret or self.is_pvt_key(latest_key)
            return is_secret
        else:
            return False