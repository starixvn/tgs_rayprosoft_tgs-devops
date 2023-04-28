#!/bin/bash
export prometheus_url="https://stg-elasticsearch.rpgp.cc"

function import_index {
	echo "Importing index..."
	until curl --user user:pwd -X POST ${prometheus_url}/api/saved_objects/_import -H "kbn-xsrf: true" --form file=@index_pattern.ndjson -H 'kbn-xsrf: true'; do sleep 5; done
	if [[ $(echo "$?") == "0" ]]; then
	  printf "\n########## Imported index-pattern successfully! #############################\n"
	else
	  printf "\n########## Failure while importing index-pattern #############\n"
	fi
}
#import_index

username=$(kubectl get secret elasticsearch-master-credentials -n observability -o jsonpath="{.data.username}" | base64 --decode)
password=$(kubectl get secret elasticsearch-master-credentials -n observability -o jsonpath="{.data.password}" | base64 --decode)

for folder in $(ls -l ./ | grep -E '^d' | awk '{print $9}'); 
do 
    for file in $(ls ./$folder -l | grep -E '^-' | awk '{print $9}');
    do 
        index_type=$(echo "${folder/-/\/}")
		echo "$index_type"
		index=$(echo "${file/.json/}")
		echo "$index"
		echo "$file"
		tail -n +2 ${folder}/${file} > ${file}
		curl -X PUT -u $username:$password $prometheus_url/$index_type/$index -H 'Content-Type: application/json' -d @${file}
		rm ${file}
		echo "Imported $index_type/$index successfully"
    done
	echo "=====";
done

## put template
#curl -XPUT -u $username:$password https://stg-elasticsearch.rpgp.cc/_index_template/jaeger-service -H 'Content-Type: application/json' -d @_index_template/jaeger-service.json


## delete index
## https://stackoverflow.com/questions/22924300/removing-data-from-elasticsearch

#curl -X DELETE 'https://stg-elasticsearch.rpgp.cc/_all'
