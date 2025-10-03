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
{{- $env := dict "env" (.Values.deployment.athensProxy.env | default (list) ) }}
{{- if and .Values.persistence.enabled }}
{{- $env = merge $env (dict "env" (list (dict "name" "ATHENS_STORAGE_TYPE" "value" "disk") (dict "name" "ATHENS_DISK_STORAGE_ROOT" "value" .Values.persistence.data.mountPath)))}}
{{- end }}
{{- if and (hasKey .Values.deployment.athensProxy.resources "limits") (hasKey .Values.deployment.athensProxy.resources.limits "cpu") }}
{{- $env = merge $env (dict "env" (list (dict "name" "GOMAXPROCS" "valueFrom" (dict "resourceFieldRef" (dict "divisor" "1" "resource" "limits.cpu"))))) }}
{{- end }}
{{ toYaml $env }}
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
{{- $volumeMounts := dict "volumeMounts" (.Values.deployment.athensProxy.volumeMounts | default (list) ) }}
{{- if .Values.persistence.enabled }}
{{- $volumeMounts = merge $volumeMounts (dict "volumeMounts" (list (dict "name" "data" "mountPath" .Values.persistence.data.mountPath))) }}
{{- end }}
{{ toYaml $volumeMounts }}
{{- end -}}

{{/* volumes */}}

{{- define "athens-proxy.deployment.volumes" -}}
{{- $volumes := dict "volumes" (.Values.deployment.athensProxy.volumes | default (list) ) }}
{{- if and .Values.persistence.enabled (not .Values.persistence.data.existingPersistentVolumeClaim.enabled) }}
{{- $volumes = merge $volumes (dict "volumes" (list (dict "name" "data" "persistentVolumeClaim" (dict "claimName" (include "athens-proxy.persistentVolumeClaim.data.name" $))))) }}
{{- else if and .Values.persistence.enabled .Values.persistence.data.existingPersistentVolumeClaim.enabled }}
{{- $volumes = merge $volumes (dict "volumes" (list (dict "name" "data" "persistentVolumeClaim" (dict "claimName" .Values.persistence.data.existingPersistentVolumeClaim.persistentVolumeClaimName)))) }}
{{- end }}
{{ toYaml $volumes }}
{{- end -}}