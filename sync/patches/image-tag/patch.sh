#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

repo_dir=$(git rev-parse --show-toplevel) ; readonly repo_dir

cd "${repo_dir}"

# Upstream's agentgateway.imageTag helper prepends a "v" to a bare semver tag,
# because upstream's own images carry one (v1.5.0). The releases of the Giant
# Swarm line of agentgateway (github.com/giantswarm/agentgateway-upstream,
# FORK.md "Publishing") are tagged bare X.Y.Z, the architect orb's convention:
# a consumer that sets controller.image.tag to such a release would render
# ...:vX.Y.Z, a tag that does not exist, and the controller pod could not pull.
# Use the configured tag as-is. A tag that already carries its v (the pinned
# default, upstream's own releases) and the .Chart.AppVersion fallback pass
# through unchanged, so the render of every current consumer is identical.
#
# The replacement asserts on the exact upstream text, so the sync fails loudly
# if upstream reworks the helper and the fix can never be lost silently. It is
# done in python rather than as a stored .patch because the repo's
# trailing-whitespace pre-commit hook rewrites .patch files.
set -x
python3 - <<'PY'
path = "helm/agentgateway/templates/_helpers.tpl"

old = r'''{{/*
Get the image tag with 'v' prefix for semver tags.
If the input already starts with 'v', return it as-is.
If the input looks like a semver version (e.g., "1.2.3"), prepend 'v'.
Otherwise (e.g., "latest", "dev"), return it unchanged.
*/}}
{{- define "agentgateway.imageTag" -}}
{{- $tag := . -}}
{{- if hasPrefix "v" $tag -}}
{{- $tag -}}
{{- else if regexMatch "^[0-9]+\\.[0-9]+\\..*$" $tag -}}
{{- printf "v%s" $tag -}}
{{- else -}}
{{- $tag -}}
{{- end -}}
{{- end }}'''

new = r'''{{/*
Get the image tag as configured. Upstream prepends a 'v' to a bare semver tag
because its own images carry one; the releases of the Giant Swarm line of
agentgateway are tagged bare X.Y.Z, so the tag is used as-is
(sync/patches/image-tag).
*/}}
{{- define "agentgateway.imageTag" -}}
{{- . -}}
{{- end }}'''

with open(path, encoding="utf-8") as f:
    content = f.read()

if content.count(new) == 1:
    raise SystemExit(0)

if content.count(old) != 1:
    raise SystemExit(
        f"{path}: the upstream agentgateway.imageTag helper is not what this patch "
        "expects. Re-derive the image-tag fix against the new upstream text."
    )

with open(path, "w", encoding="utf-8") as f:
    f.write(content.replace(old, new))
PY

{ set +x; } 2>/dev/null
