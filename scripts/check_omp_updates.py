#!/usr/bin/env python3
"""check upstream LLVM tags and detect new omp releases needed."""

import argparse
import json
import os
import re
import sys

try:
    from urllib.parse import urlencode
    from urllib.request import Request, urlopen
except ImportError:
    from urllib import urlencode
    from urllib2 import Request, urlopen

TAG_RE = re.compile(r"^llvmorg-(\d+)\.(\d+)\.(\d+)$")


def parse_versions_env(path):
    values = {}
    with open(path, encoding="utf-8") as f:
        for raw in f:
            line = raw.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip()
    return values


def list_llvm_tags(max_pages=5, per_page=100):
    tags = []
    for page in range(1, max_pages + 1):
        params = urlencode({"per_page": per_page, "page": page})
        url = "https://api.github.com/repos/llvm/llvm-project/tags?%s" % params
        req = Request(
            url,
            headers={
                "Accept": "application/vnd.github+json",
                "User-Agent": "omp-version-watch",
            },
        )
        resp = urlopen(req, timeout=30)
        batch = json.loads(resp.read().decode("utf-8"))
        if not batch:
            break
        tags.extend(item.get("name", "") for item in batch)
    return tags


def find_latest_patch(tags, tracked_minor):
    parts = tracked_minor.split(".", 1)
    if len(parts) != 2:
        raise ValueError("TRACKED_LLVM_MINOR must be 'major.minor', got: %s" % tracked_minor)
    major, minor = int(parts[0]), int(parts[1])

    best = None
    for tag in tags:
        match = TAG_RE.match(tag)
        if not match:
            continue
        m_major, m_minor, m_patch = [int(x) for x in match.groups()]
        if m_major != major or m_minor != minor:
            continue
        candidate = (m_major, m_minor, m_patch)
        if best is None or candidate > best:
            best = candidate

    if best is None:
        raise RuntimeError("no llvm tags found for TRACKED_LLVM_MINOR=%s" % tracked_minor)
    return "%d.%d.%d" % best


def emit_output(output_path, values):
    lines = ["%s=%s" % (k, v) for k, v in values.items()]
    text = "\n".join(lines) + "\n"
    if output_path:
        with open(output_path, "a", encoding="utf-8") as f:
            f.write(text)
    else:
        sys.stdout.write(text)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--versions-file", default="versions.env")
    parser.add_argument("--write", action="store_true")
    parser.add_argument("--github-output", default=os.environ.get("GITHUB_OUTPUT"))
    args = parser.parse_args()

    values = parse_versions_env(args.versions_file)
    current_version = values.get("LLVM_VERSION", "").strip()
    tracked_minor = values.get("TRACKED_LLVM_MINOR", "").strip()

    if not current_version or not tracked_minor:
        raise SystemExit("versions.env must define LLVM_VERSION and TRACKED_LLVM_MINOR")

    tags = list_llvm_tags()
    latest_version = find_latest_patch(tags, tracked_minor)
    needs_update = latest_version != current_version

    if args.write and needs_update:
        # update versions.env in place
        with open(args.versions_file, encoding="utf-8") as f:
            lines = f.read().splitlines()
        out = []
        for line in lines:
            if line.startswith("LLVM_VERSION="):
                out.append("LLVM_VERSION=%s" % latest_version)
            else:
                out.append(line)
        with open(args.versions_file, "w", encoding="utf-8") as f:
            f.write("\n".join(out) + "\n")

    emit_output(
        args.github_output,
        {
            "current_version": current_version,
            "latest_version": latest_version,
            "needs_update": "true" if needs_update else "false",
            "tracked_minor": tracked_minor,
        },
    )


if __name__ == "__main__":
    main()
