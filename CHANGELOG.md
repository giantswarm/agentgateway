# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- fixed: `make sync` no longer deletes `helm/agentgateway-crds/values.yaml`, `.schema.yaml` and `zz_generated.app-platform.values.yaml`. vendir treated them as unmanaged content in the CRD chart and removed them, which left the pre-commit schema hook without its config.

- fixed: the Renovate cap that keeps this repo on the upstream `v1.x` line now matches. Renovate names an
  image from a custom manager with its registry included, so the `giantswarm/agentgateway-controller`
  entry matched nothing and Renovate proposed the controller image at `v2.2.1` (#34), which is the
  deprecated kgateway control plane. The entries are regexes anchored on the trailing path segment, so
  they hold whether or not the name carries a registry.

- changed: **breaking** flattened the chart. The upstream controller chart is no longer a subchart under `charts/agentgateway`: its files are vendored onto the chart root, so consumers set upstream keys at the top level (`controller.*`) instead of nesting them under `agentgateway.*`. See `UPGRADE.md`.
- added: `agentgateway-crds` chart, the same `agentgateway.dev` CRDs as a chart of their own for consumers that let Helm own the CRD lifecycle. Published from this repo, cut from the same tag as `agentgateway`. Its `values.schema.json` accepts any value: the chart has none of its own, and the app platform injects cluster values.
- added: `sync/sync.sh` as the re-vendor entrypoint (`make sync`), with the Giant Swarm delta under `sync/patches/` and the delta from upstream stored in `diffs/`.
- added: `make verify-sync`, run by the `Verify vendored chart` workflow, fails a PR that skipped `make sync`.
- changed: `controller.image.tag` is empty again, so the controller image follows `appVersion`, the vendored upstream release. The published chart keeps that `appVersion`, so the fallback resolves to a tag that exists. Its Renovate marker is gone; `proxy.image.tag` stays pinned, because the upstream template has no fallback for it.
- changed: the published chart keeps the upstream release as its `appVersion` (`override_app_version: false` on the chart jobs). It used to be stamped with the chart's own version at package time.
- added: `application.giantswarm.io/team` is now a label on every resource both charts render, not only a pod annotation.
- fixed: the `helm.sh/chart` label now strips trailing non-alphanumerics, so a long chart version truncated at 63 characters cannot produce a label Kubernetes rejects.
- removed: `make verify-subchart-version` and `make crds-keep`, replaced by `make verify-sync` and `sync/patches/crds/`. The chart has no `dependencies` and no `Chart.lock` any more.
- changed: chart description now names the product "Giant Swarm Agent Platform" (renamed from "agentic platform").
- reverted: rolled back the migration to agentgateway `v2.2.1`; the vendored chart and CRDs are back on the `v1.3.1` line. The `v2.x` tags in `cr.agentgateway.dev/charts` are the deprecated kgateway-based control plane, a different product from the standalone agentgateway this app packages.
- added: `renovate-custom.json5` capping `cr.agentgateway.dev/charts/agentgateway` and `agentgateway-crds` at `< 2.0.0` so Renovate no longer bumps across into the `v2.x` (kgateway) line.
- fixed: aligned the parent chart on `v1.3.1`. The `file://` subchart dependency version, `Chart.lock` and packaged tarball now match the vendored subchart (`v1.3.1`).
- changed: dropped the controller `image.tag` override so the controller image tracks the vendored subchart appVersion (moved by `vendir`) instead of a hand-maintained pin (previously stuck at `v1.2.1`). The controller now needs no Renovate rule.
- added: Renovate now bumps the pinned data-plane proxy image `giantswarm/agentgateway` via a marker comment in `values.yaml` and a `customManagers` rule, capped `< 2.0.0` alongside the vendored charts.
- fixed: re-injected `helm.sh/resource-policy: keep` on the vendored CRDs (missing from the committed tree), so a `helm uninstall` or Flux prune cannot cascade-delete the agentgateway CRDs and every agentgateway CR cluster-wide.
- changed: `crds-keep` is now a prerequisite of `update-deps`, so `make update-chart` (and a bare `make update-deps`) re-inject the keep annotation after a `vendir sync` overwrites `crds/` with pristine manifests. `APPLICATION` is set so the generated App targets no longer need it on the command line.
- changed: `app.giantswarm.io` label group was changed to `application.giantswarm.io`

[Unreleased]: https://github.com/giantswarm/agentgateway/tree/main
