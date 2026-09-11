##@ Vendoring

# Consumed by the generated App targets (Makefile.gen.app.mk) so they resolve
# helm/agentgateway/... without an explicit APPLICATION= on the command line. A
# command-line override still wins.
APPLICATION := agentgateway

# The upstream chart is flattened onto the chart root by vendir and the Giant
# Swarm delta is re-applied by sync/sync.sh, so re-vendoring is that script and
# not `helm dependency update`. Override the generated update-chart/update-deps
# entrypoints (there is no dependency left to resolve) so a habitual
# `make update-chart` does the right thing.
.PHONY: sync
sync: ## Re-vendor upstream and re-apply the Giant Swarm delta (see sync/sync.sh).
	./sync/sync.sh

update-chart: sync
update-deps: sync

.PHONY: verify-sync
verify-sync: ## Fail when the tree does not match what sync/sync.sh produces.
	./sync/verify.sh

##@ Values schema

# helm/agentgateway/values.schema.json is generated from values.yaml with
# additionalProperties: false on every object, which is what fails an install on
# a typo in a key name. An object that is `{}` in values.yaml (the PDB, the
# rollout strategy, the HPA and VPA specs, affinity, the label and annotation
# maps, extraEnv, ...) gets that strictness with no properties at all, so the
# `# @schema additionalProperties: true` annotations in
# sync/patches/values/values.yaml open each of them. This target renders the
# chart with a values file that sets a key inside every one of them and checks
# the value reaches its manifest, then checks an unknown key is still rejected.
.PHONY: verify-values-surface
verify-values-surface: ## Fail when the values schema rejects a key inside a free-form object (tests/values/surface.yaml) or admits an unknown one.
	@set -e ; \
	full=$$(mktemp) ; deploy=$$(mktemp) ; trap 'rm -f "$$full" "$$deploy"' EXIT ; \
	if ! helm template t helm/agentgateway -f tests/values/surface.yaml >"$$full" 2>&1 ; then \
		cat "$$full" ; echo "verify-values-surface: helm template rejected tests/values/surface.yaml" ; exit 1 ; \
	fi ; \
	helm template t helm/agentgateway -f tests/values/surface.yaml -s templates/deployment.yaml >"$$deploy" ; \
	for want in \
		'type: RollingUpdate' 'maxSurge: 1' \
		'podAntiAffinity:' \
		'topologySpreadConstraints:' 'whenUnsatisfiable: ScheduleAnyway' \
		'dnsConfig:' 'name: ndots' \
		'nodeSelector:' 'kubernetes.io/os: linux' \
		'name: LOG_FORMAT' 'value: "json"' \
		'giantswarm.io/surface-common: common-labels' \
		'giantswarm.io/surface: pod-labels' \
		'giantswarm.io/surface: deployment-annotations' \
		'shared-gwp' \
	; do \
		grep -q -F -- "$$want" "$$deploy" || { echo "verify-values-surface: '$$want' did not reach the Deployment" ; exit 1 ; } ; \
	done ; \
	for want in \
		'kind: PodDisruptionBudget' 'maxUnavailable: 1' \
		'kind: HorizontalPodAutoscaler' 'averageUtilization: 80' \
		'kind: VerticalPodAutoscaler' 'updateMode: Auto' \
		'giantswarm.io/surface: service-account-annotations' \
		'giantswarm.io/surface: service-annotations' \
		'giantswarm.io/surface-service: service-extra-labels' \
		'timeoutSeconds: 10800' \
		'kind: PodMonitor' 'kind: ServiceMonitor' \
		'giantswarm.io/surface-monitor: service-monitor-extra-labels' \
		'- agentgateway-proxies' \
	; do \
		grep -q -F -- "$$want" "$$full" || { echo "verify-values-surface: '$$want' did not reach the rendered chart" ; exit 1 ; } ; \
	done ; \
	for bogus in controller.bogusKey=1 bogus=1 ; do \
		if helm template t helm/agentgateway --set "$$bogus" >"$$full" 2>&1 ; then \
			echo "verify-values-surface: --set $$bogus rendered; the schema must reject an unknown key" ; exit 1 ; \
		fi ; \
		grep -q -F -- 'additional properties' "$$full" || { cat "$$full" ; echo "verify-values-surface: --set $$bogus failed, but not on the schema" ; exit 1 ; } ; \
	done ; \
	echo "verify-values-surface: ok"
