import tfparse
from glob import glob
from os.path import join

BAD_COMMENT_WORDS = {"bug", "hack", "fixme", "later", "todo"}

def get_suspicious_comments(path: str) -> list[int]:
    line_numbers = []
    in_multiline_comment = False

    terraform_files = glob(join(path, "*.tf"))
    for filename in terraform_files:
        with open(filename) as f:
            lines = f.readlines()

            for i, line in enumerate(lines):
                comment = ""

                if in_multiline_comment:
                    end_comment = line.find("*/")

                    if end_comment != -1:
                        comment = line[:end_comment].lower()
                        in_multiline_comment = False
                    else:
                        comment = line.lower()
                else:
                    start_comment = line.find("/*") # Test for start of multi line comment
                    if start_comment != -1:
                        in_multiline_comment = True
                    else:
                        start_comment = line.find("#")
                        if start_comment == -1:
                            start_comment = line.find("//") # Both '#' and '//' start single line comments
                        
                    if start_comment != -1:
                        comment = line[start_comment:].lower()
            
                for word in BAD_COMMENT_WORDS:
                    if word in comment:
                        line_numbers.append({
                            "line_number": i + 1, # enumerate starts at 0, so we save i + 1
                            "file": filename
                        })
                        continue
        
    return line_numbers

def _get_all_inner_attributes(resource) -> list:
    attributes = []

    if isinstance(resource, dict):
        for key, value in resource.items():
            if key != "__tfmeta":
                attributes += _get_all_inner_attributes(value)
    elif isinstance(resource, list):
        for value in resource:
            attributes += _get_all_inner_attributes(value)
    else:
        attributes.append(resource)
    
    return attributes

def _get_all_attributes(parsed):
    attributes = []

    for resource_list in parsed.values():
        for resource in resource_list:
            resource_attributes = {"__tfmeta": resource["__tfmeta"], 
                                   "attributes": _get_all_inner_attributes(resource)}
            attributes.append(resource_attributes)

    return attributes

def get_HTTP_without_TLS(path: str) -> list[int]:
    parsed = tfparse.load_from_path(path)

    attributes = _get_all_attributes(parsed)

    # DEBUG:
    # for i in attributes:
    #     print(f"Path: {i['__tfmeta']['path']}")
    #     print(f"Lines: {i['__tfmeta']['line_start']} - {i['__tfmeta']['line_end']}")
    #     for j in i["attributes"]:
    #         print(j)
    #     print()
    
    line_numbers = []
    for att in attributes:
        for s in att["attributes"]:
            if ("http" in s) and (not "https" in s):
                line_numbers.append({
                    "line_number": att["__tfparse"]["line_start"],
                    "file": att["__tfparse"]["filename"]
                    })

    return line_numbers


