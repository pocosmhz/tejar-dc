#!/usr/bin/env python3
"""Keep the legacy StorageClass parameters during a Ceph CSI Helm upgrade.

Helm passes rendered YAML on stdin. Change only the two added publish-secret
parameters of csi-rbd-sc; preserve every other byte, including Secret manifests.
This intentionally targets the upstream chart's block-style YAML and fails
closed if the expected class or parameter layout changes. Python stdlib only.
"""

import re
import sys


def preserve(manifest):
    documents = re.split(r"(?m)(^---[ \t]*\r?\n)", manifest)
    matched = 0
    for index in range(0, len(documents), 2):
        document = documents[index]
        if not re.search(r"(?m)^kind: StorageClass[ \t]*$", document):
            continue
        if not re.search(r"(?m)^  name: csi-rbd-sc[ \t]*$", document):
            continue
        matched += 1
        if not re.search(r"(?m)^parameters:[ \t]*$", document):
            raise ValueError("csi-rbd-sc parameters layout changed")
        for suffix in ("name", "namespace"):
            pattern = (
                r"(?m)^  csi\.storage\.k8s\.io/controller-publish-secret-"
                + suffix
                + r":[^\r\n]*\r?\n"
            )
            document, count = re.subn(pattern, "", document)
            if count > 1:
                raise ValueError("duplicate controller-publish Secret parameter")
        if "controller-publish-secret-" in document:
            raise ValueError("unrecognized controller-publish Secret parameter layout")
        documents[index] = document
    if matched != 1:
        raise ValueError("expected exactly one csi-rbd-sc StorageClass")
    return "".join(documents)


if __name__ == "__main__":
    try:
        result = preserve(sys.stdin.read())
    except ValueError as error:
        print(f"StorageClass preservation failed: {error}", file=sys.stderr)
        sys.exit(1)
    sys.stdout.write(result)
