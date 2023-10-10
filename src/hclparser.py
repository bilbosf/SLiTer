import docker
from glob import glob
from os.path import join, abspath, basename
import json

class HCLParser():
    def __init__(self, path: str) -> None:
        self.path = abspath(path)
        self.client = docker.from_env()
        self.parsed = {}
        self.comments = {}
        self.in_multiline_comment = False

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

    def parse_comments(self, file):
        with open(file) as f:
            lines = f.readlines()
            for i, line in enumerate(lines):
                comment = self.extract_comment(line)
                if len(comment) > 0:
                    self.comments[f"{basename(file)}[{i+1}]"] = comment

    def parse(self):
        terraform_files = glob(join(self.path, "*.tf"))
        for file in terraform_files:
            self.parse_comments(file)

            filename = basename(file)
            path_in_container = join("terraform/", filename)
            json_out = self.client.containers.run("tmccombs/hcl2json:0.6.0", path_in_container, volumes=[f"{self.path}:/terraform/"])

            dict_out = json.loads(json_out)

            self.parsed[filename] = dict_out
        
        return self.parsed, self.comments
