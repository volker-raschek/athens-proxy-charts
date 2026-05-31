{{/* vim: set filetype=mustache: */}}

{{/* annotations */}}

{{- define "athens-proxy.backendTLSPolicy.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.gatewayAPI.core.backendTLSPolicy.annotations }}
{{ toYaml .Values.gatewayAPI.core.backendTLSPolicy.annotations }}
{{- end }}
{{- end }}

{{/* enabled */}}

{{- define "athens-proxy.backendTLSPolicy.enabled" -}}
{{- if and .Values.gatewayAPI.enabled
           .Values.gatewayAPI.core.backendTLSPolicy.enabled
           .Values.service.enabled
-}}
true
{{- else -}}
false
{{- end -}}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.backendTLSPolicy.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.gatewayAPI.core.backendTLSPolicy.labels }}
{{ toYaml .Values.gatewayAPI.core.backendTLSPolicy.labels }}
{{- end }}
{{- end }}
