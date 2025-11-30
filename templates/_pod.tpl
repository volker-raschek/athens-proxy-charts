---

{{/* annotations */}}

{{- define "athens-proxy.pod.annotations" }}
{{- include "athens-proxy.annotations" . }}
{{- if and .Values.certificate.enabled .Values.certificate.addSHASumAnnotation }}
{{- $secretName := include "athens-proxy.certificates.server.name" $ }}
{{- if and .Values.certificate.existingSecret.enabled (gt (len .Values.certificate.existingSecret.secretName) 0) }}
{{- $secretName = .Values.certificate.existingSecret.secretName }}
{{- end }}
{{- $secret := lookup "v1" "Secret" .Release.Namespace $secretName | toYaml }}
{{ printf "checksum/secret-%s: %s" $secretName ($secret | sha256sum) }}
{{- end }}

{{- if and .Values.config.env.enabled .Values.config.env.addSHASumAnnotation }}
{{- $secretName := include "athens-proxy.secrets.env.name" $ }}
{{- $secret := include (print $.Template.BasePath "/secretEnv.yaml") $ }}
{{- if and .Values.config.env.existingSecret.enabled (gt (len .Values.config.env.existingSecret.secretName) 0) }}
{{- $secretName = .Values.config.env.existingSecret.secretName }}
{{- $secret := lookup "v1" "Secret" .Release.Namespace $secretName | toYaml }}
{{- end }}
{{ printf "checksum/secret-%s: %s" $secretName ($secret | sha256sum) }}
{{- end }}

{{- if and .Values.config.downloadMode.enabled .Values.config.downloadMode.addSHASumAnnotation }}
{{- $configMapName := include "athens-proxy.configMap.downloadMode.name" $ }}
{{- $configMap := include (print $.Template.BasePath "/configMapDownloadMode.yaml") . }}
{{- if and .Values.config.downloadMode.existingConfigMap.enabled (gt (len .Values.config.downloadMode.existingConfigMap.configMapName) 0) }}
{{- $configMapName = .Values.config.downloadMode.existingConfigMap.configMapName }}
{{- $configMap := lookup "v1" "ConfigMap" .Release.Namespace $configMapName | toYaml }}
{{- end }}
{{ printf "checksum/config-map-%s: %s" $configMapName ($configMap | sha256sum) }}
{{- end }}

{{- if and .Values.config.gitConfig.enabled .Values.config.gitConfig.addSHASumAnnotation }}
{{- $configMapName := include "athens-proxy.configMap.gitConfig.name" $ }}
{{- $configMap := include (print $.Template.BasePath "/configMapGitConfig.yaml") . }}
{{- if and .Values.config.gitConfig.existingConfigMap.enabled (gt (len .Values.config.gitConfig.existingConfigMap.configMapName) 0) }}
{{- $configMapName = .Values.config.gitConfig.existingConfigMap.configMapName }}
{{- $configMap := lookup "v1" "ConfigMap" .Release.Namespace $configMapName | toYaml }}
{{- end }}
{{ printf "checksum/config-map-%s: %s" $configMapName ($configMap | sha256sum) }}
{{- end }}

{{- if and .Values.config.netrc.enabled .Values.config.netrc.addSHASumAnnotation }}
{{- $secretName := include "athens-proxy.secrets.netrc.name" $ }}
{{- $secret := include (print $.Template.BasePath "/secretNetRC.yaml") $ }}
{{- if and .Values.config.netrc.existingSecret.enabled (gt (len .Values.config.netrc.existingSecret.secretName) 0) }}
{{- $secretName = .Values.config.netrc.existingSecret.secretName }}
{{- $secret := lookup "v1" "Secret" .Release.Namespace $secretName | toYaml }}
{{- end }}
{{ printf "checksum/secret-%s: %s" $secretName ($secret | sha256sum) }}
{{- end }}

{{- if and .Values.config.ssh.enabled .Values.config.ssh.addSHASumAnnotation }}
{{- $secretName := include "athens-proxy.secrets.ssh.name" $ }}
{{- $secret := include (print $.Template.BasePath "/secretSSH.yaml") $ }}
{{- if and .Values.config.ssh.existingSecret.enabled (gt (len .Values.config.ssh.existingSecret.secretName) 0) }}
{{- $secretName = .Values.config.ssh.existingSecret.secretName }}
{{- $secret := lookup "v1" "Secret" .Release.Namespace $secretName | toYaml }}
{{- end }}
{{ printf "checksum/secret-%s: %s" $secretName ($secret | sha256sum) }}
{{- end }}

{{- end }}

{{/* labels */}}

{{- define "athens-proxy.pod.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- end }}

{{- define "athens-proxy.pod.selectorLabels" -}}
{{ include "athens-proxy.selectorLabels" . }}
{{- end }}