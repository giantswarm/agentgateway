# agentgateway-crds

Giant Swarm packaging of the upstream agentgateway.dev CRDs (AgentgatewayBackend, AgentgatewayModel, AgentgatewayParameters, AgentgatewayPolicy) as a Helm-managed chart.

**Homepage:** <https://github.com/giantswarm/agentgateway>

## Source Code

* <https://github.com/giantswarm/agentgateway>
* <https://github.com/agentgateway/agentgateway>

## Values

The chart takes no values. It renders the four `agentgateway.dev` CRDs, each
annotated with `helm.sh/resource-policy: keep` so an uninstall never
cascade-deletes the custom resources. `values.schema.json` stays permissive on
purpose: the Giant Swarm app platform merges cluster values into every App's
values, and a strict schema would reject them.

Install this chart INSTEAD of relying on the `crds/` dir of the `agentgateway`
chart. Installing both makes two Helm releases own the same cluster-scoped
objects.
