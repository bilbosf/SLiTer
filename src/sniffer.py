import baseline_sniffer

SMELL_NAMES = baseline_sniffer.SMELL_NAMES
LOG_COLUMNS = baseline_sniffer.LOG_COLUMNS

class Sniffer(baseline_sniffer.Baseline_Sniffer):
    def __init__(self, path) -> None:
        super().__init__(path)

        self.BAD_COMMENT_WORDS = {"bug", "hack", "fixme", "later", "todo", "ticket", "to-do", "launchpad", "debug"}
        self.BAD_CRYPTO_ALGO_WORDS = {"md4", "md5", "rc4", "rc2", "blowfish", "sha1", "sha-1", "sha_1"}
        self.PASSWORD_WORDS = {"password", "pass", "pwd"}
        self.PRIVATE_KEY_WORDS = {"crypt", "secret", "cert", "ssh", "md5", "rsa", "ssl", "dsa"}
