#!/usr/bin/env python3
"""Assert that every image the chart's rendered defaults run is published on
gsoci.azurecr.io (giantswarm/agentgateway#55).

The chart once pinned `agentgateway-controller:2.0.0`, a tag nobody had
published, and a fresh install waited on ImagePullBackOff until the release
timed out. This check renders helm/agentgateway with its defaults and looks up
every image it names in the registry:

  * every container image of every pod template (the controller);
  * the data-plane proxy image the controller creates proxies from, which the
    chart passes as the AGW_PROXY_IMAGE_REGISTRY / _REPOSITORY / _TAG env
    variables. A missing registry or tag fails too: the controller would fall
    back to upstream's own registry and build.

Each reference must be on gsoci.azurecr.io and its manifest must resolve
(anonymous pull, the registry's token endpoint). Needs PyYAML and network;
HELM selects the binary. Usage: verify-images.py <chart dir>
"""

import json
import os
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request

import yaml

HELM = os.environ.get("HELM", "helm")
REGISTRY = "gsoci.azurecr.io"
CONTAINER_LISTS = ("containers", "initContainers", "ephemeralContainers")
PROXY_ENV = ("AGW_PROXY_IMAGE_REGISTRY", "AGW_PROXY_IMAGE_REPOSITORY", "AGW_PROXY_IMAGE_TAG")
MANIFEST_TYPES = ", ".join((
    "application/vnd.oci.image.index.v1+json",
    "application/vnd.docker.distribution.manifest.list.v2+json",
    "application/vnd.oci.image.manifest.v1+json",
    "application/vnd.docker.distribution.manifest.v2+json",
))


def fail(message: str) -> None:
    print(f"FAIL: {message}", file=sys.stderr)
    sys.exit(1)


def render(chart: str) -> list[dict]:
    result = subprocess.run([HELM, "template", "t", chart], capture_output=True, text=True, check=False)
    if result.returncode != 0:
        fail(f"helm template {chart} failed:\n{result.stderr}")
    return [d for d in yaml.safe_load_all(result.stdout) if isinstance(d, dict)]


def pod_specs(node):
    """Every map that holds a container list, wherever the pod template sits."""
    if isinstance(node, dict):
        if any(isinstance(node.get(k), list) for k in CONTAINER_LISTS):
            yield node
        for value in node.values():
            yield from pod_specs(value)
    elif isinstance(node, list):
        for item in node:
            yield from pod_specs(item)


def images(docs: list[dict]) -> dict[str, str]:
    """Image reference -> where it was rendered."""
    found: dict[str, str] = {}
    for doc in docs:
        where = f"{doc.get('kind', '')}/{doc.get('metadata', {}).get('name', '')}"
        for spec in pod_specs(doc):
            for key in CONTAINER_LISTS:
                for container in spec.get(key) or []:
                    name = container.get("name", "")
                    if container.get("image"):
                        found.setdefault(container["image"], f"{where} {key}[{name}].image")
                    env = {e.get("name"): e.get("value") for e in container.get("env") or [] if "value" in e}
                    if PROXY_ENV[1] in env:
                        registry, repository, tag = (env.get(k) for k in PROXY_ENV)
                        if not registry or not tag:
                            fail(f"{where} {key}[{name}]: the proxy image names no registry or no tag "
                                 f"({'/'.join(PROXY_ENV)}), so the controller falls back to upstream's build")
                        found.setdefault(f"{registry}/{repository}:{tag}", f"{where} {key}[{name}] {PROXY_ENV[1]}")
    return found


def published(reference: str) -> tuple[bool, str]:
    """Whether the reference is a gsoci image whose manifest resolves."""
    host, _, rest = reference.partition("/")
    if host != REGISTRY:
        return False, f"not on {REGISTRY}"
    if "@" in rest:
        repository, _, ref = rest.partition("@")
    else:
        repository, _, ref = rest.rpartition(":")
    if not repository or not ref:
        return False, "names no tag or digest"
    scope = urllib.parse.quote(f"repository:{repository}:pull", safe="")
    try:
        with urllib.request.urlopen(f"https://{REGISTRY}/oauth2/token?service={REGISTRY}&scope={scope}", timeout=30) as r:
            token = json.load(r)["access_token"]
        request = urllib.request.Request(f"https://{REGISTRY}/v2/{repository}/manifests/{ref}", method="HEAD",
                                         headers={"Authorization": f"Bearer {token}", "Accept": MANIFEST_TYPES})
        with urllib.request.urlopen(request, timeout=30):
            return True, "published"
    except urllib.error.HTTPError as e:
        return False, "not published" if e.code == 404 else f"registry answered {e.code}"
    except (urllib.error.URLError, TimeoutError, KeyError) as e:
        return False, f"lookup failed: {e}"


def main() -> None:
    if len(sys.argv) != 2:
        fail("usage: verify-images.py <chart dir>")
    found = images(render(sys.argv[1]))
    if not found:
        fail("the render names no image; the check would prove nothing")
    missing = []
    for reference, where in sorted(found.items()):
        ok, why = published(reference)
        print(f"{'ok  ' if ok else 'FAIL'} {reference} ({where}): {why}")
        if not ok:
            missing.append(reference)
    if missing:
        fail(f"{len(missing)} of {len(found)} image(s) are not published on {REGISTRY}")


if __name__ == "__main__":
    main()
