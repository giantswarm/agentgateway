##@ Vendoring

# CRD files vendored (pristine) from the upstream agentgateway-crds chart into
# helm/agentgateway/crds/. Helm never upgrades crds/-dir CRDs on its own; Flux
# applies this dir with `crds: CreateReplace` (set on the agentic-platform
# component). The keep annotation injected below makes the live CRDs survive a
# `helm uninstall`/prune so their CRs are never cascade-deleted.
CRDS := $(wildcard helm/agentgateway/crds/agentgateway.dev_*.yaml)

.PHONY: sync crds-keep
sync: ## Re-vendor the upstream agentgateway chart + CRDs (pinned in vendir.lock.yml) and re-inject the keep annotation.
	vendir sync
	$(MAKE) crds-keep
	@echo "Synced upstream controller chart (helm/agentgateway/charts) and CRDs (helm/agentgateway/crds)."
	@echo "helm.sh/resource-policy: keep re-injected into each crds/ manifest."

crds-keep: ## Inject helm.sh/resource-policy: keep into each vendored CRD (idempotent).
	@for f in $(CRDS); do \
		$(YQ) -i '.metadata.annotations."helm.sh/resource-policy" = "keep"' "$$f"; \
		echo "annotated $$f"; \
	done
