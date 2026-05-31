{{/* vim: set filetype=mustache: */}}

{{/* annotations */}}

{{- define "athens-proxy.serviceAccount.annotations" -}}
{{- if .Values.serviceAccount.new.annotations }}
{{ toYaml .Values.serviceAccount.new.annotations }}
{{- end }}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.serviceAccount.labels" -}}
{{- if .Values.serviceAccount.new.labels }}
{{ toYaml .Values.serviceAccount.new.labels }}
{{- end }}
{{- end }}