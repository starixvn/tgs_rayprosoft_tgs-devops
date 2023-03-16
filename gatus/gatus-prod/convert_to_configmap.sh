#!/bin/bash
gatus_url="https://healthcheck.srvptt.com/"
output_filename=./cm_gatus.yaml
file=./services.csv
cat << EOF > ./cm_gatus.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  annotations:
    meta.helm.sh/release-name: gatus
    meta.helm.sh/release-namespace: prod
  labels:
    app.kubernetes.io/instance: gatus
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: gatus
    app.kubernetes.io/version: v5.2.0
    helm.sh/chart: gatus-3.1.3
  name: gatus
  namespace: prod
data:
  config.yaml: |-
    alerting:
      telegram:
        token: "2068651097:AAEOwrN7N5c23vthx2PTQ5_YQEU4ZGo2i7A"
        id: "-1001626239965"
    storage:
      type: postgres
      path: "postgres://gatus_prod:1q2w3e4r@db-staging.cglu874fh5rb.ap-east-1.rds.amazonaws.com/gatus_prod?sslmode=disable"
    endpoints:
EOF
while read -r line; do
    echo -e "$line"
    IFS=',' read -r -a arrIn <<< "$line";unset EOF;
    echo ${arrIn[4]}

    cat << EOF >> $output_filename
      - group: ${arrIn[0]}
        name: ${arrIn[1]}
        url: ${arrIn[3]}
        interval: ${arrIn[2]}
        conditions:
          - ${arrIn[4]}
        alerts:
        - type: telegram
          enabled: true
          description: "healthcheck failed\nplease check ${gatus_url}"
          send-on-resolved: true
EOF
    echo "========================="
done <$file