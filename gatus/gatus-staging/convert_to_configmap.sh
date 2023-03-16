#!/bin/bash
gatus_url="https://stg-gatus.rpgp.cc/"
output_filename=./cm_gatus.yaml
file=./staging-services.csv
cat << EOF > ./cm_gatus.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  annotations:
    meta.helm.sh/release-name: gatus
    meta.helm.sh/release-namespace: staging
  labels:
    app.kubernetes.io/instance: gatus
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: gatus
    app.kubernetes.io/version: v5.2.0
    helm.sh/chart: gatus-3.1.3
  name: gatus
  namespace: staging
data:
  config.yaml: |-
    alerting:
      telegram:
        token: "1652136804:AAFWBATSiBh-6wNIpoUXHCRNwSOa5J3fVfw"
        id: "-1001368681345"
    storage:
      type: postgres
      path: "postgres://gatus_staging:1q2w3e4r@db-staging.cglu874fh5rb.ap-east-1.rds.amazonaws.com/gatus_staging?sslmode=disable"
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