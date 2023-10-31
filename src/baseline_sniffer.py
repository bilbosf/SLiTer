import hclparser
import re

SMELL_NAMES = ["admin_by_default",
                "empty_password",
                "hard_coded_secret",
                "invalid_IP_binding",
                "suspicious_comments",
                "HTTP_without_TLS",
                "weak_crypto_algo"]

LOG_COLUMNS = ["REPO", "SMELL", "LOCATION"]

class Baseline_Sniffer():
    def __init__(self, path) -> None:
        self.path = path

        parser = hclparser.HCLParser(path)
        self.parsed, self.comments = parser.parse()

        self.BAD_COMMENT_WORDS = {"bug", "hack", "fixme", "later", "later2", "todo", "ticket", "to-do", "launchpad"}

        self.BAD_CRYPTO_ALGO_WORDS = {"md5", "sha1", "base64"}

        self.USER_WORDS = {"user"}
        self.NEGATIVE_USER_WORDS = {"provider"}

        self.ADMIN_WORDS = {"admin"}

        self.PASSWORD_WORDS = {"password", "pass", "pwd"}
        self.NEGATIVE_PASSWORD_WORDS = {"provider", "passive"}

        self.PRIVATE_KEY_WORDS = {"key", "crypt", "secret", "certificate", "cert", "ssh_key", "md5", "rsa", "ssl", "dsa", "ssh-rsa"}
        self.NEGATIVE_KEY_WORDS = {"provider"}

        self.smells = dict()
        for s in SMELL_NAMES:
            self.smells[s] = []

        self.current_key = ""

    def make_results(self):
        line = [self.path]
        for smell in SMELL_NAMES:
            line.append(str(len(self.smells[smell])))
        return line
    
    def make_logs(self):
        lines = []
        for smell, occurrence_list in self.smells.items():
            for i in occurrence_list:
                line = [self.path, smell.upper(), i]
                lines.append(line)
        return lines

    def get_smells(self):
        for location, comment in self.comments.items():
            if self.test_suspicious_comment(comment):
                self.smells["suspicious_comments"].append(location)

        for filename in self.parsed.keys():
            self.current_key = filename
            self.visit(self.parsed[filename])

    def visit(self, node):
        if isinstance(node, dict):
            self.visit_dict(node)
        elif isinstance(node, list):
            self.visit_list(node)
        else:
            self.visit_leaf(node)
    
    def visit_dict(self, node):
        for key, value in node.items():
            previous_key = self.current_key
            self.current_key += "." + key
            self.visit(value)
            self.current_key = previous_key

    def visit_list(self, node):
        previous_key = self.current_key
        for i, item in enumerate(node):
            self.current_key = previous_key + f"[{i}]"
            self.visit(item)
    
    def visit_leaf(self, node):
        location = self.current_key

        if isinstance(node, str):
            if self.test_admin_by_default(node):
                self.smells["admin_by_default"].append(location)
            if self.test_empty_password(node):
                self.smells["empty_password"].append(location)
            if self.test_hard_coded_secret(node):
                self.smells["hard_coded_secret"].append(location)
            if self.test_invalid_IP_binding(node):
                self.smells["invalid_IP_binding"].append(location)
            if self.test_HTTP_without_TLS(node):
                self.smells["HTTP_without_TLS"].append(location)
            if self.test_weak_crypto_algo(node):
                self.smells["weak_crypto_algo"].append(location)

    def is_password(self, s: str) -> bool:
        if any(word in s.lower() for word in self.PASSWORD_WORDS):
            if not any(word in s.lower() for word in self.NEGATIVE_PASSWORD_WORDS):
                return True
        return False
    
    def is_user(self, s: str) -> bool:
        if any(word in s.lower() for word in self.USER_WORDS):
            if not any(word in s.lower() for word in self.NEGATIVE_USER_WORDS):
                return True
        return False
    
    def is_admin(self, s: str) -> bool:
        return any(word in s.lower() for word in self.ADMIN_WORDS)

    def is_pvt_key(self, s: str) -> bool:
        if any(word in s.lower() for word in self.PRIVATE_KEY_WORDS):
            if not any(word in s.lower() for word in self.NEGATIVE_KEY_WORDS):
                return True
        return False
    
    def is_constant(self, s: str) -> bool:
        return not "${" in s
    
    def remove_variables(self, s: str) -> str:
        return re.sub(r'\${.*?}', '', s) # Replaces the '${...}' pattern with blank
    
    def latest_key(self) -> str:
        return self.current_key[self.current_key.rfind(".") + 1:]

    def test_admin_by_default(self, s: str) -> bool:
        latest_key = self.latest_key()
        constant_s = self.remove_variables(s).lower()
        return self.is_user(latest_key) and (self.is_admin(constant_s) or self.is_admin(latest_key))
    
    def test_empty_password(self, s: str | None) -> bool:
        latest_key = self.latest_key()
        if self.is_password(latest_key):
            return (len(s) == 0) or (s == " ")
        else:
            return False
    
    def test_hard_coded_secret(self, s: str) -> bool:
        latest_key = self.latest_key()
        constant_s = self.remove_variables(s).lower()
        if len(constant_s) > 0:
            is_secret = self.is_user(latest_key) or self.is_password(latest_key)
            is_secret = is_secret or self.is_pvt_key(latest_key) or self.is_pvt_key(constant_s)
            return is_secret
        else:
            return False

    def test_invalid_IP_binding(self, s: str) -> bool:
        return ("0.0.0.0" in s.lower())
    
    def test_suspicious_comment(self, s: str) -> bool:
        for word in self.BAD_COMMENT_WORDS:
            if word in s.lower() and not "debug" in s.lower():
                return True
        return False
    
    def test_HTTP_without_TLS(self, s: str) -> bool:
        return ("http://" in s.lower())
    
    def test_weak_crypto_algo(self, s: str) -> bool:
        for word in self.BAD_CRYPTO_ALGO_WORDS:
            if word in s.lower():
                return True
        
        return False