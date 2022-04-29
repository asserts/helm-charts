{{/*
Expand the name of the chart.
*/}}
{{- define "asserts.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "asserts.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "asserts.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "asserts.labels" -}}
helm.sh/chart: {{ include "asserts.chart" . }}
{{ include "asserts.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "asserts.selectorLabels" -}}
app.kubernetes.io/name: {{ include "asserts.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "asserts.serviceAccountName" -}}
asserts
{{- end }}

{{/*
Return  the proper Storage Class
{{ include "asserts.storageClass"  . }}
*/}}
{{- define "asserts.storageClass" -}}

{{- $storageClass := .Values.server.persistence.storageClass -}}
{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}

{{- end -}}

{{/*
The asserts tenant name
{{ include "asserts.tenant"  . }}
*/}}
{{- define "asserts.tenant" -}}
bootstrap
{{- end }}

{{/*
Renders a value that contains template.
Usage:
{{ include "render-values" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "render-values" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Return the domain to use
{{ include "domain"  . }}
*/}}
{{- define "domain" -}}
{{ .Release.Namespace }}.{{ .Values.clusterDomain }}
{{- end -}}