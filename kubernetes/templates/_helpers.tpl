{{- define "sparky.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* fullname: ถ้า release name มีชื่อ chart อยู่แล้ว ใช้ release name เลย
     เช่น release=sparky chart=sparky -> sparky (ไม่ใช่ sparky-sparky) */}}
{{- define "sparky.fullname" -}}
{{- if contains .Chart.Name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "sparky.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ include "sparky.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: scratch
{{- end -}}

{{- define "sparky.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sparky.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
