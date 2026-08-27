#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

repo_dir=$(git rev-parse --show-toplevel) ; readonly repo_dir

cd "${repo_dir}"

# Both charts keep their own version line (git-replaced at build time), so only
# appVersion tracks upstream. The controller image tag is empty in values.yaml
# and the deployment template falls back to .Chart.AppVersion, so this is also
# what selects the controller image. Keep the leading "v" of the vendored
# version: it is what the upstream chart itself carries, and it keeps the
# rendered app.kubernetes.io/version label unchanged from the 1.x wrapper.
set -x
app_version=$(yq -r '.directories[] | select(.path == "vendor").contents[] | select(.path == "agentgateway").helmChart.version' vendir.yml)
crds_version=$(yq -r '.directories[] | select(.path == "vendor").contents[] | select(.path == "agentgateway-crds").helmChart.version' vendir.yml)

yq -i ".appVersion = \"${app_version}\"" ./helm/agentgateway/Chart.yaml
yq -i ".appVersion = \"${crds_version}\"" ./helm/agentgateway-crds/Chart.yaml

{ set +x; } 2>/dev/null
