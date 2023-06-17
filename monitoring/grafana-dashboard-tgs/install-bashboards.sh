#!/bin/bash
files_to_change=$(find dashboard -name "* *") 
for arg in "$files_to_change" ; do
	echo "$arg" | tr ' ' '_' | tr A-Z a-z
done


# for arg in "$files_to_change" ; do
	# find $startDir \( -name "*_*" -o -name "*_*" \) -print |
		# while read old ; do
		# new=$(echo "$old" | tr -s '\011' ' ' | tr -s '_' '.')
		# mv "$old" "$new"
	# done
# done


# kubectl -n monitoring create configmap grafana-datasource-cloudwatch --from-file=grafana-datasource.json
# kubectl -n monitoring label configmap grafana-datasource-cloudwatch grafana_datasource=1