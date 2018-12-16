{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "gcloud-sqlproxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "gcloud-sqlproxy.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s" .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
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
{{- if .Values.existingSecret -}}
    {{ .Values.existingSecretKey }}
{{- else -}} credentials.json
{{- end }}
{{ end -}}

{{/*
Check if Secret exists
*/}}
{{- define "existSecret" -}}
{{ if or .Values.serviceAccountKey .Values.existingSecret -}}
    {{ .Values.existingSecret }}
{{- end }}
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

{{- define "container.image" -}}
image: "{{ .Values.image.repo }}:{{ .Values.image.tag }}"
imagePullPolicy: {{ default "" .Values.image.pullPolicy | quote }}
resources:
{{ toYaml .Values.resources | indent 10 }}
{{- end -}}

{{- define "container.volumeMounts" -}}
volumeMounts:
{{ if or .Values.serviceAccountKey .Values.existingSecret -}}
- name: cloudsql-oauth-credentials
  mountPath: /secrets/cloudsql
  {{ end -}}
- name: cloudsql
  mountPath: /cloudsql
{{- end -}}

{{- define "rbacSpec" -}}
{{- if .Values.rbac.create }}
serviceAccountName: {{ template "gcloud-sqlproxy.fullname" }}
{{- end }}
{{- end -}}

{{- define "container.spec" -}}
volumes:
{{ if or .Values.serviceAccountKey .Values.existingSecret -}}
- name: cloudsql-oauth-credentials
  secret:
    secretName: {{ default (include "gcloud-sqlproxy.fullname" .) .Values.masterReplica.existingSecret }}
      {{ end -}}
- name: cloudsql
  emptyDir: {}
nodeSelector:
{{ toYaml .Values.nodeSelector | indent 8 }}
      affinity:
{{ toYaml .Values.affinity | indent 8 }}
      tolerations:
{{ toYaml .Values.tolerations | indent 8 }}
{{- end }}

{{- define "lables_yaml" -}}
chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
release: "{{ .Release.Name }}"
heritage: "{{ .Release.Service }}"
{{- end }}
