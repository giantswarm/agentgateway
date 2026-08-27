#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

repo_dir=$(git rev-parse --show-toplevel) ; readonly repo_dir

cd "${repo_dir}"

# Two CRD delivery paths ship from the same pristine manifests:
#
#   * helm/agentgateway/crds/ -- app-owned CRDs. Helm never upgrades a crds/
#     dir on its own, so consumers apply this chart with Flux
#     `crds: CreateReplace`.
#   * helm/agentgateway-crds/templates/ -- the optional Helm-managed lifecycle,
#     for consumers that let Helm own the CRDs and disable the dir above.
#
# Both get helm.sh/resource-policy: keep, so a `helm uninstall` or a Flux prune
# never cascade-deletes every agentgateway CR in the cluster.
set -x
mkdir -p ./helm/agentgateway/crds
rm -f ./helm/agentgateway/crds/agentgateway.dev_*.yaml
cp ./vendor/agentgateway-crds/templates/agentgateway.dev_*.yaml ./helm/agentgateway/crds/

for f in ./helm/agentgateway/crds/agentgateway.dev_*.yaml ./helm/agentgateway-crds/templates/agentgateway.dev_*.yaml ; do
	yq -i '.metadata.annotations."helm.sh/resource-policy" = "keep"' "$f"
done

# The chart's CRDs also carry the Giant Swarm labels. The crds/ dir of the main
# chart cannot: Helm does not template a crds/ dir.
python3 - <<'PY'
import pathlib

OLD = """  labels:
    app: agentgateway
    app.kubernetes.io/name: agentgateway
"""

NEW = """  labels:
    app: agentgateway
    app.kubernetes.io/name: agentgateway
    {{- include "agentgateway-crds.giantSwarmLabels" . | nindent 4 }}
"""

for path in sorted(pathlib.Path("helm/agentgateway-crds/templates").glob("agentgateway.dev_*.yaml")):
    content = path.read_text(encoding="utf-8")
    if content.count(NEW) == 1:
        continue
    if content.count(OLD) != 1:
        raise SystemExit(
            f"{path}: the upstream label block is not what this patch expects. "
            "Re-derive the label injection against the new upstream manifests."
        )
    path.write_text(content.replace(OLD, NEW), encoding="utf-8")
PY

{ set +x; } 2>/dev/null
