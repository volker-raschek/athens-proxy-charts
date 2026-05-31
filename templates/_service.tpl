{{/* vim: set filetype=mustache: */}}

{{/* annotations */}}

{{- define "athens-proxy.service.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.service.annotations }}
{{ toYaml .Values.service.annotations }}
{{- end }}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.service.labels" -}}
{{ include "athens-proxy.labels" . }}
{{/* Add label to select the correct service via `selector.matchLabels` of the serviceMonitor resource. */}}
app.kubernetes.io/service-name: http
{{- if .Values.service.labels }}
{{ toYaml .Values.service.labels }}
{{- end }}
{{- end }}

{{/* names */}}

{{- define "athens-proxy.service.name" -}}
{{- if .Values.service.enabled -}}
{{ include "athens-proxy.fullname" . }}
{{- end -}}
{{- end -}}
