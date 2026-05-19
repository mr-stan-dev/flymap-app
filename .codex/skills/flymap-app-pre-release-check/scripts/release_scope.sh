#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git repository" >&2
  exit 1
fi

base_tag="$(git describe --tags --abbrev=0 2>/dev/null || true)"
head_sha="$(git rev-parse --short HEAD)"

if [[ -n "${base_tag}" ]]; then
  base_ref="${base_tag}"
  range="${base_ref}..HEAD"
else
  base_ref="$(git rev-list --max-parents=0 HEAD | tail -n 1)"
  range="${base_ref}..HEAD"
fi

echo "BASE_REF=${base_ref}"
if [[ -n "${base_tag}" ]]; then
  echo "BASE_TAG=${base_tag}"
else
  echo "BASE_TAG="
fi
echo "HEAD_SHA=${head_sha}"
echo "RANGE=${range}"
echo
echo "DIFFSTAT"
git diff --stat "${range}"
echo
echo "CHANGED_FILES"
git diff --name-only "${range}"
