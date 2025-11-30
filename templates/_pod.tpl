---

{{/* annotations */}}

{{- define "athens-proxy.pod.annotations" }}
{{- include "athens-proxy.annotations" . }}
{{- if and .Values.certificate.enabled (not .Values.certificate.existingSecret.enabled) }}
{{- $secretName := include "athens-proxy.certificates.server.name" $ }}
{{- $secret := lookup "v1" "Secret" .Release.Namespace $secretName }}
{{ printf "checksum/secret-%s: %s" $secretName ($secret | toYaml | sha256sum) }}
{{- end }}
{{- if and .Values.config.env.enabled (not .Values.config.env.existingSecret.enabled) }}
{{ printf "checksum/secret-%s: %s" (include "athens-proxy.secrets.env.name" $) (include (print $.Template.BasePath "/secretEnv.yaml") . | sha256sum) }}
{{- end }}
{{- if and .Values.config.downloadMode.enabled (not .Values.config.downloadMode.existingConfigMap.enabled) }}
{{ printf "checksum/config-map-%s: %s" (include "athens-proxy.configMap.downloadMode.name" $) (include (print $.Template.BasePath "/configMapDownloadMode.yaml") . | sha256sum) }}
{{- end }}
{{- if and .Values.config.gitConfig.enabled (not .Values.config.gitConfig.existingConfigMap.enabled) }}
{{ printf "checksum/config-map-%s: %s" (include "athens-proxy.configMap.gitConfig.name" $) (include (print $.Template.BasePath "/configMapGitConfig.yaml") . | sha256sum) }}
{{- end }}
{{- if and .Values.config.netrc.enabled (not .Values.config.netrc.existingSecret.enabled) }}
{{ printf "checksum/secret-%s: %s" (include "athens-proxy.secrets.netrc.name" $) (include (print $.Template.BasePath "/secretNetRC.yaml") . | sha256sum) }}
{{- end }}
{{- if and .Values.config.ssh.enabled (not .Values.config.ssh.existingSecret.enabled) }}
{{ printf "checksum/secret-%s: %s" (include "athens-proxy.secrets.ssh.name" $) (include (print $.Template.BasePath "/secretSSH.yaml") . | sha256sum) }}
{{- end }}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.pod.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- end }}

{{- define "athens-proxy.pod.selectorLabels" -}}
{{ include "athens-proxy.selectorLabels" . }}
{{- end }}