##@ Vendoring

# Consumed by the generated App targets (Makefile.gen.app.mk) so they resolve
# helm/agentgateway/... without an explicit APPLICATION= on the command line. A
# command-line override still wins.
APPLICATION := agentgateway

# CRD files vendored (pristine) from the upstream agentgateway-crds chart into
# helm/agentgateway/crds/. Helm never upgrades crds/-dir CRDs on its own; Flux
# applies this dir with `crds: CreateReplace` (set on the agentic-platform
# component). The keep annotation injected below makes the live CRDs survive a
# `helm uninstall`/prune so their CRs are never cascade-deleted.
CRDS := $(wildcard helm/agentgateway/crds/agentgateway.dev_*.yaml)

# vendir sync overwrites crds/ with pristine manifests that lack the keep
# annotation. Wire crds-keep in as a prerequisite of the generated update-deps
# target (a prerequisite, not a recipe override, so devctl regeneration of
# Makefile.gen.app.mk is unaffected). update-chart runs `vendir sync` then
# `$(MAKE) update-deps`, so this re-injects the annotation on every re-vendor
# path: `make sync`, `make update-chart`, and `make update-deps`.
update-deps: crds-keep

.PHONY: sync crds-keep
sync: ## Re-vendor the upstream chart + CRDs (pinned in vendir.lock.yml), re-inject the keep annotation, and refresh the local dep lock/tarball.
	vendir sync
	$(MAKE) update-deps
	@echo "Synced upstream controller chart (helm/agentgateway/charts) and CRDs (helm/agentgateway/crds)."
	@echo "helm.sh/resource-policy: keep re-injected into each crds/ manifest; local dep lock/tarball refreshed."

crds-keep: ## Inject helm.sh/resource-policy: keep into each vendored CRD (idempotent).
	@for f in $(CRDS); do \
		$(YQ) -i '.metadata.annotations."helm.sh/resource-policy" = "keep"' "$$f"; \
		echo "annotated $$f"; \
	done
