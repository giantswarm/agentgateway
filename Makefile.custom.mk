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

# `make update-chart` is the re-vendor entrypoint: it runs `vendir sync` then
# `$(MAKE) update-deps`. vendir sync overwrites crds/ with pristine manifests
# that lack the keep annotation, so wire crds-keep in as a prerequisite of
# update-deps (a prerequisite, not a recipe override, so devctl regeneration of
# Makefile.gen.app.mk is unaffected). This re-injects the annotation on every
# re-vendor path: `make update-chart` and a bare `make update-deps`.
update-deps: crds-keep

.PHONY: crds-keep
crds-keep: ## Inject helm.sh/resource-policy: keep into each vendored CRD (idempotent).
	@for f in $(CRDS); do \
		$(YQ) -i '.metadata.annotations."helm.sh/resource-policy" = "keep"' "$$f"; \
		echo "annotated $$f"; \
	done
