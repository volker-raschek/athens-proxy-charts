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
{{- if and (hasKey .Values.deployment.athensProxy.resources "limits") (hasKey .Values.deployment.athensProxy.resources.limits "cpu") }}
{{- $env = concat $env (list (dict "name" "GOMAXPROCS" "valueFrom" (dict "resourceFieldRef" (dict "divisor" "1" "resource" "limits.cpu")))) }}
{{- end }}
{{ toYaml (dict "env" $env) }}
{{- end -}}


{{/* envFrom */}}

{{- define "athens-proxy.deployment.envFrom" -}}
{{- end -}}

{{/* image */}}

{{- define "athens-proxy.deployment.images.athens-proxy.fqin" -}}
{{- $registry := .Values.deployment.athensProxy.image.registry -}}
{{- $repository := .Values.deployment.athensProxy.image.repository -}}
{{- $tag := default .Chart.AppVersion .Values.deployment.athensProxy.image.tag -}}
{{- printf "%s/%s:v%s" $registry $repository $tag -}}
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

{{- if .Values.config.netrc.enabled }}
{{- $volumeMounts = concat $volumeMounts (list (dict "name" "secrets" "mountPath" "/root/.netrc" "subPath" ".netrc" )) }}
{{- end }}

{{ toYaml (dict "volumeMounts" $volumeMounts) }}
{{- end -}}

{{/* volumes */}}

{{- define "athens-proxy.deployment.volumes" -}}
{{- $volumes := .Values.deployment.athensProxy.volumes | default (list) }}

{{- if .Values.persistence.enabled }}
{{- $claimName := include "athens-proxy.persistentVolumeClaim.data.name" $ }}
{{- if .Values.persistence.data.existingPersistentVolumeClaim.enabled }}
{{- $claimName = .Values.persistence.data.existingPersistentVolumeClaim.persistentVolumeClaimName }}
{{- end }}
{{- $volumes = concat $volumes (list (dict "name" "data" "persistentVolumeClaim" (dict "claimName" $claimName))) }}
{{- end }}

{{- if .Values.config.netrc.enabled }}
{{- $projectedSources := list -}}

{{- $itemList := list (dict "key" ".netrc" "path" ".netrc" "mode" 0600) }}
{{- $secretName := include "athens-proxy.secrets.netrc.name" . }}
{{- if .Values.config.netrc.existingSecret.enabled }}
{{- $itemList = list (dict "key" .Values.config.netrc.existingSecret.netrcKey "path" ".netrc" "mode" 0600) }}
{{- $secretName = .Values.config.netrc.existingSecret.secretName }}
{{- end }}
{{- $projectedSources = concat $projectedSources (list (dict "secret" (dict "name" $secretName "items" $itemList))) }}


{{- $volumes = concat $volumes (list (dict "name" "secrets" "projected" (dict "sources" $projectedSources)))}}
{{- end }}

{{ toYaml (dict "volumes" $volumes) }}
{{- end -}}