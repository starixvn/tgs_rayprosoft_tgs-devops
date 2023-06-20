#!/bin/bash
IFS=$'\n'
files_to_change=($(find . -name "*.json"))

for file in "$files_to_change[@]" ; do
    configmapname=$(echo $file | cut -d '-' -f 1)
    configmapname=${configmapname:2}
	
    echo "file=$file"
    echo "configmapname=$configmapname"
    echo "=========="

    kubectl -n monitoring create configmap grafana-datasource-$configmapname --from-file=$file
    kubectl -n monitoring label configmap grafana-datasource-$configmapname grafana_dashboard=1
done
