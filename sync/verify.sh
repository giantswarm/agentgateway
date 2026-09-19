#!/usr/bin/env bash

# Fail when the tree does not match what sync/sync.sh produces.
#
# The Giant Swarm delta is not a layer of its own any more: sync/sync.sh
# re-applies it after every `vendir sync`. Nothing forces a contributor (or
# Renovate) to run that script, and the tree stays plausible when they do not,
# so this check runs in CI instead. It needs no network: it compares files that
# are already in the tree.

set -o errexit
set -o nounset
set -o pipefail

repo_dir=$(git rev-parse --show-toplevel) ; readonly repo_dir

cd "${repo_dir}"

readonly chart=helm/agentgateway
readonly crds_chart=helm/agentgateway-crds

fail=0

note() {
	echo "$1"
	fail=1
}

vendored_version() {
	yq -r ".directories[] | select(.path == \"vendor\").contents[] | select(.path == \"$1\").helmChart.version" vendir.yml
}

# values.yaml is repo-owned in full. Back at upstream defaults it would publish
# a chart with the upstream registry and no restricted-PSS contexts.
if ! diff -q sync/patches/values/values.yaml "${chart}/values.yaml" >/dev/null ; then
	note "${chart}/values.yaml differs from sync/patches/values/values.yaml; run 'make sync'"
fi

# The CRDs track the chart, so the two vendored versions move together.
chart_version=$(vendored_version agentgateway)
crds_version=$(vendored_version agentgateway-crds)
if [ "${chart_version}" != "${crds_version}" ] ; then
	note "vendir.yml vendors chart ${chart_version} but CRDs ${crds_version}; the CRDs must track the chart"
fi

# appVersion also selects the controller image in the upstream template, and it
# is what the CRD chart advertises.
for pair in "${chart}:${chart_version}" "${crds_chart}:${crds_version}" ; do
	dir=${pair%:*}
	want=${pair#*:}
	got=$(yq -r '.appVersion' "${dir}/Chart.yaml")
	if [ "${want}" != "${got}" ] ; then
		note "${dir}/Chart.yaml appVersion is ${got} but vendir.yml vendors ${want}; run 'make sync'"
	fi
done

# Both image tags are releases of the Giant Swarm line of agentgateway
# (github.com/giantswarm/agentgateway-upstream, FORK.md "Publishing"): the
# line's own stable semver, decoupled from the vendored chart's version as the
# RFC on semantic versioning of upstream software lays down — which upstream
# pin a release carries is documented in the line's FORK.md, not encoded in
# the tag. So the check is the shape (a stable X.Y.Z: no v, no suffix, never
# empty) and that both images come from one release. The proxy tag has no
# appVersion fallback in the upstream template (with no tag the
# AGW_PROXY_IMAGE_TAG env var is not set at all); the controller tag must not be
# left to the appVersion fallback either, because that names upstream's build.
proxy_tag=$(yq -r '.proxy.image.tag' "${chart}/values.yaml")
controller_tag=$(yq -r '.controller.image.tag' "${chart}/values.yaml")
for pair in "proxy.image.tag:${proxy_tag}" "controller.image.tag:${controller_tag}" ; do
	key=${pair%%:*}
	tag=${pair#*:}
	if ! [[ "${tag}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] ; then
		note "${chart}/values.yaml pins ${key} '${tag}'; expected a stable release of the agentgateway line (X.Y.Z)"
	fi
done
if [ "${proxy_tag}" != "${controller_tag}" ] ; then
	note "${chart}/values.yaml pins proxy.image.tag ${proxy_tag} but controller.image.tag ${controller_tag}; both images come from one release of the line"
fi

if yq -e '.dependencies' "${chart}/Chart.yaml" >/dev/null 2>&1 ; then
	note "${chart}/Chart.yaml still declares dependencies; the chart is flattened"
fi

# Without the chart-label fix a branch build can emit an invalid label, and the
# install then fails late and reads like a flake.
if ! grep -q 'regexReplaceAll "\[^a-zA-Z0-9\]+\$"' "${chart}/templates/_helpers.tpl" ; then
	note "${chart}/templates/_helpers.tpl lost the chart-label fix; run 'make sync'"
fi

# Without the image-tag fix the upstream helper prepends a v to the bare X.Y.Z
# tag of the line's images, and the controller image it renders does not exist.
if ! grep -q 'sync/patches/image-tag' "${chart}/templates/_helpers.tpl" ; then
	note "${chart}/templates/_helpers.tpl lost the image-tag fix; run 'make sync'"
fi

# app-build-suite's C0001 validator rejects a chart whose _helpers.tpl carries
# no team label, so a missing line fails the release, not just the label.
for f in "${chart}/templates/_helpers.tpl" "${crds_chart}/templates/_helpers.tpl" ; do
	if ! grep -q 'application.giantswarm.io/team: {{ index .Chart.Annotations' "$f" ; then
		note "$f lost the team label; run 'make sync'"
	fi
done

# Without the keep annotation a helm uninstall or a Flux prune cascade-deletes
# every agentgateway custom resource in the cluster.
for f in "${chart}"/crds/agentgateway.dev_*.yaml ; do
	yq -e '.metadata.annotations."helm.sh/resource-policy" == "keep"' "$f" >/dev/null \
		|| note "$f lost helm.sh/resource-policy: keep; run 'make sync'"
done

# The CRD chart's manifests hold a Helm include, so they are not YAML any more.
for f in "${crds_chart}"/templates/agentgateway.dev_*.yaml ; do
	grep -q 'helm.sh/resource-policy: keep' "$f" \
		|| note "$f lost helm.sh/resource-policy: keep; run 'make sync'"
done

# Both delivery paths must ship the same CRD. The only difference the chart's
# copy is allowed to carry is the label include.
for f in "${chart}"/crds/agentgateway.dev_*.yaml ; do
	other="${crds_chart}/templates/$(basename "$f")"
	if ! grep -v 'include "agentgateway-crds.giantSwarmLabels"' "${other}" | diff -q - "$f" >/dev/null ; then
		note "$f and ${other} disagree; both ship the same CRD, run 'make sync'"
	fi
done

exit "${fail}"
