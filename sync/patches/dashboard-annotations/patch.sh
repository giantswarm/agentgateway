#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

repo_dir=$(git rev-parse --show-toplevel) ; readonly repo_dir

cd "${repo_dir}"

# The dashboard ConfigMap accepts extra labels but no annotations, and the Giant
# Swarm observability platform reads the Grafana organization and folder from
# `observability.giantswarm.io/organization` and `.../folder`. Both values are
# display names that contain a space — "Shared Org", "Agent Platform" — and no
# Kubernetes label value admits a space, so they have to be annotations.
# Without them the board lands in the organization's General folder.
#
# Filed upstream as agentgateway#3591. Delete this patch, and the values key it
# reads, at the bump to a release that carries it.
#
# The replacement asserts on the exact upstream text, so the sync fails loudly
# if upstream reworks the ConfigMap.
set -x
python3 - <<'PY'
path = "helm/agentgateway/templates/monitoring.yaml"

old = '''    {{- with .Values.monitoring.grafanaDashboard.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
data:
  agentgateway.json: |'''

new = '''    {{- with .Values.monitoring.grafanaDashboard.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .Values.monitoring.grafanaDashboard.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
data:
  agentgateway.json: |'''

with open(path, encoding="utf-8") as f:
    content = f.read()

if content.count(new) == 1:
    raise SystemExit(0)

if content.count(old) != 1:
    raise SystemExit(
        f"{path}: the upstream dashboard ConfigMap is not what this patch expects. "
        "If the vendored release now carries agentgateway#3591, delete this patch "
        "and the monitoring.grafanaDashboard.annotations default in "
        "sync/patches/values/values.yaml; otherwise re-derive the annotations "
        "block against the new upstream text."
    )

with open(path, "w", encoding="utf-8") as f:
    f.write(content.replace(old, new))
PY

{ set +x; } 2>/dev/null
