{{/* vim: set filetype=mustache: */}}

{{/* annotations */}}

{{- define "athens-proxy.services.http.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.services.http.annotations }}
{{ toYaml .Values.services.http.annotations }}
{{- end }}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.services.http.labels" -}}
{{ include "athens-proxy.labels" . }}
{{/* Add label to select the correct service via `selector.matchLabels` of the serviceMonitor resource. */}}
app.kubernetes.io/service-name: http
{{- if .Values.services.http.labels }}
{{ toYaml .Values.services.http.labels }}
{{- end }}
{{- end }}

{{/* names */}}

{{- define "athens-proxy.services.http.name" -}}
{{- if .Values.services.http.enabled -}}
{{ include "athens-proxy.fullname" . }}-http
{{- end -}}
{{- end -}}