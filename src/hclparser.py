import docker
from glob import glob
from os.path import join, abspath, basename
import json
import re
from bisect import bisect_left

class HCLParser():
    def __init__(self, path: str) -> None:
        self.path = abspath(path)
        self.client = docker.from_env()
        self.parsed = {}
        self.comments = {}

    def parse_comments(self, file):
        pattern = r"""
            (?P<literal> (\"([^\"\n])*\")+) |
            (?P<single> (//|\#)(?P<single_content>.*)?$) |
            (?P<multi> /\*(?P<multi_content>(.|\n)*?)?\*/) |
        """

        compiled = re.compile(pattern, re.VERBOSE | re.MULTILINE)

        code = ""
        with open(file, "r") as f:
            code = f.read()

        lines_indexes = []
        for match in re.finditer(r"$", code, re.M):
            lines_indexes.append(match.start())

        for match in compiled.finditer(code):
            kind = match.lastgroup

            start_character = match.start()
            line_no = bisect_left(lines_indexes, start_character) + 1
            location = f"{basename(file)}[{line_no}]"

            if kind == "single":
                comment_content = match.group("single_content")
                self.comments[location] = comment_content
            elif kind == "multi":
                comment_content = match.group("multi_content")
                self.comments[location] = comment_content

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
