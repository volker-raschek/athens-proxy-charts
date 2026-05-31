{{/* vim: set filetype=mustache: */}}

{{/* annotations */}}

{{- define "athens-proxy.networkPolicy.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.networkPolicy.annotations }}
{{ toYaml .Values.networkPolicy.annotations }}
{{- end }}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.networkPolicy.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.networkPolicy.labels }}
{{ toYaml .Values.networkPolicy.labels }}
{{- end }}
{{- end }}
