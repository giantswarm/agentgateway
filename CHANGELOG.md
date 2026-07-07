# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- reverted: rolled back the migration to agentgateway `v2.2.1`; the vendored chart and CRDs are back on the `v1.3.1` line. The `v2.x` tags in `cr.agentgateway.dev/charts` are the deprecated kgateway-based control plane, a different product from the standalone agentgateway this app packages.
- added: `renovate-custom.json5` capping `cr.agentgateway.dev/charts/agentgateway` and `agentgateway-crds` at `< 2.0.0` so Renovate no longer bumps across into the `v2.x` (kgateway) line.
- changed: `app.giantswarm.io` label group was changed to `application.giantswarm.io`

[Unreleased]: https://github.com/giantswarm/agentgateway/tree/main
