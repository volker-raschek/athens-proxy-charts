---

{{/* annotations */}}

{{- define "athens-proxy.configMap.downloadMode.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.config.downloadMode.configMap.annotations }}
{{ toYaml .Values.config.downloadMode.configMap.annotations }}
{{- end }}
{{- end }}

{{- define "athens-proxy.configMap.gitConfig.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.config.gitConfig.configMap.annotations }}
{{ toYaml .Values.config.gitConfig.configMap.annotations }}
{{- end }}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.configMap.downloadMode.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.config.downloadMode.configMap.labels }}
{{ toYaml .Values.config.downloadMode.configMap.labels }}
{{- end }}
{{- end }}

{{- define "athens-proxy.configMap.gitConfig.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.config.gitConfig.configMap.labels }}
{{ toYaml .Values.config.gitConfig.configMap.labels }}
{{- end }}
{{- end }}

{{/* name */}}

{{- define "athens-proxy.configMap.downloadMode.name" -}}
{{ include "athens-proxy.fullname" . }}-download-mode-file
{{- end }}

{{- define "athens-proxy.configMap.gitConfig.name" -}}
{{ include "athens-proxy.fullname" . }}-gitconfig
{{- end }}