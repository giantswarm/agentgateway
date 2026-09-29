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

.PHONY: verify-images
verify-images: ## Fail when an image the chart's rendered defaults run (the controller, the proxy it creates) is not published on gsoci.azurecr.io. Needs PyYAML and network; HELM selects the binary.
	@python3 -c 'import yaml' 2>/dev/null || { echo "FAIL: PyYAML is not installed (apt: python3-yaml, pip: pyyaml)"; exit 1; }
	@python3 tests/verify-images.py helm/agentgateway
