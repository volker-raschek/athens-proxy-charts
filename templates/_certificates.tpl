{{/* vim: set filetype=mustache: */}}

{{/* annotations */}}

{{- define "athens-proxy.certificates.server.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.certificate.new.annotations }}
{{ toYaml .Values.certificate.new.annotations }}
{{- end }}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.certificates.server.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.certificate.new.labels }}
{{ toYaml .Values.certificate.new.labels }}
{{- end }}
{{- end }}

{{/* names */}}

{{- define "athens-proxy.certificates.server.name" -}}
{{ include "athens-proxy.fullname" . }}-tls
{{- end -}}