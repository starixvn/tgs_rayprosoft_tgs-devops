#!/bin/bash 
TgsEnv=prod
components=("role" "rolebinding" "sa" "cm" "deploy" "svc" "ing")

find -mindepth 1 -maxdepth 1 -type d -exec rm -r {} \;

for obj in "${components[@]}"
do
	mkdir -p $obj;
	for p in $(kubectl get $obj -n ${TgsEnv} | awk '{print $1}'); do
		if [[ $p != "NAME" ]];then
		    echo "$obj/$p"
			kubectl get $obj $p -n ${TgsEnv} -o yaml > $obj/$p.yaml
		fi
	done;
done

mkdir -p secrets;back
for p in $(kubectl get secrets -n prod  | grep -v -E 'tls|token|helm' | awk '{print $1}'); do
	echo "secrets/$p"
	kubectl get secrets $p -n ${TgsEnv} -o yaml > secrets/$p.yaml
done;