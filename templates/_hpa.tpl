---

{{/* annotations */}}

{{- define "athens-proxy.hpa.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.hpa.annotations }}
{{ toYaml .Values.hpa.annotations }}
{{- end }}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.hpa.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.hpa.labels }}
{{ toYaml .Values.hpa.labels }}
{{- end }}
{{- end }}
