{{/* vim: set filetype=mustache: */}}

{{/* annotations */}}

{{- define "athens-proxy.ingress.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.ingress.annotations }}
{{ toYaml .Values.ingress.annotations }}
{{- end }}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.ingress.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.ingress.labels }}
{{ toYaml .Values.ingress.labels }}
{{- end }}
{{- end }}
