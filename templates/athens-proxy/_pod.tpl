---

{{/* annotations */}}

{{- define "athens-proxy.pod.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.pod.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- end }}

{{- define "athens-proxy.pod.selectorLabels" -}}
{{ include "athens-proxy.selectorLabels" . }}
{{- end }}