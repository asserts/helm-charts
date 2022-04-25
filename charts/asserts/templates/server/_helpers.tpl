{{/*
server name
*/}}
{{- define "asserts.serverName" -}}
{{- if .Values.server.nameOverride -}}
{{- .Values.server.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ include "asserts.name" . }}-server
{{- end -}}
{{- end -}}

{{/*
server fullname
*/}}
{{- define "asserts.serverFullname" -}}
{{- if .Values.server.fullnameOverride -}}
{{- .Values.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ include "asserts.fullname" . }}-server
{{- end -}}
{{- end -}}

{{/*
server common labels
*/}}
{{- define "asserts.serverLabels" -}}
{{ include "asserts.labels" . }}
app.kubernetes.io/component: server
{{- end }}

{{/*
server selector labels
*/}}
{{- define "asserts.serverSelectorLabels" -}}
{{ include "asserts.selectorLabels" . }}
app.kubernetes.io/component: server
{{- end }}

