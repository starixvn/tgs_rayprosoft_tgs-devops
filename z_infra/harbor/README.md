///////////////////////////////////////////////
///////////// Bitnami Harbor//////////////////
///////////////////////////////////////////////

helm repo add bitnami https://charts.bitnami.com/bitnami

https://github.com/bitnami/charts/tree/master/bitnami/harbor/#installing-the-chart



helm -n harbor uninstall harbor

helm -n harbor upgrade --install harbor bitnami/harbor --set nameOverride=harbor \
  --set trivy.enabled=false \
  --set notary.enabled=false \
  --set chartmuseum.enabled=false \
  --set global.storageClass=gp2 \
  --set service.type=ClusterIP \
  --set ingress.core.ingressClassName=nginx \
  --set ingress.core.pathType=Prefix \
  --set adminPassword=harbor123 \
  --set externalURL=https://harbor.srvptt.com \
  --set externalRedis.host=tgs-redis.ie2cpa.0001.ape1.cache.amazonaws.com \
  --set harborAdminPassword=harbor123 \
  --set postgresql.postgresqlUsername=harbor \
  --set postgresql.postgresqlPassword=harbor123 \
  --set postgresql.auth.postgresPassword=harbor123 \
  --set externalDatabase.host=db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com \
  --set externalDatabase.user=harbor \
  --set externalDatabase.password=harbor123
  
  
  
///////////////////////////////////////////////
///////////// Official Harbor /////////////////
///////////////////////////////////////////////
 
helm repo add harbor https://helm.goharbor.io
helm show all  harbor/harbor

https://github.com/goharbor/harbor-helm


/// 下面是正確的安裝方式
helm -n harbor upgrade --install harbor harbor/harbor \
  --set trivy.enabled=false \
  --set notary.enabled=false \
  --set chartmuseum.enabled=false \
  --set registry.credentials.username=harbor \
  --set registry.credentials.password=harbor123 \
  --set internalTLS.enabled=true \
  --set expose.ingress.hosts.core=harbor.rpgp.cc \
  --set database.type=external \
  --set database.external.host=db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com \
  --set database.external.username=harbor \
  --set database.external.password=harbor123 \
  --set postgresql.auth.postgresUsername=harbor \
  --set postgresql.auth.postgresPassword=harbor123 \
  --set redis.type=external \
  --set redis.external.addr=redis-master.staging:6379 \
  --set externalURL=https://harbor.rpgp.cc \
  --set expose.type=ingress
  

  
  
  
  --set externalURL=https://harbor.srvptt.com 
  
  

  --set global.storageClass=gp2 \
  --set service.type=ClusterIP \
  --set ingress.core.ingressClassName=nginx \
  --set ingress.core.pathType=Prefix \
  --set adminPassword=harbor123 \
  --set externalURL=https://harbor.srvptt.com \
  --set externalRedis.host=tgs-redis.ie2cpa.0001.ape1.cache.amazonaws.com \
  --set harborAdminPassword=harbor123 \
  --set postgresql.postgresqlUsername=harbor \
  --set postgresql.postgresqlPassword=harbor123 \
  --set postgresql.auth.postgresPassword=harbor123 \
  --set externalDatabase.host=db-production.cglu874fh5rb.ap-east-1.rds.amazonaws.com \
  --set externalDatabase.user=harbor \
  --set externalDatabase.password=harbor123
  
  

