#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

repo_dir=$(git rev-parse --show-toplevel) ; readonly repo_dir
script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly script_dir

cd "${repo_dir}"

readonly script_dir_rel=".${script_dir#"${repo_dir}"}"

# values.yaml is repo-owned in full, not merged: it carries the Giant Swarm
# defaults (gsoci registry, controller repository, pinned proxy tag,
# restricted-PSS contexts, resources, team annotation), the Renovate marker for
# the proxy tag, and the `# @schema` annotations the values.schema.json
# generator needs. On an upstream bump, read
# diffs/helm__agentgateway__values.yaml.patch and port any new upstream key
# into this file.
set -x
cp "${script_dir_rel}/values.yaml" ./helm/agentgateway/values.yaml

{ set +x; } 2>/dev/null
