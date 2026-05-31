{{/* vim: set filetype=mustache: */}}

{{/* annotations */}}

{{- define "athens-proxy.httpRoute.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.gatewayAPI.core.httpRoute.annotations }}
{{ toYaml .Values.gatewayAPI.core.httpRoute.annotations }}
{{- end }}
{{- end }}

{{/* enabled */}}

{{- define "athens-proxy.httpRoute.enabled" -}}
{{- if and .Values.gatewayAPI.enabled
           .Values.gatewayAPI.core.httpRoute.enabled
           .Values.service.enabled
-}}
true
{{- else -}}
false
{{- end -}}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.httpRoute.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.gatewayAPI.core.httpRoute.labels }}
{{ toYaml .Values.gatewayAPI.core.httpRoute.labels }}
{{- end }}
{{- end }}
