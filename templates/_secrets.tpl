{{/* vim: set filetype=mustache: */}}

{{/* annotations */}}

{{- define "athens-proxy.secrets.env.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.config.env.secret.annotations }}
{{ toYaml .Values.config.env.secret.annotations }}
{{- end }}
{{- end }}

{{- define "athens-proxy.secrets.netrc.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.config.netrc.secret.annotations }}
{{ toYaml .Values.config.netrc.secret.annotations }}
{{- end }}
{{- end }}

{{- define "athens-proxy.secrets.ssh.annotations" -}}
{{ include "athens-proxy.annotations" . }}
{{- if .Values.config.ssh.secret.annotations }}
{{ toYaml .Values.config.ssh.secret.annotations }}
{{- end }}
{{- end }}

{{/* labels */}}

{{- define "athens-proxy.secrets.env.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.config.env.secret.labels }}
{{ toYaml .Values.config.env.secret.labels }}
{{- end }}
{{- end }}

{{- define "athens-proxy.secrets.netrc.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.config.netrc.secret.labels }}
{{ toYaml .Values.config.netrc.secret.labels }}
{{- end }}
{{- end }}

{{- define "athens-proxy.secrets.ssh.labels" -}}
{{ include "athens-proxy.labels" . }}
{{- if .Values.config.ssh.secret.labels }}
{{ toYaml .Values.config.ssh.secret.labels }}
{{- end }}
{{- end }}

{{/* name */}}

{{- define "athens-proxy.secrets.env.name" -}}
{{ include "athens-proxy.fullname" . }}-env
{{- end }}

{{- define "athens-proxy.secrets.netrc.name" -}}
{{ include "athens-proxy.fullname" . }}-netrc
{{- end }}

{{- define "athens-proxy.secrets.ssh.name" -}}
{{ include "athens-proxy.fullname" . }}-ssh
{{- end }}
