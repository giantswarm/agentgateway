# agentgateway

![Version: 1.3.0](https://img.shields.io/badge/Version-1.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.3.0](https://img.shields.io/badge/AppVersion-1.3.0-informational?style=flat-square)

A Helm chart for the agentgateway project

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| imagePullSecrets | list | `[]` | Set a list of image pull secrets for Kubernetes to use when pulling container images from your own private registry instead of the default agentgateway registry. |
| commonLabels | object | `{}` | Additional labels to add to all resources created by the Helm chart. |
| nameOverride | string | `""` | Add a name to the default Helm base release, which is 'agentgateway'. If you set 'nameOverride: "foo", the name of the resources that the Helm release creates become 'agentgateway-foo', such as the deployment, service, and service account for the agentgateway control plane in the agentgateway-system namespace. |
| fullnameOverride | string | `""` | Override the full name of resources created by the Helm chart, which is 'agentgateway'. If you set 'fullnameOverride: "foo", the full name of the resources that the Helm release creates become 'foo', such as the deployment, service, and service account for the agentgateway control plane in the agentgateway-system namespace. |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Configure the service account for the deployment. |
| serviceAccount.create | bool | `true` | Specify whether a service account should be created. |
| serviceAccount.annotations | object | `{}` | Add annotations to the service account. |
| serviceAccount.name | string | `""` | Set the name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| deploymentAnnotations | object | `{}` | Add annotations to the agentgateway deployment. |
| podAnnotations | object | `{"prometheus.io/scrape":"true"}` | Add annotations to the agentgateway pods. |
| podSecurityContext | object | `{}` | Set the pod-level security context. For example, 'fsGroup: 2000' sets the filesystem group to 2000. |
| securityContext | object | `{}` | Set the container-level security context, such as 'runAsNonRoot: true'. |
| resources | object | `{"requests":{"cpu":"100m","memory":"128Mi"}}` | Configure resource requests and limits for the container, such as 'limits.cpu: 100m' or 'requests.memory: 128Mi'. |
| nodeSelector | object | `{}` | Set node selector labels for pod scheduling, such as 'kubernetes.io/arch: amd64'. |
| tolerations | list | `[]` | Set tolerations for pod scheduling, such as 'key: "nvidia.com/gpu"'. |
| affinity | object | `{}` | Set affinity rules for pod scheduling, such as 'nodeAffinity:'. |
| controller | object | `{"extraEnv":{},"extraVolumeMounts":[],"extraVolumes":[],"horizontalPodAutoscaler":{},"image":{"pullPolicy":"","registry":"","repository":"controller","tag":""},"logLevel":"info","podDisruptionBudget":{},"priorityClassName":"","replicaCount":1,"service":{"allocateLoadBalancerNodePorts":null,"annotations":{},"clusterIP":"","clusterIPs":[],"enabled":true,"externalIPs":[],"externalName":"","externalTrafficPolicy":"","extraLabels":{},"healthCheckNodePort":null,"internalTrafficPolicy":"","ipFamilies":[],"ipFamilyPolicy":"","loadBalancerClass":"","loadBalancerIP":"","loadBalancerSourceRanges":[],"ports":{"agwGrpc":9978,"health":9093,"metrics":9092},"publishNotReadyAddresses":false,"sessionAffinity":"","sessionAffinityConfig":{},"trafficDistribution":"","type":"ClusterIP"},"strategy":{},"verticalPodAutoscaler":{},"xds":{"mode":"tls"}}` | Configure the agentgateway control plane deployment. |
| controller.replicaCount | int | `1` | Set the number of controller pod replicas. |
| controller.priorityClassName | string | `""` | Set the priority class name for the controller pod. |
| controller.logLevel | string | `"info"` | Set the log level for the controller. |
| controller.image | object | `{"pullPolicy":"","registry":"","repository":"controller","tag":""}` | Configure the controller container image. |
| controller.image.registry | string | `""` | Set the image registry for the controller. |
| controller.image.repository | string | `"controller"` | Set the image repository for the controller. |
| controller.image.pullPolicy | string | `""` | Set the image pull policy for the controller. |
| controller.image.tag | string | `""` | Set the image tag for the controller. |
| controller.service | object | `{"allocateLoadBalancerNodePorts":null,"annotations":{},"clusterIP":"","clusterIPs":[],"enabled":true,"externalIPs":[],"externalName":"","externalTrafficPolicy":"","extraLabels":{},"healthCheckNodePort":null,"internalTrafficPolicy":"","ipFamilies":[],"ipFamilyPolicy":"","loadBalancerClass":"","loadBalancerIP":"","loadBalancerSourceRanges":[],"ports":{"agwGrpc":9978,"health":9093,"metrics":9092},"publishNotReadyAddresses":false,"sessionAffinity":"","sessionAffinityConfig":{},"trafficDistribution":"","type":"ClusterIP"}` | Configure the controller service. |
| controller.service.enabled | bool | `true` | Create the controller Service. |
| controller.service.type | string | `"ClusterIP"` | Service type. |
| controller.service.ports | object | `{"agwGrpc":9978,"health":9093,"metrics":9092}` | Service ports. |
| controller.service.annotations | object | `{}` | Service annotations. |
| controller.service.extraLabels | object | `{}` | Extra labels for the Service. |
| controller.service.clusterIP | string | `""` | Cluster IP address. |
| controller.service.clusterIPs | list | `[]` | Cluster IPs for dual-stack. |
| controller.service.externalIPs | list | `[]` | External IP addresses. |
| controller.service.externalName | string | `""` | External name for ExternalName services. |
| controller.service.loadBalancerIP | string | `""` | Load balancer IP address. |
| controller.service.loadBalancerSourceRanges | list | `[]` | Allowed source ranges for load balancer. |
| controller.service.loadBalancerClass | string | `""` | Load balancer class. |
| controller.service.externalTrafficPolicy | string | `""` | External traffic policy. |
| controller.service.internalTrafficPolicy | string | `""` | Internal traffic policy. |
| controller.service.healthCheckNodePort | string | `nil` | Health check node port. |
| controller.service.sessionAffinity | string | `""` | Session affinity. |
| controller.service.sessionAffinityConfig | object | `{}` | Session affinity configuration. |
| controller.service.ipFamilies | list | `[]` | IP families. |
| controller.service.ipFamilyPolicy | string | `""` | IP family policy. |
| controller.service.publishNotReadyAddresses | bool | `false` | Publish not ready addresses. |
| controller.service.allocateLoadBalancerNodePorts | string | `nil` | Allocate load balancer node ports. |
| controller.service.trafficDistribution | string | `""` | Traffic distribution. |
| controller.extraEnv | object | `{}` | Add extra environment variables to the controller container. Supports either a direct scalar value: extraEnv:   LOG_FORMAT: json Or Kubernetes valueFrom sources: extraEnv:   API_TOKEN:     valueFrom:       secretKeyRef:         name: agentgateway-secrets         key: apiToken |
| controller.extraVolumeMounts | list | `[]` | Add extra volume mounts to the controller container. |
| controller.extraVolumes | list | `[]` | Add extra volumes to the controller pod. |
| controller.xds | object | `{"mode":"tls"}` | Configure xDS transport mode for the gRPC servers. |
| controller.xds.mode | string | `"tls"` | One of: plaintext, tls, either. |
| controller.strategy | object | `{}` | Change the rollout strategy from the Kubernetes default of a RollingUpdate with 25% maxUnavailable, 25% maxSurge. E.g., to recreate pods, minimizing resources for the rollout but causing downtime: strategy:   type: Recreate E.g., to roll out as a RollingUpdate but with non-default parameters: strategy:   type: RollingUpdate   rollingUpdate:     maxSurge: 100% |
| controller.podDisruptionBudget | object | `{}` | Set pod disruption budget for the controller. Note that this does not    affect the data plane. E.g.:  podDisruptionBudget:   minAvailable: 100% |
| controller.horizontalPodAutoscaler | object | `{}` | Set horizontal pod autoscaler for the controller. Note that this does not    affect the data plane. The scaleTargetRef is automatically configured to    target the controller deployment. E.g.:  horizontalPodAutoscaler:   minReplicas: 1   maxReplicas: 5   metrics:     - type: Resource       resource:         name: cpu         target:           type: Utilization           averageUtilization: 80 |
| controller.verticalPodAutoscaler | object | `{}` | Set vertical pod autoscaler for the controller. Note that this does not    affect the data plane. The targetRef is automatically configured to    target the controller deployment. E.g.:  verticalPodAutoscaler:   updatePolicy:     updateMode: Auto   resourcePolicy:     containerPolicies:       - containerName: "*"         minAllowed:           cpu: 100m           memory: 128Mi |
| proxy | object | `{"image":{"registry":"","repository":"agentgateway","tag":""}}` | Configure the agentgateway data plane deployment. |
| proxy.image.registry | string | `""` | Set the default image registry. Set to override the global value. |
| proxy.image.repository | string | `"agentgateway"` | Set the default image repository. |
| proxy.image.tag | string | `""` | Set the default image tag. |
| image | object | `{"pullPolicy":"IfNotPresent","registry":"cr.agentgateway.dev","tag":""}` | Configure the default container image for the components that Helm deploys. You can override these settings for each particular component in that component's section, such as 'controller.image' for the agentgateway control plane. If you use your own private registry, make sure to include the imagePullSecrets. |
| image.registry | string | `"cr.agentgateway.dev"` | Set the default image registry. |
| image.tag | string | `""` | Set the default image tag. |
| image.pullPolicy | string | `"IfNotPresent"` | Set the default image pull policy. |
| inferenceExtension | object | `{"enabled":false}` | Configure the integration with the Gateway API Inference Extension project, which lets you use agentgateway to route to AI inference workloads like LLMs that run locally in your Kubernetes cluster. Documentation for Inference Extension can be found here: https://agentgateway.dev/docs/kubernetes/latest/inference/ |
| inferenceExtension.enabled | bool | `false` | Enable Inference Extension support in the agentgateway controller. |
| discoveryNamespaceSelectors | list | `[]` | List of namespace selectors (OR'ed): each entry can use 'matchLabels' or 'matchExpressions' (AND'ed within each entry if used together). Agentgateway includes the selected namespaces in config discovery. For more information, see the docs https://agentgateway.dev/docs/kubernetes/latest/install/advanced/#namespace-discovery. |
| gatewayClassParametersRefs | object | `{}` | Map of GatewayClass names to GatewayParameters references that will be set on    the default GatewayClasses managed by kgateway. Each entry must define both the    name and namespace of the GatewayParameters resource.    The default GatewayClasses managed by kgateway are:    - agentgateway    Example:    gatewayClassParametersRefs:      agentgateway:        name: shared-gwp        namespace: kgateway-system |
| istio | object | `{"autoEnabled":false,"caAddress":"","clusterId":"","namespace":"","network":"","revision":""}` | Control-plane-wide Istio mesh defaults. |
| istio.autoEnabled | bool | `false` | Enable Istio integration by default on all built-in-class gateways.    When false (default), gateways opt in via AgentgatewayParameters spec.istio;    when true, individual gateways can opt out via spec.istio.enabled=false. |
| istio.namespace | string | `""` | Namespace where the Istio control plane the controller integrates with is installed.    Defaults to "istio-system". |
| istio.revision | string | `""` | Revision of the Istio control plane the controller integrates with.   If unset, the default revision is used. |
| istio.clusterId | string | `""` | Istio cluster ID (the istiod multiCluster clusterName) for mesh-integrated gateways. |
| istio.network | string | `""` | Istio network for mesh-integrated gateways. |
| istio.caAddress | string | `""` | Istio CA address override;    Defaults to "https://istiod.istio-system.svc:15012" |
| monitoring | object | `{"enabled":false,"grafanaDashboard":{"enabled":true,"labels":{"grafana_dashboard":"1"}},"proxy":{"namespaceSelector":{}},"serviceMonitor":{"enabled":true,"extraLabels":{},"interval":"15s"}}` | Configure Prometheus and Grafana monitoring resources. |
| monitoring.enabled | bool | `false` | Create monitoring resources (ServiceMonitors and Grafana dashboard ConfigMap). Requires the Prometheus Operator CRDs to be installed in the cluster. |
| monitoring.serviceMonitor.enabled | bool | `true` | Create ServiceMonitor resources. |
| monitoring.serviceMonitor.interval | string | `"15s"` | Scrape interval for both ServiceMonitors. |
| monitoring.serviceMonitor.extraLabels | object | `{}` | Additional labels to add to both ServiceMonitor resources (e.g. release: prometheus). |
| monitoring.proxy.namespaceSelector | object | `{}` | Namespace selector used by the proxy ServiceMonitor. The proxy ServiceMonitor always selects Services with gateway.networking.k8s.io/gateway-class-name=agentgateway. |
| monitoring.grafanaDashboard.enabled | bool | `true` | Create the Grafana dashboard ConfigMap. |
| monitoring.grafanaDashboard.labels | object | `{"grafana_dashboard":"1"}` | Labels that the Grafana sidecar uses to discover dashboards. |
