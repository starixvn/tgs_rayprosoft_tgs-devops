#!/bin/bash
TGSENV=$1
debug=$(kubectl get pods -n default | grep debug | awk '{print $1}' | head -n 1)

SendMessage(){
        curl "https://api.telegram.org/bot1652136804:AAFWBATSiBh-6wNIpoUXHCRNwSOa5J3fVfw/sendMessage?chat_id=-1001626239965&text=$1"
}
Message=""
IFS=$'\\'
all_svc=$(kubectl get svc -n ${TGSENV} -o jsonpath='{range .items[*]}{@.metadata.name}{","}{@.spec.ports[0].port}{"\n"}{end}')
IFS=$'\n'
for svc in ${all_svc} ; do
	IFS=','
	read -a _svc <<< ${svc}
	svcname=${_svc[0]/\"}
	svcport=${_svc[1]/\"}
	echo -n  "svcname:${svcname}, svcport:${svcport}:"

	if [[ ${svcport} ==  80 ]]; then 
		if [[ ${svcname} == "agent-api"  ]]; then
			result=$(kubectl -n default exec ${debug} -- curl -s -o /dev/null -w "%{http_code}" http://${svcname}.${TGSENV}/health)
                        echo -n -e ${result}

                        if [[ ${result} == 200 ]]; then
                                echo -n -e "\e[42m      \e[49m"
                        else
                                echo -n -e "\e[41m      \e[49m"
				Message="${Message} svc: ${svcname}%0A"
                        fi
		elif [[  ${svcname} == "file-service"  ]]; then
			result=$(kubectl -n default exec ${debug} -- curl -s -o /dev/null -w "%{http_code}" http://${svcname}.${TGSENV}/fs/health)
                        echo -n -e ${result}

                        if [[ ${result} == 200 ]]; then
                                echo -n -e "\e[42m      \e[49m"
                        else
                                echo -n -e "\e[41m      \e[49m"
				Message="${Message} svc: ${svcname}%0A"
                        fi
		elif [[  ${svcname} == "schedulers"  ]]; then
			result=$(kubectl -n default exec ${debug} -- curl -s -o /dev/null -w "%{http_code}" http://${svcname}.${TGSENV}/hangfire)
                        echo -n -e ${result}

                        if [[ ${result} == 200 ]]; then
                                echo -n -e "\e[42m      \e[49m"
                        else
                                echo -n -e "\e[41m      \e[49m"
				Message="${Message} svc: ${svcname}%0A"
                        fi
		elif [[ ${svcname} == agent-*  ]] || [[ ${svcname} == lobby-* ]] || [[ ${svcname} == backoffice-site ]] || [[ ${svcname} == tgs-production ]];  then
			result=$(kubectl -n default exec ${debug} -- curl -s -o /dev/null -w "%{http_code}" http://${svcname}.${TGSENV}/healthcheck)
                 	echo -n -e ${result}	

			if [[ ${result} == 200 ]]; then 	
				echo -n -e "\e[42m      \e[49m"
			else
				echo -n -e "\e[41m      \e[49m"
				Message="${Message} svc: ${svcname}%0A"
			fi
		else 
			result1=$(kubectl -n default exec ${debug} -- curl -s -o /dev/null -w "%{http_code}" http://${svcname}.${TGSENV}/healthz)
			result2=$(kubectl -n default exec ${debug} -- curl -s -o /dev/null -w "%{http_code}" http://${svcname}.${TGSENV}/health)

                        echo -n -e ${result1} ${result2}

			if [[ ${result1} == 200 ]] ||  [[ ${result2} == 200 ]] ||  [[ ${result1} == 000 ]] ||  [[ ${result2} == 000 ]]  ; then
                                echo -n -e "\e[42m      \e[49m"
                        else
                                echo -n -e "\e[41m      \e[49m"
				Message="${Message} svc: ${svcname}%0A"
                        fi
		fi
	else 
		result=$(kubectl -n default exec ${debug} -- nc -w 2 -v ${svcname}.${TGSENV}  ${svcport}  </dev/null; echo $?)
   	        echo -n -e "result:${result}=="

		if [[ ${result} == 0 ]] || [[ ${result} = "INFO"*  ]]  ; then
                 	echo -n -e "\e[42m      \e[49m"
                else
                        echo -n -e "\e[41m      \e[49m"
			Message="${Message} svc: ${svcname}%0A"
                fi
		echo -n -e "==svcport: ${svcport} =="
  		echo -n -e "NOT 80"
        fi	
	echo ""
done

echo "message=${Message}"

if [[ "${Message}" != ""  ]]; then
	SendMessage "${TGSENV} service error: %0A ${Message}"
fi




