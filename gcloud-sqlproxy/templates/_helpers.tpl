{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "sqlproxy.chart.name" -}}
{{- $name :=default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- printf "%s" $name -}}
{{- end -}}

{{- define "sqlproxy.release.name" -}}
{{- $name :=default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- printf "%s" $name -}}
{{- end -}}

{{- define "gcloud-sqlproxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified proxy name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "gcloud-sqlproxy.instance.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified default backend name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "gcloud-sqlproxy.readReplica.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.readReplica.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.readReplica.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create the filename for credential
*/}}
{{- define "credentials-filename" -}}
{{ if or .Values.serviceAccountKey .Values.existingSecret -}}
- -credential_file=/secrets/cloudsql/{{- if .Values.existingSecret -}} {{ .Values.existingSecretKey }} {{- else -}} credentials.json {{- end }}
{{ end -}}
{{ end -}}


{{/*
Create the name of the service account to use
*/}}
{{- define "gcloud-sqlproxy.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "gcloud-sqlproxy.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "volumeMounts" -}}
{{ if or .Values.serviceAccountKey .Values.existingSecret -}}
- name: cloudsql-oauth-credentials
  mountPath: /secrets/cloudsql
  {{- end }}
{{- end -}}

{{- define "rbacSpec" -}}
{{- if .Values.rbac.create }}
serviceAccountName: {{ template "gcloud-sqlproxy.fullname" }}
{{- end -}}
{{- end -}}

{{- define "oauth-credentials" -}}
{{ if or .Values.serviceAccountKey .Values.existingSecret -}}
- name: cloudsql-oauth-credentials
  secret:
    secretName: {{ default (include "gcloud-sqlproxy.name" .) .Values.existingSecret }}
      {{ end -}}
{{- end -}}

{{- define "lables_yaml" -}}
chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
release: "{{ .Release.Name }}"
heritage: "{{ .Release.Service }}"
{{- end -}}
