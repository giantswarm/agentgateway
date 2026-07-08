# agentgateway

Giant Swarm packaging of the upstream agentgateway controller (kgateway-based control plane + data-plane proxy), shipping its agentgateway.dev CRDs as app-owned CRDs for the Giant Swarm agentic platform.

**Homepage:** <https://github.com/giantswarm/agentgateway>

## Source Code

* <https://github.com/giantswarm/agentgateway>
* <https://github.com/agentgateway/agentgateway>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://charts/agentgateway | agentgateway | v1.3.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| agentgateway.image.registry | string | `"gsoci.azurecr.io"` |  |
| agentgateway.image.tag | string | `"v1.3.1"` |  |
| agentgateway.controller.image.repository | string | `"giantswarm/agentgateway-controller"` |  |
| agentgateway.proxy.image.registry | string | `"gsoci.azurecr.io"` |  |
| agentgateway.proxy.image.repository | string | `"giantswarm/agentgateway"` |  |
| agentgateway.proxy.image.tag | string | `"v1.3.1"` |  |
| agentgateway.podAnnotations."application.giantswarm.io/team" | string | `"bumblebee"` |  |
| agentgateway.podSecurityContext.runAsNonRoot | bool | `true` |  |
| agentgateway.podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| agentgateway.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| agentgateway.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| agentgateway.securityContext.runAsNonRoot | bool | `true` |  |
| agentgateway.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| agentgateway.securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| agentgateway.resources.requests.cpu | string | `"50m"` |  |
| agentgateway.resources.requests.memory | string | `"128Mi"` |  |
| agentgateway.resources.limits.cpu | string | `"500m"` |  |
| agentgateway.resources.limits.memory | string | `"512Mi"` |  |
