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
CHART_VERSION=1.0.0
helm show values volker.raschek/athens-proxy --version "${CHART_VERSION}" > values.yaml
```

A complete list of available helm chart versions can be displayed via the following command:

```bash
helm search repo reposilite --versions
```

The helm chart also contains a persistent volume claim definition. It persistent volume claim is not enabled by default.
Use the `--set` argument to persist your data.

```bash
CHART_VERSION=1.0.0
helm install --version "${CHART_VERSION}" athens-proxy volker.raschek/athens-proxy \
  persistence.enabled=true
```

### Examples

The following examples serve as individual configurations and as inspiration for how deployment problems can be solved.

#### Avoid CPU throttling by defining a CPU limit

If the application is deployed with a CPU resource limit, Prometheus may throw a CPU throttling warning for the
application. This has more or less to do with the fact that the application finds the number of CPUs of the host, but
cannot use the available CPU time to perform computing operations.

The application must be informed that despite several CPUs only a part (limit) of the available computing time is
available. As this is a Golang application, this can be implemented using `GOMAXPROCS`. The following example is one way
of defining `GOMAXPROCS` automatically based on the defined CPU limit like `1000m`. Please keep in mind, that the CFS
rate of `100ms` - default on each kubernetes node, is also very important to avoid CPU throttling.

Further information about this topic can be found in one of Kanishk's blog
[posts](https://kanishk.io/posts/cpu-throttling-in-containerized-go-apps/).

> [!NOTE]
> The environment variable `GOMAXPROCS` is set automatically, when a CPU limit is defined. An explicit configuration is
> not anymore required.
>
> Please take care the a CPU limit < `1000m` can also lead to CPU throttling. Please read the linked documentation carefully.

```bash
CHART_VERSION=1.0.0
helm install --version "${CHART_VERSION}" athens-proxy volker.raschek/athens-proxy \
  --set 'deployment.athensProxy.env.name=GOMAXPROCS' \
  --set 'deployment.athensProxy.env.valueFrom.resourceFieldRef.resource=limits.cpu' \
  --set 'deployment.athensProxy.resources.limits.cpu=1000m'
```

#### Network policies

Network policies can only take effect, when the used CNI plugin support network policies. The chart supports no custom
network policy implementation of CNI plugins. It's support only the official API resource of `networking.k8s.io/v1`.

The example below is an excerpt of the `values.yaml` file. The network policy contains ingress rules to allow incoming
traffic from an ingress controller. Additionally two egress rules are defined. The first one to allow the application
outgoing access to the internal running DNS server `core-dns`. The second rule to be able to access the upstream Go
proxy `https://proxy.golang.org` via HTTPS.

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

### Global

| Name               | Description                               | Value |
| ------------------ | ----------------------------------------- | ----- |
| `nameOverride`     | Individual release name suffix.           | `""`  |
| `fullnameOverride` | Override the complete release name logic. | `""`  |

### Configuration

| Name                                                    | Description                                                                                                                                       | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `config.env.enabled`                                    | Enable mounting of the secret as environment variables.                                                                                           | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `config.env.existingSecret.enabled`                     | Mount an existing secret containing the application specific environment variables.                                                               | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `config.env.existingSecret.secretName`                  | Name of the existing secret containing the application specific environment variables.                                                            | `""`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.env.secret.annotations`                         | Additional annotations of the secret containing the database credentials.                                                                         | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.env.secret.labels`                              | Additional labels of the secret containing the database credentials.                                                                              | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.env.secret.envs`                                | List of environment variables stored in a secret and mounted into the container.                                                                  | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.downloadMode.enabled`                           | Enable mounting of a download mode file into the container file system. If enabled, the env `ATHENS_DOWNLOAD_MODE` will automatically be defined. | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `config.downloadMode.existingConfigMap.enabled`         | Enable to use an external config map for mounting the download mode file.                                                                         | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `config.downloadMode.existingConfigMap.configMapName`   | The name of the existing config map which should be used to mount the download mode file.                                                         | `""`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.downloadMode.existingConfigMap.downloadModeKey` | The name of the key inside the config map where the content of the download mode file is stored.                                                  | `downloadMode`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `config.downloadMode.configMap.annotations`             | Additional annotations of the config map containing the download mode file.                                                                       | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.downloadMode.configMap.labels`                  | Additional labels of the config map containing the download mode file.                                                                            | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.downloadMode.configMap.content`                 | The content of the download mode file.                                                                                                            | `downloadURL = "https://proxy.golang.org"

mode = "async_redirect"

# download "github.com/gomods/*" {
#     mode = "sync"
# }
#
# download "golang.org/x/*" {
#     mode = "none"
# }
#
# download "github.com/pkg/*" {
#     mode = "redirect"
#     downloadURL = "https://proxy.golang.org"
# }
`                                                                                                                                                                                                                                                                                                                                                                           |
| `config.gitConfig.enabled`                              | Enable mounting of a .gitconfig file into the container file system.                                                                              | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `config.gitConfig.existingConfigMap.enabled`            | Enable to use an external config map for mounting the .gitconfig file.                                                                            | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `config.gitConfig.existingConfigMap.configMapName`      | The name of the existing config map which should be used to mount the .gitconfig file.                                                            | `""`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.gitConfig.existingConfigMap.gitConfigKey`       | The name of the key inside the config map where the content of the .gitconfig file is stored.                                                     | `nil`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `config.gitConfig.configMap.annotations`                | Additional annotations of the config map containing the .gitconfig file.                                                                          | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.gitConfig.configMap.labels`                     | Additional labels of the config map containing the .gitconfig file.                                                                               | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.gitConfig.configMap.content`                    | The content of the .gitconfig file.                                                                                                               | `# The .gitconfig file
#
# The .gitconfig file contains the user specific git configuration. It generally resides in the user's home
# directory.
#
# [url "git@github.com:"] insteadOf = https://github.com/
`                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `config.netrc.enabled`                                  | Enable mounting of a .netrc file into the container file system.                                                                                  | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `config.netrc.existingSecret.enabled`                   | Enable to use an external secret for mounting the .netrc file.                                                                                    | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `config.netrc.existingSecret.secretName`                | The name of the existing secret which should be used to mount the .netrc file.                                                                    | `""`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.netrc.existingSecret.netrcKey`                  | The name of the key inside the secret where the content of the .netrc file is stored.                                                             | `.netrc`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `config.netrc.secret.annotations`                       | Additional annotations of the secret containing the database credentials.                                                                         | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.netrc.secret.labels`                            | Additional labels of the secret containing the database credentials.                                                                              | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.netrc.secret.content`                           | The content of the .netrc file.                                                                                                                   | `# The .netrc file
#
# The .netrc file contains login and initialization information used by the auto-login process. It generally
# resides in the user's home directory, but a location outside of the home directory can be set using the
# environment variable NETRC. Both locations are overridden by the command line option -N. The selected file
# must be a regular file, or access will be denied.
#
# https://www.gnu.org/software/inetutils/manual/html_node/The-_002enetrc-file.html
#
# default login           [name]     password  [password/token]
# machine github.com      [octocat]  password  [PAT]
# machine api.github.com  [octocat]  password  [PAT]
` |
| `config.ssh.enabled`                                    | Enable mounting of a .netrc file into the container file system.                                                                                  | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `config.ssh.existingSecret.enabled`                     | Enable to use an external secret for mounting the public and private SSH key files.                                                               | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `config.ssh.existingSecret.secretName`                  | The name of the existing secret which should be used to mount the public and private SSH key files.                                               | `""`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.ssh.existingSecret.configKey`                   | The name of the key inside the secret where the content of the SSH client config file is stored.                                                  | `config`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `config.ssh.existingSecret.id_ed25519Key`               | The name of the key inside the secret where the content of the id_ed25519 key file is stored.                                                     | `id_ed25519`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `config.ssh.existingSecret.id_ed25519PubKey`            | The name of the key inside the secret where the content of the id_ed25519.pub key file is stored.                                                 | `id_ed25519.pub`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| `config.ssh.existingSecret.id_rsaKey`                   | The name of the key inside the secret where the content of the id_rsa key file is stored.                                                         | `id_rsa`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `config.ssh.existingSecret.id_rsaPubKey`                | The name of the key inside the secret where the content of the id_ed25519.pub key file is stored.                                                 | `id_rsa.pub`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `config.ssh.secret.annotations`                         | Additional annotations of the secret containing the public and private SSH key files.                                                             | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.ssh.secret.labels`                              | Additional labels of the secret containing the public and private SSH key files.                                                                  | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `config.ssh.secret.config`                              | The content of the SSH client config file.                                                                                                        | `# Host *
#   IdentityFile ~/.ssh/id_ed25519
#   IdentityFile ~/.ssh/id_rsa
`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |

### Deployment

| Name                                               | Description                                                                                                | Value           |
| -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | --------------- |
| `deployment.annotations`                           | Additional deployment annotations.                                                                         | `{}`            |
| `deployment.labels`                                | Additional deployment labels.                                                                              | `{}`            |
| `deployment.additionalContainers`                  | List of additional containers.                                                                             | `[]`            |
| `deployment.affinity`                              | Affinity for the athens-proxy deployment.                                                                  | `{}`            |
| `deployment.initContainers`                        | List of additional init containers.                                                                        | `[]`            |
| `deployment.dnsConfig`                             | dnsConfig of the athens-proxy deployment.                                                                  | `{}`            |
| `deployment.dnsPolicy`                             | dnsPolicy of the athens-proxy deployment.                                                                  | `""`            |
| `deployment.hostname`                              | Individual hostname of the pod.                                                                            | `""`            |
| `deployment.subdomain`                             | Individual domain of the pod.                                                                              | `""`            |
| `deployment.hostNetwork`                           | Use the kernel network namespace of the host system.                                                       | `false`         |
| `deployment.imagePullSecrets`                      | Secret to use for pulling the image.                                                                       | `[]`            |
| `deployment.athensProxy.args`                      | Arguments passed to the athens-proxy container.                                                            | `[]`            |
| `deployment.athensProxy.command`                   | Command passed to the athens-proxy container.                                                              | `[]`            |
| `deployment.athensProxy.env`                       | List of environment variables for the athens-proxy container.                                              | `[]`            |
| `deployment.athensProxy.envFrom`                   | List of environment variables mounted from configMaps or secrets for the athens-proxy container.           | `[]`            |
| `deployment.athensProxy.image.registry`            | Image registry, eg. `docker.io`.                                                                           | `docker.io`     |
| `deployment.athensProxy.image.repository`          | Image repository, eg. `library/busybox`.                                                                   | `gomods/athens` |
| `deployment.athensProxy.image.tag`                 | Custom image tag, eg. `0.1.0`. Defaults to `appVersion`.                                                   | `""`            |
| `deployment.athensProxy.image.pullPolicy`          | Image pull policy.                                                                                         | `IfNotPresent`  |
| `deployment.athensProxy.resources`                 | CPU and memory resources of the pod.                                                                       | `{}`            |
| `deployment.athensProxy.securityContext`           | Security context of the container of the deployment.                                                       | `{}`            |
| `deployment.athensProxy.volumeMounts`              | Additional volume mounts.                                                                                  | `[]`            |
| `deployment.nodeSelector`                          | NodeSelector of the athens-proxy deployment.                                                               | `{}`            |
| `deployment.priorityClassName`                     | PriorityClassName of the athens-proxy deployment.                                                          | `""`            |
| `deployment.replicas`                              | Number of replicas for the athens-proxy deployment.                                                        | `1`             |
| `deployment.restartPolicy`                         | Restart policy of the athens-proxy deployment.                                                             | `""`            |
| `deployment.securityContext`                       | Security context of the athens-proxy deployment.                                                           | `{}`            |
| `deployment.strategy.type`                         | Strategy type - `Recreate` or `RollingUpdate`.                                                             | `RollingUpdate` |
| `deployment.strategy.rollingUpdate.maxSurge`       | The maximum number of pods that can be scheduled above the desired number of pods during a rolling update. | `1`             |
| `deployment.strategy.rollingUpdate.maxUnavailable` | The maximum number of pods that can be unavailable during a rolling update.                                | `1`             |
| `deployment.terminationGracePeriodSeconds`         | How long to wait until forcefully kill the pod.                                                            | `60`            |
| `deployment.tolerations`                           | Tolerations of the athens-proxy deployment.                                                                | `[]`            |
| `deployment.topologySpreadConstraints`             | TopologySpreadConstraints of the athens-proxy deployment.                                                  | `[]`            |
| `deployment.volumes`                               | Additional volumes to mount into the pods of the prometheus-exporter deployment.                           | `[]`            |

### Horizontal Pod Autoscaler (HPA)

| Name              | Description                                                                                        | Value       |
| ----------------- | -------------------------------------------------------------------------------------------------- | ----------- |
| `hpa.enabled`     | Enable the horizontal pod autoscaler (HPA).                                                        | `false`     |
| `hpa.annotations` | Additional annotations for the HPA.                                                                | `{}`        |
| `hpa.labels`      | Additional labels for the HPA.                                                                     | `{}`        |
| `hpa.metrics`     | Metrics contains the specifications for which to use to calculate the desired replica count.       | `undefined` |
| `hpa.minReplicas` | Min replicas is the lower limit for the number of replicas to which the autoscaler can scale down. | `1`         |
| `hpa.maxReplicas` | Upper limit for the number of pods that can be set by the autoscaler.                              | `10`        |

### Ingress

| Name                  | Description                                                                                                          | Value   |
| --------------------- | -------------------------------------------------------------------------------------------------------------------- | ------- |
| `ingress.enabled`     | Enable creation of an ingress resource. Requires, that the http service is also enabled.                             | `false` |
| `ingress.className`   | Ingress class.                                                                                                       | `nginx` |
| `ingress.annotations` | Additional ingress annotations.                                                                                      | `{}`    |
| `ingress.labels`      | Additional ingress labels.                                                                                           | `{}`    |
| `ingress.hosts`       | Ingress specific configuration. Specification only required when another ingress controller is used instead of `t1k. | `[]`    |
| `ingress.tls`         | Ingress TLS settings. Specification only required when another ingress controller is used instead of `t1k``.         | `[]`    |

### Persistence

| Name                                                                       | Description                                                                                                                                                                                                             | Value                        |
| -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| `persistence.enabled`                                                      | Enable the feature to store the data on a persistent volume claim. If enabled, the volume will be automatically be mounted into the pod. Furthermore, the env `ATHENS_STORAGE_TYPE=disk` will automatically be defined. | `false`                      |
| `persistence.data.mountPath`                                               | The path where the persistent volume should be mounted in the container file system. This variable controls `ATHENS_DISK_STORAGE_ROOT`.                                                                                 | `/var/www/athens-proxy/data` |
| `persistence.data.existingPersistentVolumeClaim.enabled`                   | TODO                                                                                                                                                                                                                    | `false`                      |
| `persistence.data.existingPersistentVolumeClaim.persistentVolumeClaimName` | TODO                                                                                                                                                                                                                    | `""`                         |
| `persistence.data.persistentVolumeClaim.annotations`                       | Additional persistent volume claim annotations.                                                                                                                                                                         | `{}`                         |
| `persistence.data.persistentVolumeClaim.labels`                            | Additional persistent volume claim labels.                                                                                                                                                                              | `{}`                         |
| `persistence.data.persistentVolumeClaim.accessModes`                       | Access modes of the persistent volume claim.                                                                                                                                                                            | `["ReadWriteMany"]`          |
| `persistence.data.persistentVolumeClaim.storageClass`                      | Storage class of the persistent volume claim.                                                                                                                                                                           | `""`                         |
| `persistence.data.persistentVolumeClaim.storageSize`                       | Size of the persistent volume claim.                                                                                                                                                                                    | `5Gi`                        |

### Network Policy

| Name                        | Description                                                               | Value   |
| --------------------------- | ------------------------------------------------------------------------- | ------- |
| `networkPolicy.enabled`     | Enable network policies in general.                                       | `false` |
| `networkPolicy.annotations` | Additional network policy annotations.                                    | `{}`    |
| `networkPolicy.labels`      | Additional network policy labels.                                         | `{}`    |
| `networkPolicy.policyTypes` | List of policy types. Supported is ingress, egress or ingress and egress. | `[]`    |
| `networkPolicy.egress`      | Concrete egress network policy implementation.                            | `[]`    |
| `networkPolicy.ingress`     | Concrete ingress network policy implementation.                           | `[]`    |

### Service

| Name                                     | Description                                                                                                                                                                                                | Value       |
| ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `services.http.enabled`                  | Enable the service.                                                                                                                                                                                        | `true`      |
| `services.http.annotations`              | Additional service annotations.                                                                                                                                                                            | `{}`        |
| `services.http.externalIPs`              | External IPs for the service.                                                                                                                                                                              | `[]`        |
| `services.http.externalTrafficPolicy`    | If `service.type` is `NodePort` or `LoadBalancer`, set this to `Local` to tell kube-proxy to only use node local endpoints for cluster external traffic. Furthermore, this enables source IP preservation. | `Cluster`   |
| `services.http.internalTrafficPolicy`    | If `service.type` is `NodePort` or `LoadBalancer`, set this to `Local` to tell kube-proxy to only use node local endpoints for cluster internal traffic.                                                   | `Cluster`   |
| `services.http.ipFamilies`               | IPFamilies is list of IP families (e.g. `IPv4`, `IPv6`) assigned to this service. This field is usually assigned automatically based on cluster configuration and only required for customization.         | `[]`        |
| `services.http.labels`                   | Additional service labels.                                                                                                                                                                                 | `{}`        |
| `services.http.loadBalancerClass`        | LoadBalancerClass is the class of the load balancer implementation this Service belongs to. Requires service from type `LoadBalancer`.                                                                     | `""`        |
| `services.http.loadBalancerIP`           | LoadBalancer will get created with the IP specified in this field. Requires service from type `LoadBalancer`.                                                                                              | `""`        |
| `services.http.loadBalancerSourceRanges` | Source range filter for LoadBalancer. Requires service from type `LoadBalancer`.                                                                                                                           | `[]`        |
| `services.http.port`                     | Port to forward the traffic to.                                                                                                                                                                            | `3000`      |
| `services.http.sessionAffinity`          | Supports `ClientIP` and `None`. Enable client IP based session affinity via `ClientIP`.                                                                                                                    | `None`      |
| `services.http.sessionAffinityConfig`    | Contains the configuration of the session affinity.                                                                                                                                                        | `{}`        |
| `services.http.type`                     | Kubernetes service type for the traffic.                                                                                                                                                                   | `ClusterIP` |

### ServiceAccount

| Name                                              | Description                                                                                                                                         | Value   |
| ------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `serviceAccount.existing.enabled`                 | Use an existing service account instead of creating a new one. Assumes that the user has all the necessary kubernetes API authorizations.           | `false` |
| `serviceAccount.existing.serviceAccountName`      | Name of the existing service account.                                                                                                               | `""`    |
| `serviceAccount.new.annotations`                  | Additional service account annotations.                                                                                                             | `{}`    |
| `serviceAccount.new.labels`                       | Additional service account labels.                                                                                                                  | `{}`    |
| `serviceAccount.new.automountServiceAccountToken` | Enable/disable auto mounting of the service account token.                                                                                          | `true`  |
| `serviceAccount.new.imagePullSecrets`             | ImagePullSecrets is a list of references to secrets in the same namespace to use for pulling any images in pods that reference this serviceAccount. | `[]`    |
| `serviceAccount.new.secrets`                      | Secrets is the list of secrets allowed to be used by pods running using this ServiceAccount.                                                        | `[]`    |
