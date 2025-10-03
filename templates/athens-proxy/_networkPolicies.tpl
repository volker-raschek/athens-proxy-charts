{{/* vim: set filetype=mustache: */}}

{{/* annotations */}}

{{- define "athens-proxy.networkPolicies.annotations" -}}
{{ include "athens-proxy.annotations" .context }}
{{- if .networkPolicy.annotations }}
{{ toYaml .networkPolicy.annotations }}
{{- end }}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.networkPolicies.labels" -}}
{{ include "athens-proxy.labels" .context }}
{{- if .networkPolicy.labels }}
{{ toYaml .networkPolicy.labels }}
{{- end }}
{{- end }}
