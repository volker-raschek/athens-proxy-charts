# athens-proxy-charts

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/volker-raschek)](https://artifacthub.io/packages/search?repo=volker-raschek)

This is an inofficial helm chart of the go-proxy
[athens](https://github.com/gomods/athens) which supports more complex
configuration options.

This helm chart can be found on [artifacthub.io](https://artifacthub.io/) and
can be installed via helm.

```bash
helm repo add volker.raschek https://charts.cryptic.systems/volker.raschek
helm install athens-proxy volker.raschek/athens-proxy
```

## Customization

The complete deployment can be adapted via the `values.yaml` files. The
configuration of the proxy can be done via the environment variables described
below or via mounting the config.toml as additional persistent volume to
`/config/config.toml`

## Access private repositories via SSH

Create a `configmap.yaml` with multiple keys. One key describe the content of
the `.gitconfig` file and another of `config` of the ssh client. All requests
Git clone comands with the prefix `http://github.com/` will be replaced by
`git@github.com:` to use SSH instead of HTTPS. The SSH keys are stored in a
separate secret.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-configs
data:
  sshconfig: |
    Host github.com
      IdentityFile /root/.ssh/id_ed25519
      StrictHostKeyChecking no
  gitconfig: |
    [url "git@github.com:"]
      insteadOf = https://github.com/
```

The secret definition below contains the SSH private and public key.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: custom-ssh-keys
type: Opaque
stringData:
  id_ed25519: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
    QyNTUxOQAAACCpf/10TWlksg6/5mZF067fTGvW71I5QVJEp/nyC8hVHgAAAJgwWWNdMFlj
    XQAAAAtzc2gtZWQyNTUxOQAAACCpf/10TWlksg6/5mZF067fTGvW71I5QVJEp/nyC8hVHg
    AAAEDzTPitanzgl6iThoFCx8AXwsGLS5Q+3+K66ZOmN0p6+6l//XRNaWSyDr/mZkXTrt9M
    a9bvUjlBUkSn+fILyFUeAAAAEG1hcmt1c0BtYXJrdXMtcGMBAgMEBQ==
    -----END OPENSSH PRIVATE KEY-----
  id_ed25519.pub: |
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKl//XRNaWSyDr/mZkXTrt9Ma9bvUjlBUkSn+fILyFUe
```

The item `config` of the configmap will be merged with the items of the secret
as virtual volume. This volume can than be mounted with special permissions
required for the ssh client.

```yaml
extraVolumes:
- name: ssh
  projected:
    defaultMode: 0644
    sources:
    - configMap:
        name: custom-configs
        items:
        - key: sshconfig
          path: config
    - secret:
        name: custom-ssh-keys
        items:
        - key: id_ed25519
          path: id_ed25519
          mode: 0600
        - key: id_ed25519.pub
          path: id_ed25519.pub
- name: gitconfig
  configMap:
    name: custom-configs
    items:
    - key: gitconfig
      path: config
      mode: 0644

extraVolumeMounts:
- name: ssh
  mountPath: /root/.ssh
- name: gitconfig
  mountPath: /root/.config/git
```

## Access private GitHub.com repositories via developer token

Another way to access private GitHub repositories is via a GitHub token, which
can be set via the environment variable `GITHUB_TOKEN`. Athens automatically
creates a `.netrc` file to access private GitHub repositories.

## Access private repositories via .netrc configuration

As describe above, a `.netrc` file is responsible for the authentication via
HTTP. The file can also be defined via a custom secret and mounted into the home
directory of `root` for general authentication purpose.

The example below describe the definition and mounting of a custom `.netrc` file
to access private repositories hosted on GitHub and GitLab.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: custom-netrc
type: Opaque
stringData:
  netrc: |
    machine github.com login USERNAME password API-KEY
    machine gitlab.com login USERNAME password API-KEY
```

The file must then be mounted via extraVolumes and extraVolumeMounts.

```yaml
extraVolumes:
- name: netrc
  secret:
    secretName: custom-netrc
    items:
    - key: netrc
      path: .netrc
      mode: 0600

extraVolumeMounts:
- name: netrc
  mountPath: /root
```

## Persistent storage

Unlike the athens default, the default here is `disk` - i.e. the files are
written to the container. Therefore, it is advisable to outsource the
corresponding storage location to persistent storage. The following example
describes the integration of a persistent storage claim.

```yaml
extraVolumes:
- name: gomodules
  persistentVolumeClaim:
    claimName: custom-gomodules-pvc

extraVolumeMounts:
- name: gomodules
  mountPath: /var/lib/athens
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
#     downloadURL = "https://gocenter.io"
# }
`                                                                                                                                                                                                                                                                                                                                                                                |
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

### NetworkPolicies

| Name                                  | Description                                                                                           | Value   |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------- | ------- |
| `networkPolicies.enabled`             | Enable network policies in general.                                                                   | `false` |
| `networkPolicies.default.enabled`     | Enable the network policy for accessing the application by default. For example to scape the metrics. | `false` |
| `networkPolicies.default.annotations` | Additional network policy annotations.                                                                | `{}`    |
| `networkPolicies.default.labels`      | Additional network policy labels.                                                                     | `{}`    |
| `networkPolicies.default.policyTypes` | List of policy types. Supported is ingress, egress or ingress and egress.                             | `[]`    |
| `networkPolicies.default.egress`      | Concrete egress network policy implementation.                                                        | `[]`    |
| `networkPolicies.default.ingress`     | Concrete ingress network policy implementation.                                                       | `[]`    |

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
