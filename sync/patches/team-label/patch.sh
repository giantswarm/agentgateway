#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

repo_dir=$(git rev-parse --show-toplevel) ; readonly repo_dir

cd "${repo_dir}"

# app-build-suite's Giant Swarm validator (C0001: HasTeamLabel) requires the
# team label, read from the Chart annotation, in the chart's
# templates/_helpers.tpl. The 1.x wrapper carried its own helper file for it;
# the flattened chart uses the upstream one, so add the label to the upstream
# common-labels helper. Every resource the chart renders then carries it.
#
# The replacement asserts on the exact upstream text, so the sync fails loudly
# if upstream reworks the helper.
set -x
python3 - <<'PY'
path = "helm/agentgateway/templates/_helpers.tpl"

old = '''app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels | default dict }}'''

new = '''app.kubernetes.io/managed-by: {{ .Release.Service }}
application.giantswarm.io/team: {{ index .Chart.Annotations "io.giantswarm.application.team" | quote }}
{{- with .Values.commonLabels | default dict }}'''

with open(path, encoding="utf-8") as f:
    content = f.read()

if content.count(new) == 1:
    raise SystemExit(0)

if content.count(old) != 1:
    raise SystemExit(
        f"{path}: the upstream agentgateway.labels helper is not what this patch "
        "expects. Re-derive the team-label line against the new upstream text."
    )

with open(path, "w", encoding="utf-8") as f:
    f.write(content.replace(old, new))
PY

{ set +x; } 2>/dev/null
