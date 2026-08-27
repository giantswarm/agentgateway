#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

repo_dir=$(git rev-parse --show-toplevel) ; readonly repo_dir

cd "${repo_dir}"

# The chart label now carries OUR chart version, not the upstream one, and in a
# branch build that version is a long git-replaced string. Upstream's
# `trunc 63 | trimSuffix "-"` can then cut inside a separator and emit a label
# that ends in a non-alphanumeric, which Kubernetes rejects. The install fails
# late and reads like a flake (app-test-suite hangs at "Deploying App CR"), so
# strip every trailing non-alphanumeric instead.
#
# The replacement asserts on the exact upstream text, so the sync fails loudly
# if upstream reworks the helper and the fix can never be lost silently. It is
# done in python rather than as a stored .patch because the repo's
# trailing-whitespace pre-commit hook rewrites .patch files.
set -x
python3 - <<'PY'
path = "helm/agentgateway/templates/_helpers.tpl"

old = '''{{- define "agentgateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}'''

new = '''{{- define "agentgateway.chart" -}}
{{- $chart := printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 }}
{{- regexReplaceAll "[^a-zA-Z0-9]+$" $chart "" }}
{{- end }}'''

with open(path, encoding="utf-8") as f:
    content = f.read()

if content.count(new) == 1:
    raise SystemExit(0)

if content.count(old) != 1:
    raise SystemExit(
        f"{path}: the upstream agentgateway.chart helper is not what this patch "
        "expects. Re-derive the chart-label fix against the new upstream text."
    )

with open(path, "w", encoding="utf-8") as f:
    f.write(content.replace(old, new))
PY

{ set +x; } 2>/dev/null
