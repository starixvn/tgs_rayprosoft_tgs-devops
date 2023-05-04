#!/bin/bash
export elasticsearch_url="https://stg-elasticsearch.rpgp.cc"
export kibana_url="https://stg-kibana.rpgp.cc"

function import_index {
	echo "Importing index..."
	until curl --user $1:$2 -X POST ${elasticsearch_url}/api/saved_objects/_import -H "kbn-xsrf: true" --form file=@index_pattern.ndjson -H 'kbn-xsrf: true'; do sleep 5; done
	if [[ $(echo "$?") == "0" ]]; then
	  printf "\n########## Imported index-pattern successfully! #############################\n"
	else
	  printf "\n########## Failure while importing index-pattern #############\n"
	fi
}

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
		curl -X PUT -u $username:$password $elasticsearch_url/$index_type/$index -H 'Content-Type: application/json' -d @${file}
		rm ${file}
		echo "Imported $index_type/$index successfully"
    done
	echo "=====";
done

import_index $username $password

## import index-pattern
curl -X POST ${kibana_url}/api/saved_objects/_import?overwrite=true -H "kbn-xsrf: true" --form file=@index_pattern.ndjson | jq


## delete index
## https://stackoverflow.com/questions/22924300/removing-data-from-elasticsearch
#先不要用
#curl -X DELETE 'https://stg-elasticsearch.rpgp.cc/_all'

#indexes=$(curl https://elasticsearch.srvptt.com/_cat/indices?v&index=log-game*)
#for index in indexes
#curl https://elasticsearch.srvptt.com/_cat/indices?index=log-game*&h=index
#| cut -d ' ' -f2 | sort
#curl https://elasticsearch.srvptt.com/_cat/indices?v&index=log-game* | cut -d ' ' -f2 | sort
