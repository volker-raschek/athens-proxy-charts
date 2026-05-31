{{/* vim: set filetype=mustache: */}}

{{/* annotations */}}

{{- define "athens-proxy.clientSettingsPolicy.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.gatewayAPI.nginx.clientSettingsPolicy.annotations }}
{{ toYaml .Values.gatewayAPI.nginx.clientSettingsPolicy.annotations }}
{{- end }}
{{- end }}

{{/* enabled */}}

{{- define "athens-proxy.clientSettingsPolicy.enabled" -}}
{{- if and (eq (include "athens-proxy.httpRoute.enabled" $) "true")
           .Values.gatewayAPI.nginx.clientSettingsPolicy.enabled
-}}
true
{{- else -}}
false
{{- end -}}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.clientSettingsPolicy.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.gatewayAPI.nginx.clientSettingsPolicy.labels }}
{{ toYaml .Values.gatewayAPI.nginx.clientSettingsPolicy.labels }}
{{- end }}
{{- end }}
