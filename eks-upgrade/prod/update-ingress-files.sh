#!/bin/bash
namespace="prod"

# for p in $(kubectl get certificate -n prod | grep -v goal3388.com | awk '{print $1}'); do
    # kubectl delete certificate $p -n $namespace
# done;

startTime=`date +%Y%m%d-%H:%M:%S`
startTime_s=`date +%s`

declare -i count=0

replaceIngressClass="\ \ ingressClassName: nginx"



#for p in $(kubectl get ing -n $namespace | grep -v -E 'goal3388.com|acme' | awk '{print $1}'); do
for p in $(ll | awk '{print $9}'); do
    #kubectl -n $namespace get ing $p -o yaml >  ${p}.yaml;
    
    endTime=`date +%Y%m%d-%H:%M:%S`
    endTime_s=`date +%s`
    sumTime=$[ $endTime_s - $startTime_s ]
    
    echo "====== $count 修改 $p ==== $startTime ---> $endTime   Total:$sumTime seconds ======"
   
    ## 刪除 kubernetes.io/ingress.class 該行
    sed -i '/kubernetes.io\/ingress.class/d' ${p}
    
    ## 刪除 cert-manager.io/cluster-issuer 該行
    sed -i '/cert-manager.io\/cluster-issuer/d' ${p}
    
    if grep -q "ingressClassName" ${p}
    then 
       ingressClassLine=$(grep -n "ingressClassName:" ${p}.yaml | awk -F':' '{print $1}')
       sed -i "$[ ingressClassLine ]c $replaceIngressClass" ${p}
       echo "ingressClassName modified"
    else 
       ## 新增 ingressClassName: nginx
       sed -i "/spec:/a $replaceIngressClass" ${p}
       echo "ingressClassName added"
    fi
    
    if grep -q "tls" ${p}
    then
        ## code if found
        ## 刪除 tls
        sed -i '/tls/,/status/{/tls/!{/status/!d}}' ${p}
        sed -i '/tls:/d' ${p} 
        echo "remove tls"        
    else
        # code if not found
        echo "without tls"
    fi
    
    #kubectl apply -f ${p}
    #rm ${p}.yaml
    #rm ${p}.yaml
    
    count=$((count+1))  
done;
