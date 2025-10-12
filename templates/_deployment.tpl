{{/* vim: set filetype=mustache: */}}

{{/* annotations */}}

{{- define "athens-proxy.deployment.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.deployment.annotations }}
{{ toYaml .Values.deployment.annotations }}
{{- end }}
{{- end }}

{{/* env */}}

{{- define "athens-proxy.deployment.env" -}}
{{- $env := .Values.deployment.athensProxy.env | default (list) }}

{{- if and .Values.persistence.enabled }}
{{- $env = concat $env (list (dict "name" "ATHENS_STORAGE_TYPE" "value" "disk") (dict "name" "ATHENS_DISK_STORAGE_ROOT" "value" .Values.persistence.data.mountPath)) }}
{{- end }}

{{- if .Values.config.downloadMode.enabled }}
{{- $env = concat $env (list (dict "name" "ATHENS_DOWNLOAD_MODE" "value" "file:/etc/athens/config/download-mode.d/download-mode")) }}
{{- end }}

{{- if and (hasKey .Values.deployment.athensProxy.resources "limits") (hasKey .Values.deployment.athensProxy.resources.limits "cpu") }}
{{- $env = concat $env (list (dict "name" "GOMAXPROCS" "valueFrom" (dict "resourceFieldRef" (dict "divisor" "1" "resource" "limits.cpu")))) }}
{{- end }}

{{ toYaml (dict "env" $env) }}

{{- end -}}


{{/* envFrom */}}

{{- define "athens-proxy.deployment.envFrom" -}}
{{- $envFrom := .Values.deployment.athensProxy.envFrom | default (list) }}

{{- if .Values.config.env.enabled }}
{{- $secretName := include "athens-proxy.secrets.env.name" $ }}
{{- if and .Values.config.env.existingSecret.enabled (gt (len .Values.config.env.existingSecret.secretName) 0)}}
{{- $secretName = .Values.config.env.existingSecret.secretName }}
{{- end }}
{{- $envFrom = concat $envFrom (list (dict "secretRef" (dict "name" $secretName))) }}
{{- end }}

{{ toYaml (dict "envFrom" $envFrom) }}

{{- end -}}

{{/* image */}}

{{- define "athens-proxy.deployment.images.athens-proxy.fqin" -}}
{{- $registry := .Values.deployment.athensProxy.image.registry -}}
{{- $repository := .Values.deployment.athensProxy.image.repository -}}
{{- $tag := default .Chart.AppVersion .Values.deployment.athensProxy.image.tag -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end -}}

{{/* labels */}}

{{- define "athens-proxy.deployment.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.deployment.labels }}
{{ toYaml .Values.deployment.labels }}
{{- end }}
{{- end }}

{{/* serviceAccount */}}

{{- define "athens-proxy.deployment.serviceAccount" -}}
{{- if .Values.serviceAccount.existing.enabled -}}
{{- printf "%s" .Values.serviceAccount.existing.serviceAccountName -}}
{{- else -}}
{{- include "athens-proxy.fullname" . -}}
{{- end -}}
{{- end }}

{{/* volumeMounts */}}

{{- define "athens-proxy.deployment.volumeMounts" -}}
{{- $volumeMounts := .Values.deployment.athensProxy.volumeMounts | default (list) }}

{{- if .Values.persistence.enabled }}
{{- $volumeMounts = concat $volumeMounts (list (dict "name" "data" "mountPath" .Values.persistence.data.mountPath)) }}
{{- end }}

{{/* volumes (download mode) */}}
{{- if .Values.config.downloadMode.enabled }}
{{- $volumeMounts = concat $volumeMounts (list (dict "name" "download-mode" "mountPath" "/etc/athens/config/download-mode.d" )) }}
{{- end }}

{{/* volumeMount (git config) */}}
{{- if .Values.config.gitConfig.enabled }}
{{- $volumeMounts = concat $volumeMounts (list (dict "name" "secrets" "mountPath" "/root/.gitconfig" "subPath" ".gitconfig" )) }}
{{- end }}

{{/* volumeMount (netrc) */}}
{{- if .Values.config.netrc.enabled }}
{{- $volumeMounts = concat $volumeMounts (list (dict "name" "secrets" "mountPath" "/root/.netrc" "subPath" ".netrc" )) }}
{{- end }}

{{/* volumeMount (ssh) */}}
{{- if and .Values.config.ssh.enabled }}
{{- if or (and (not .Values.config.ssh.existingSecret.enabled) (gt (len .Values.config.ssh.secret.config) 0)) (and .Values.config.ssh.existingSecret.enabled (gt (len .Values.config.ssh.existingSecret.configKey) 0)) }}
{{- $volumeMounts = concat $volumeMounts (list (dict "name" "secrets" "mountPath" "/root/.ssh/config" "subPath" "config" )) }}
{{- end }}

{{- if or (and (not .Values.config.ssh.existingSecret.enabled) (gt (len .Values.config.ssh.secret.id_ed25519) 0)) (and .Values.config.ssh.existingSecret.enabled (gt (len .Values.config.ssh.existingSecret.id_ed25519Key) 0)) }}
{{- $volumeMounts = concat $volumeMounts (list (dict "name" "secrets" "mountPath" "/root/.ssh/id_ed25519" "subPath" "id_ed25519" )) }}
{{- end }}

{{- if or (and (not .Values.config.ssh.existingSecret.enabled) (gt (len .Values.config.ssh.secret.id_ed25519_pub) 0)) (and .Values.config.ssh.existingSecret.enabled (gt (len .Values.config.ssh.existingSecret.id_ed25519PubKey) 0)) }}
{{- $volumeMounts = concat $volumeMounts (list (dict "name" "secrets" "mountPath" "/root/.ssh/id_ed25519.pub" "subPath" "id_ed25519.pub" )) }}
{{- end }}

{{- if or (and (not .Values.config.ssh.existingSecret.enabled) (gt (len .Values.config.ssh.secret.id_rsa) 0)) (and .Values.config.ssh.existingSecret.enabled (gt (len .Values.config.ssh.existingSecret.id_rsaKey) 0)) }}
{{- $volumeMounts = concat $volumeMounts (list (dict "name" "secrets" "mountPath" "/root/.ssh/id_rsa" "subPath" "id_rsa" )) }}
{{- end }}

{{- if or (and (not .Values.config.ssh.existingSecret.enabled) (gt (len .Values.config.ssh.secret.id_rsa_pub) 0)) (and .Values.config.ssh.existingSecret.enabled (gt (len .Values.config.ssh.existingSecret.id_rsaPubKey) 0)) }}
{{- $volumeMounts = concat $volumeMounts (list (dict "name" "secrets" "mountPath" "/root/.ssh/id_rsa.pub" "subPath" "id_rsa.pub" )) }}
{{- end }}

{{- end }}

{{ toYaml (dict "volumeMounts" $volumeMounts) }}
{{- end -}}

{{/* volumes */}}

{{- define "athens-proxy.deployment.volumes" -}}
{{- $volumes := .Values.deployment.volumes | default (list) }}


{{/* volumes (data) */}}
{{- if .Values.persistence.enabled }}
{{- $claimName := include "athens-proxy.persistentVolumeClaim.data.name" $ }}
{{- if .Values.persistence.data.existingPersistentVolumeClaim.enabled }}
{{- $claimName = .Values.persistence.data.existingPersistentVolumeClaim.persistentVolumeClaimName }}
{{- end }}
{{- $volumes = concat $volumes (list (dict "name" "data" "persistentVolumeClaim" (dict "claimName" $claimName))) }}
{{- end }}


{{/* volumes (download mode) */}}
{{- if .Values.config.downloadMode.enabled }}
{{- $itemList := list (dict "key" "downloadMode" "path" "download-mode" "mode" 0644) }}
{{- $configMapName := include "athens-proxy.configMap.downloadMode.name" $ }}
{{- if and .Values.config.downloadMode.existingConfigMap.enabled (gt (len .Values.config.downloadMode.existingConfigMap.configMapName) 0) }}
{{- $itemList = list (dict "key" .Values.config.downloadMode.existingConfigMap.downloadModeKey "path" "download-mode" "mode" 0644) }}
{{- $configMapName = .Values.config.downloadMode.existingConfigMap.configMapName }}
{{- end }}
{{- $volumes = concat $volumes (list (dict "name" "download-mode" "configMap" (dict "name" $configMapName "items" $itemList))) }}
{{- end }}


{{/* volumes (git config) */}}
{{- $projectedSecretSources := list -}}

{{- if .Values.config.gitConfig.enabled }}
{{- $itemList := list (dict "key" ".gitconfig" "path" ".gitconfig" "mode" 0644) }}
{{- $configMapName := include "athens-proxy.configMap.gitConfig.name" . }}
{{- if .Values.config.gitConfig.existingConfigMap.enabled }}
{{- $itemList = list (dict "key" .Values.config.gitConfig.existingConfigMap.gitConfigKey "path" ".gitconfig" "mode" 0644) }}
{{- $configMapName = .Values.config.gitConfig.existingConfigMap.configMapName }}
{{- end }}
{{- $projectedSecretSources = concat $projectedSecretSources (list (dict "configMap" (dict "name" $configMapName "items" $itemList))) }}

{{- end }}

{{/* volumes (netrc) */}}

{{- if .Values.config.netrc.enabled }}
{{- $itemList := list (dict "key" ".netrc" "path" ".netrc" "mode" 0600) }}
{{- $secretName := include "athens-proxy.secrets.netrc.name" . }}
{{- if .Values.config.netrc.existingSecret.enabled }}
{{- $itemList = list (dict "key" .Values.config.netrc.existingSecret.netrcKey "path" ".netrc" "mode" 0600) }}
{{- $secretName = .Values.config.netrc.existingSecret.secretName }}
{{- end }}
{{- $projectedSecretSources = concat $projectedSecretSources (list (dict "secret" (dict "name" $secretName "items" $itemList))) }}

{{- end }}

{{/* volumes (ssh) */}}
{{- if .Values.config.ssh.enabled }}

{{- $itemList := list -}}
{{- $secretName := include "athens-proxy.secrets.ssh.name" . }}

{{- if and .Values.config.ssh.existingSecret.enabled .Values.config.ssh.existingSecret.secretName }}
{{- $secretName = .Values.config.ssh.existingSecret.secretName }}

{{- if gt (len .Values.config.ssh.existingSecret.configKey) 0 }}
{{- $configItem := dict "key" .Values.config.ssh.existingSecret.configKey "path" "config" "mode" 0600 }}
{{- $itemList = concat $itemList (list $configItem) }}
{{- end }}

{{- if gt (len .Values.config.ssh.existingSecret.id_ed25519Key) 0 }}
{{- $idED25519Item := dict "key" .Values.config.ssh.existingSecret.id_ed25519Key "path" "id_ed25519" "mode" 0600 }}
{{- $itemList = concat $itemList (list $idED25519Item) }}
{{- end }}

{{- if gt (len .Values.config.ssh.existingSecret.id_ed25519PubKey) 0 }}
{{- $idED25519PubItem := dict "key" .Values.config.ssh.existingSecret.id_ed25519PubKey "path" "id_ed25519.pub" "mode" 0644 }}
{{- $itemList = concat $itemList (list $idED25519PubItem) }}
{{- end }}

{{- if gt (len .Values.config.ssh.existingSecret.id_rsaKey) 0 }}
{{- $idRSAItem := dict "key" .Values.config.ssh.existingSecret.id_rsaKey "path" "id_rsa" "mode" 0600 }}
{{- $itemList = concat $itemList (list $idRSAItem) }}
{{- end }}

{{- if gt (len .Values.config.ssh.existingSecret.id_rsaPubKey) 0 }}
{{- $idRSAPubItem := dict "key" .Values.config.ssh.existingSecret.id_rsaPubKey "path" "id_rsa.pub" "mode" 0644 }}
{{- $itemList = concat $itemList (list $idRSAPubItem) }}
{{- end }}
{{- end }}

{{- if not .Values.config.ssh.existingSecret.enabled }}
{{- if gt (len .Values.config.ssh.secret.config) 0 }}
{{- $configItem := dict "key" "config" "path" "config" "mode" 0600 }}
{{- $itemList = concat $itemList (list $configItem) }}
{{- end }}

{{- if gt (len .Values.config.ssh.secret.id_ed25519) 0 }}
{{- $idED25519Item := dict "key" "id_ed25519" "path" "id_ed25519" "mode" 0600 }}
{{- $itemList = concat $itemList (list $idED25519Item) }}
{{- end }}

{{- if gt (len .Values.config.ssh.secret.id_ed25519_pub) 0 }}
{{- $idED25519PubItem := dict "key" "id_ed25519.pub" "path" "id_ed25519.pub" "mode" 0644 }}
{{- $itemList = concat $itemList (list $idED25519PubItem) }}
{{- end }}

{{- if gt (len .Values.config.ssh.secret.id_rsa) 0 }}
{{- $idRSAItem := dict "key" "id_rsa" "path" "id_rsa" "mode" 0600 }}
{{- $itemList = concat $itemList (list $idRSAItem) }}
{{- end }}

{{- if gt (len .Values.config.ssh.secret.id_rsa_pub) 0 }}
{{- $idRSAPubItem := dict "key" "id_rsa.pub" "path" "id_rsa.pub" "mode" 0644 }}
{{- $itemList = concat $itemList (list $idRSAPubItem) }}
{{- end }}
{{- end }}

{{- $projectedSecretSources = concat $projectedSecretSources (list (dict "secret" (dict "name" $secretName "items" $itemList))) }}
{{- end }}

{{- if gt (len $projectedSecretSources) 0 }}
{{- $projectedSecretVolume := dict "name" "secrets" "projected" (dict "sources" $projectedSecretSources) }}
{{- $volumes = concat $volumes (list $projectedSecretVolume) }}
{{- end }}

{{ toYaml (dict "volumes" $volumes) }}
{{- end -}}