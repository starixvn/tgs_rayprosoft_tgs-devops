# https://hub.develeap.com/kibana-objects-exporting-importing/
#!/bin/bash
export KIBANA_URL="https://stg-kibana.rpgp.cc"
function import_index {
	echo "Importing index..."
	until curl --user user:pwd -X POST ${KIBANA_URL}/api/saved_objects/_import -H "kbn-xsrf: true" --form file=@index_pattern.ndjson -H 'kbn-xsrf: true'; do sleep 5; done
	if [[ $(echo "$?") == "0" ]]; then
	  printf "\n########## Imported index-pattern successfully! #############################\n"
	else
	  printf "\n########## Failure while importing index-pattern #############\n"
	fi
}
import_index