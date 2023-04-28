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
import_index


## put template
curl -X PUT https://${prometheus_url}/_index_template/jaeger-service -H 'Content-Type: application/json' -d @jaeger-service.json


## delete index
## https://stackoverflow.com/questions/22924300/removing-data-from-elasticsearch

curl -X DELETE 'https://stg-elasticsearch.rpgp.cc/_all'
