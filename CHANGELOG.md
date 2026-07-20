# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- reverted: rolled back the migration to agentgateway `v2.2.1`; the vendored chart and CRDs are back on the `v1.3.1` line. The `v2.x` tags in `cr.agentgateway.dev/charts` are the deprecated kgateway-based control plane, a different product from the standalone agentgateway this app packages.
- added: `renovate-custom.json5` capping `cr.agentgateway.dev/charts/agentgateway` and `agentgateway-crds` at `< 2.0.0` so Renovate no longer bumps across into the `v2.x` (kgateway) line.
- fixed: aligned the parent chart on `v1.3.1`. The `file://` subchart dependency version, `Chart.lock` and packaged tarball now match the vendored subchart (`v1.3.1`).
- changed: dropped the controller `image.tag` override so the controller image tracks the vendored subchart appVersion (moved by `vendir`) instead of a hand-maintained pin (previously stuck at `v1.2.1`). The controller now needs no Renovate rule.
- added: Renovate now bumps the pinned data-plane proxy image `giantswarm/agentgateway` via a marker comment in `values.yaml` and a `customManagers` rule, capped `< 2.0.0` alongside the vendored charts.
- fixed: re-injected `helm.sh/resource-policy: keep` on the vendored CRDs (missing from the committed tree), so a `helm uninstall` or Flux prune cannot cascade-delete the agentgateway CRDs and every agentgateway CR cluster-wide.
- changed: `crds-keep` is now a prerequisite of `update-deps`, so `make update-chart` (and a bare `make update-deps`) re-inject the keep annotation after a `vendir sync` overwrites `crds/` with pristine manifests. `APPLICATION` is set so the generated App targets no longer need it on the command line.
- changed: `app.giantswarm.io` label group was changed to `application.giantswarm.io`

[Unreleased]: https://github.com/giantswarm/agentgateway/tree/main
