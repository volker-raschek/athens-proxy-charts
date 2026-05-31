{{/* vim: set filetype=mustache: */}}

{{/* annotations */}}

{{- define "athens-proxy.persistentVolumeClaim.data.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.persistence.data.persistentVolumeClaim.annotations }}
{{ toYaml .Values.persistence.data.persistentVolumeClaim.annotations}}
{{- end }}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.persistentVolumeClaim.data.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.persistence.data.persistentVolumeClaim.labels }}
{{ toYaml .Values.persistence.data.persistentVolumeClaim.labels}}
{{- end }}
{{- end }}

{{/* name */}}

{{- define "athens-proxy.persistentVolumeClaim.data.name" -}}
{{ include "athens-proxy.fullname" . }}-data
{{- end }}
