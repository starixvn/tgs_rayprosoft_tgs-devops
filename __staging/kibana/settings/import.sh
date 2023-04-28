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


for p in $(ls -l | grep -E '^d' | awk '{print $9}'); 
do 
    for f in $(ls $p -l | grep -E '^-' | awk '{print $9}');
    do 
        index_type=$(echo "${p/-/\/}")
		echo "$index_type"
		index=$(echo "${f/.json/}")
		echo "$index"
		echo "$f"
		# curl -X PUT https://${prometheus_url}/$index_type/$index_key -H 'Content-Type: application/json' -d @jaeger-service.json
    done
	echo "=====";
done

## put template
#curl -X PUT https://${prometheus_url}/_index_template/jaeger-service -H 'Content-Type: application/json' -d @jaeger-service.json


## delete index
## https://stackoverflow.com/questions/22924300/removing-data-from-elasticsearch

#curl -X DELETE 'https://stg-elasticsearch.rpgp.cc/_all'
