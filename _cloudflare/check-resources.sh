#!/bin/bash
export TgsEnv=prod
resources=$(kubectl get deploy -o=jsonpath='{range .items[*]}{.metadata.name}{","}{.spec.template.spec.containers[0].resources.requests.memory}{"\n"}{end}' -n $TgsEnv)


GetAvg() {
    #IFS=" "
    _count=0
    _total=0

    #echo "GetAvg=$@"

    for current in $@; do
        _count=$((_count+1))
        res=${current/"Mi"/""}

        #echo "res=$res"
        #echo "tmpCount=$_count"
        _total=$(expr $_total + $res)
    done

    #echo "total=$_total"
    #echo "count=$_count"

    if [[ "$_count" -eq "0" ]]; then
            echo 0;
    else
            echo $_total/$_count | bc ;
    fi
}

declare -A arr
count=0
oldIFS="$IFS"
emptyChar=" "
for resource in $resources; do
    count=$((count+1))
    echo $count
    IFS=","
    resource_=($resource)

    echo ${resource_[0]}
    currents=$(kubectl top pods -n $TgsEnv | grep ${resource_[0]}  | awk '{print $3}')

    IFS="$oldIFS"

    avg=$(GetAvg $currents)

    if [[ !"$avg" -eq "0" ]]; then
          echo "Set=${resource_[1]} ,AVG=$avg"

          tmpRes=0
          if [[ "${resource_[1]}" == *"Mi"* ]]; then
              echo "Mi"
              tmpRes=${resource_[1]/"Mi"/""}
          elif [[ "${resource_[1]}" == *"Gi"* ]]; then
              echo "Gi"
              tmpRes=${resource_[1]/"Gi"/""}
              tmpRes=$(printf "%.3f" $(echo "$tmpRes * 1000" | bc -l))
          fi

          echo "tmpRes=$tmpRes"
          res2=$(printf "%.3f" $(echo "$tmpRes/$avg" | bc -l))
		  echo "res2=$res2"
          key=${resource_[0]/-/_}
          echo "key=$key"
          arr["${key}"]=$res2

          #echo "arr=${arr[@]}"
    fi
done
IFS="$oldIFS"

echo ""

echo "arr=${arr[@]}"

for key in "${!arr[@]}"; do
  #echo "$key ${arr[$key]} "
  printf '%s:%s\n' "$key" "${arr[$key]}"
done | sort -t : -k 2n

                              