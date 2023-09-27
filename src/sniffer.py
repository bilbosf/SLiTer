import tfparse
from glob import glob
from os.path import join

class Sniffer:
    def __init__(self, path) -> None:
        self.path = path
        self.parsed = tfparse.load_from_path(path)

        self.BAD_COMMENT_WORDS = {"bug", "hack", "fixme", "later", "todo", "ticket", "to-do", "launchpad", "debug"}
        self.BAD_CRYPTO_ALGO_WORDS = {"md5", "sha1", "sha-1", "sha_1"}
        self.PASSWORD_WORDS = {"password", "pass", "pwd"}
        self.PRIVATE_KEY_WORDS = {"crypt", "secret", "cert", "ssh", "md5", "rsa", "ssl", "dsa"}

        self.smells = dict()
        self.admin_by_default    = []
        self.empty_password      = []
        self.hard_coded_secret   = []
        self.invalid_IP_binding  = []
        self.suspicious_comments = []
        self.HTTP_without_TLS    = []
        self.weak_crypto_algo    = []

        self.in_multiline_comment = False

        self.current_key = ""
        self.current_top_level_resource = None

    def extract_comment(self, line):
        if self.in_multiline_comment:
            if "*/" in line:
                self.in_multiline_comment = False
                return line[:line.find("*/")]
            else:
                return line
        else:
            if "/*" in line:
                if "*/" in line:
                    return line[line.find("/*") + 2 : line.find("*/")]
                else:
                    self.in_multiline_comment = True
                    return line[line.find("/*") + 2 :]
            elif "#" in line:
                return line[line.find("#") + 2 :]
            elif "//" in line:
                return line[line.find("//") + 2 :]
                
        return ""

    def get_suspicious_comments(self, filename, lines):
        for i, line in enumerate(lines):
            comment = self.extract_comment(line).lower()
        
            for word in self.BAD_COMMENT_WORDS:
                if word in comment and not "debug" in comment:
                    self.suspicious_comments.append({
                        "line_number": i + 1, # enumerate starts at 0, so we save i + 1
                        "file": filename[filename.rfind("/"):], # Only the file name, not including directories
                    })
                    break

    def get_smells(self):
        # First parse raw text files for suspicious comments
        terraform_files = glob(join(self.path, "*.tf"))
        for filename in terraform_files:
            with open(filename) as f:
                lines = f.readlines()
                self.get_suspicious_comments(filename, lines)

        # Then use tfparse to detect other smells
        for resource_list in self.parsed.values():
            for resource in resource_list:
                self.current_top_level_resource = resource
                self.visit(resource)

    def visit(self, node):
        if isinstance(node, dict):
            self.visit_dict(node)
        elif isinstance(node, list):
            self.visit_list(node)
        else:
            self.visit_leaf(node)
    
    def visit_dict(self, node):
        for key, value in node.items():
            if key != "__tfmeta":
                previous_key = self.current_key
                self.current_key += key
                self.visit(value)
                self.current_key = previous_key
    
    def visit_list(self, node):
        for i in node:
            self.visit(i)
    
    def visit_leaf(self, node):
        location = { 
            "line_number": self.current_top_level_resource["__tfmeta"]["line_start"], 
            "file": self.current_top_level_resource["__tfmeta"]["filename"],
        }

        if isinstance(node, str):
            if self.test_admin_by_default(node):
                self.admin_by_default.append(location)
            if self.test_empty_password(node):
                self.empty_password.append(location)
            if self.test_hard_coded_secret(node):
                self.hard_coded_secret.append(location)
            if self.test_invalid_IP_binding(node):
                self.invalid_IP_binding.append(location)
            if self.test_HTTP_without_TLS(node):
                self.HTTP_without_TLS.append(location)
            if self.test_weak_crypto_algo(node):
                self.weak_crypto_algo.append(location)
        elif node is None: # We can also test for empty password if the value is None
            if self.test_empty_password(node):
                self.empty_password.append(location)

    def is_password(self, s: str) -> bool:
        for word in self.PASSWORD_WORDS:
            if word in s.lower():
                return True
        return False
    
    def is_user(self, s: str) -> bool:
        return ("user" in s.lower())
    
    def is_admin(self, s: str) -> bool:
        return ("admin" in s.lower())

    def is_pvt_key(self, s: str) -> bool:
        for word in self.PRIVATE_KEY_WORDS:
            if word in s.lower():
                return True
        return False

    def test_admin_by_default(self, s: str) -> bool:
        return self.is_user(self.current_key) and (self.is_admin(s) or self.is_admin(self.current_key))
    
    def test_empty_password(self, s: str | None) -> bool:
        if self.is_password(self.current_key):
            return (s is None) or (len(s) == 0) or (s == " ")
        else:
            return False
    
    def test_hard_coded_secret(self, s: str) -> bool:
        if len(s) > 0:
            is_secret = self.is_user(self.current_key) or self.is_password(self.current_key)
            is_secret = is_secret or self.is_pvt_key(self.current_key) or self.is_pvt_key(s)
            return is_secret
        else:
            return False

    def test_invalid_IP_binding(self, s: str) -> bool:
        return ("0.0.0.0" in s.lower())
    
    def test_HTTP_without_TLS(self, s: str) -> bool:
        return ("http:" in s.lower())
    
    def test_weak_crypto_algo(self, s: str) -> bool:
        for word in self.BAD_CRYPTO_ALGO_WORDS:
            if word in s:
                return True
        
        return False
