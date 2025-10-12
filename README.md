# athens-proxy-charts

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/volker-raschek)](https://artifacthub.io/packages/search?repo=volker-raschek)

> [!NOTE]
> This is not the official helm chart of Athens Go Proxy. If you are looking for the official helm chart, checkout the
> GitHub project [gomods/athens-charts](https://github.com/gomods/athens-charts).

This helm chart enables the deployment of [Athens Go Proxy](https://github.com/gomods/athens), a module datastore and
proxy for Golang.

The helm chart supports the individual configuration of additional containers/initContainers, mounting of volumes,
defining additional environment variables and much more.

Chapter [configuration and installation](#helm-configuration-and-installation) describes the basics how to configure
helm and use it to deploy the exporter. It also contains further configuration examples.

Furthermore, this helm chart contains unit tests to detect regressions and stabilize the deployment. Additionally, this
helm chart is tested for deployment scenarios with **ArgoCD**, but please keep in mind, that this chart supports the
*[Automatically Roll Deployment](https://helm.sh/docs/howto/charts_tips_and_tricks/#automatically-roll-deployments)*
concept of Helm, which can trigger unexpected rolling releases. Further configuration instructions are described in a
separate [chapter](#argocd).

## Helm: configuration and installation

1. A helm chart repository must be configured, to pull the helm charts from.
2. All available [parameters](#parameters) are documented in detail below. The parameters can be defined via the helm
   `--set` flag or directly as part of a `values.yaml` file. The following example defines the repository and use the
   `--set` flag for a basic deployment.

```bash
helm repo add volker.raschek https://charts.cryptic.systems/volker.raschek
helm repo update
helm install athens-proxy volker.raschek/athens-proxy
```

Instead of passing all parameters via the *set* flag, it is also possible to define them as part of the `values.yaml`.
The following command downloads the `values.yaml` for a specific version of this chart. Please keep in mind, that the
version of the chart must be in sync with the `values.yaml`. Newer *minor* versions can have new features. New *major*
versions can break something!

```bash
CHART_VERSION=0.3.0
helm show values volker.raschek/athens-proxy --version "${CHART_VERSION}" > values.yaml
```

A complete list of available helm chart versions can be displayed via the following command:

```bash
helm search repo reposilite --versions
```

The helm chart also contains a persistent volume claim definition. It persistent volume claim is not enabled by default.
Use the `--set` argument to persist your data.

```bash
CHART_VERSION=0.3.0
helm install --version "${CHART_VERSION}" athens-proxy volker.raschek/athens-proxy \
  persistence.enabled=true
```

### Examples

The following examples serve as individual configurations and as inspiration for how deployment problems can be solved.

#### Network policies

Network policies can only take effect, when the used CNI plugin support network policies. The chart supports no custom
network policy implementation of CNI plugins. It's support only the official API resource of `networking.k8s.io/v1`.

The example below is an excerpt of the `values.yaml` file. The network policy contains ingress rules to allow incoming
traffic from an ingress controller. Additionally two egress rules are defined. The first one to allow the application
outgoing access to the internal running DNS server `core-dns`. The second rule to be able to access the Apache Maven
Central repository via HTTPS.

> [!IMPORTANT]
> Please keep in mind, that the namespace and pod selector labels can be different from environment to environment. For
> this reason, there is are not default network policy rules defined.

```yaml
networkPolicies:
  enabled: true
  annotations: {}
  labels: {}
  policyTypes:
  - Egress
  - Ingress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP
  - ports:
    - port: 443
      protocol: TCP

  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
      podSelector:
        matchLabels:
          app.kubernetes.io/name: ingress-nginx
    ports:
    - port: http
      protocol: TCP
```

## ArgoCD

### Daily execution of rolling updates

The behavior whereby ArgoCD triggers a rolling update even though nothing appears to have changed often occurs in
connection with the helm concept `checksum/secret`, `checksum/configmap` or more generally, [Automatically Roll
Deployments](https://helm.sh/docs/howto/charts_tips_and_tricks/#automatically-roll-deployments).

The problem with combining this concept with ArgoCD is that ArgoCD re-renders the Helm chart every time. Even if the
content of the config map or secret has not changed, there may be minimal differences (e.g., whitespace, chart version,
Helm render order, different timestamps).

This changes the SHA256 hash, Argo sees a drift and trigger a rolling update of the deployment. Among other things, this
can lead to unnecessary notifications from ArgoCD.

To avoid this, the annotation with the shasum must be ignored. Below is a diff that adds the `Application` to ignore all
annotations with the prefix `checksum`.

```diff
  apiVersion: argoproj.io/v1alpha1
  kind: Application
  spec:
+   ignoreDifferences:
+   - group: apps/v1
+     kind: Deployment
+     jqPathExpressions:
+     - '.spec.template.metadata.annotations | with_entries(select(.key | startswith("checksum")))'
```

## Parameters
