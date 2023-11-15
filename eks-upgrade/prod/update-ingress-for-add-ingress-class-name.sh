#!/bin/bash
namespace="prod"

# for p in $(kubectl get certificate -n prod | grep -v goal3388.com | awk '{print $1}'); do
    # kubectl delete certificate $p -n $namespace
# done;

startTime=`date +%Y%m%d-%H:%M:%S`
startTime_s=`date +%s`

declare -i count=0

replaceIngressClass="\ \ ingressClassName: nginx"

for p in $(kubectl get ing -n $namespace | grep -v goal3388.com | awk '{print $1}'); do
    kubectl -n $namespace get ing $p -o yaml >  ${p}.yaml;
    
    endTime=`date +%Y%m%d-%H:%M:%S`
    endTime_s=`date +%s`
    sumTime=$[ $endTime_s - $startTime_s ]
    
    echo "====== $count 修改 $p ==== $startTime ---> $endTime   Total:$sumTime seconds ======"
   
    ## 刪除 kubernetes.io/ingress.class 該行
    sed -i '/kubernetes.io\/ingress.class/d' ${p}.yaml
    
    ## 刪除 cert-manager.io/cluster-issuer 該行
    sed -i '/cert-manager.io\/cluster-issuer/d' ${p}.yaml
    
    if grep -q "ingressClassName" ${p}.yaml
    then 
       ingressClassLine=$(grep -n "ingressClassName:" ${p}.yaml | awk -F':' '{print $1}')
       sed -i "$[ ingressClassLine ]c $replaceIngressClass" ${p}.yaml
       echo "ingressClassName modified"
    else 
       ## 新增 ingressClassName: nginx
       sed -i "/spec:/a $replaceIngressClass" ${p}.yaml
       echo "ingressClassName added"
    fi
    
    if grep -q "tls" ${p}.yaml
    then
        ## code if found
        ## 刪除 tls
        sed -i '/tls/,/status/{/tls/!{/status/!d}}' ${p}.yaml
        sed -i '/tls:/d' ${p}.yaml 
        echo "remove tls"        
    else
        # code if not found
        echo "without tls"
    fi
    
    #kubectl apply -f ${p}.yaml
    #rm ${p}.yaml
    #rm ${p}.yaml
    
    count=$((count+1))  
done;
