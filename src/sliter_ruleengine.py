import baseline_ruleengine

SMELL_NAMES = baseline_ruleengine.SMELL_NAMES
LOG_COLUMNS = baseline_ruleengine.LOG_COLUMNS

class SLiTer_RuleEngine(baseline_ruleengine.Baseline_RuleEngine):
    def __init__(self, path) -> None:
        super().__init__(path)

        self.SUSP_COMMENT_WORDS = {"bug", "hack", "fixme", "later", "todo", "ticket", "to-do", "launchpad", "debug", "pending", "missing", "note"}

        self.BAD_CRYPTO_ALGO_WORDS = {"md4", "md5", "rc4", "rc2", "blowfish", "sha1", "sha-1", "sha_1", " des ", "_des_", "-des-"}

        self.PRIVATE_KEY_WORDS = {"crypt", "secret", "cert", "ssh", "md5", "rsa", "ssl", "dsa"}

        self.ADMIN_WORDS = {"adm", "root", "superuser"}

    def test_hard_coded_secret(self, s: str) -> bool:
        latest_key = self.latest_key()
        constant_s = self.remove_variables(s).lower()

        # Terraform's tls_private_key stores keys unencrypted in terraform state and should be
        # avoided in production enviroments.
        if ("resource.tls_private_key" in self.current_key):
            # Only triggering when latest_key == "algorithm" to avoid multiple triggers for single instance
            return (latest_key == "algorithm")

        if len(constant_s) > 0 and latest_key != "description":
            is_secret = self.is_user(latest_key) or self.is_password(latest_key)
            is_secret = is_secret or self.is_pvt_key(latest_key) or ("ssh-rsa" in constant_s)
            return is_secret
        else:
            return False
    
    def test_empty_password(self, s: str) -> bool:
        latest_key = self.latest_key()
        return (self.is_password(latest_key) and s.strip() == "")
    