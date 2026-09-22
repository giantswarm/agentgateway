#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

repo_dir=$(git rev-parse --show-toplevel) ; readonly repo_dir

cd "${repo_dir}"

# The bundled Grafana dashboard filters and discovers gateways by the
# `gateway.networking.k8s.io/gateway-name` pod label, which a PodMonitor copies
# onto the scraped series only through podTargetLabels. Without it the board's
# gateway variable resolves to nothing and most of its panels are empty
# (agentgateway#3238, agentgateway#3420).
#
# Backport of agentgateway#3421 (`8a790629`), which added the value and the
# rendering upstream. The vendored release v1.5.0 predates it and no 1.5.x
# release carries it; delete this patch, and the values key it reads, at the
# bump to a release that does.
#
# The replacement asserts on the exact upstream text, so the sync fails loudly
# if upstream reworks the PodMonitor.
set -x
python3 - <<'PY'
path = "helm/agentgateway/templates/monitoring.yaml"

old = '''  podMetricsEndpoints:
  - port: metrics
    path: /metrics
    interval: {{ .Values.monitoring.serviceMonitor.interval }}
{{- end }}
{{- if .Values.monitoring.serviceMonitor.enabled }}'''

new = '''  podMetricsEndpoints:
  - port: metrics
    path: /metrics
    interval: {{ .Values.monitoring.serviceMonitor.interval }}
  {{- with .Values.monitoring.proxy.podMonitor.podTargetLabels }}
  podTargetLabels:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- if .Values.monitoring.serviceMonitor.enabled }}'''

with open(path, encoding="utf-8") as f:
    content = f.read()

if content.count(new) == 1:
    raise SystemExit(0)

if content.count(old) != 1:
    raise SystemExit(
        f"{path}: the upstream proxy PodMonitor is not what this patch expects. "
        "If the vendored release now carries agentgateway#3421, delete this patch "
        "and the monitoring.proxy.podMonitor.podTargetLabels default in "
        "sync/patches/values/values.yaml; otherwise re-derive the podTargetLabels "
        "block against the new upstream text."
    )

with open(path, "w", encoding="utf-8") as f:
    f.write(content.replace(old, new))
PY

{ set +x; } 2>/dev/null
