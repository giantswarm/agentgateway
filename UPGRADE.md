# Upgrading

## 1.x to 2.0.0

`2.0.0` flattens the chart. The upstream controller chart used to be a subchart
under `charts/agentgateway`, so every consumer nested its values under
`agentgateway.*`. The upstream files now sit at the chart root, so upstream keys
move to the top level.

`1.x` is not end-of-life. It continues on the `release-1.x` branch, and CVE and
upstream bumps for the fleet ship from there.

### What you have to change

Drop the `agentgateway:` key and lift everything under it up one level:

```yaml
# 1.x
agentgateway:
  controller:
    replicaCount: 2
  monitoring:
    enabled: true

# 2.0.0
controller:
  replicaCount: 2
monitoring:
  enabled: true
```

`helm show values` of `2.0.0` lists the full set. The chart validates values
against `values.schema.json`, so a leftover `agentgateway:` key fails the
install with `Additional property agentgateway is not allowed` rather than being
ignored.

### What does not change

- Resource names, the pod selector and the namespace. No object is renamed, so
  the upgrade is in place and needs no delete.
- The rendered output for the same effective values, apart from three labels,
  none of them a selector label:
  - `helm.sh/chart` and `app.kubernetes.io/version` now carry this chart's own
    version instead of the upstream one.
  - `application.giantswarm.io/team` is new on every resource. The 1.x wrapper
    set it as a pod annotation only.
- CRD delivery. The `crds/` dir is still app-owned, still annotated
  `helm.sh/resource-policy: keep`, and consumers still apply the chart with
  Flux `crds: CreateReplace`.

### New in 2.0.0

- `agentgateway-crds`, the same CRDs as a chart of their own, published to the
  same catalog and cut from the same tag. It is for consumers that want Helm to
  own the CRD lifecycle. Install it *instead of* relying on the `crds/` dir;
  installing both makes two Helm releases own the same cluster-scoped objects.
