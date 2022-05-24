# athens-proxy-charts

[![Build Status](https://drone.cryptic.systems/api/badges/volker.raschek/athens-proxy-charts/status.svg)](https://drone.cryptic.systems/volker.raschek/athens-proxy-charts)
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
git clone comands with the prefix `http://github.com/` will be replaced by
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

## Access private github.com repositories via developer token

Another way to access private github repositories is via a github token, which
can be set via the environment variable `GITHUB_TOKEN`. Athens automatically
creates a `.netrc` file to access private github repositories.

## Access private repositories via .netrc configuration

As describe above, a `.netrc` file is responsible for the authentication via
HTTP. The file can also be defined via a custom secret and mounted into the home
directory of `root` for general authentication purpose.

The example below describe the definition and mounting of a custom `.netrc` file
to access private repositories hosted on github and gitlab.

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
