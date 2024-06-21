# https://karpenter.sh/docs/getting-started/
# https://aws.github.io/aws-eks-best-practices/karpenter/

Yc4h=--tmmXYNM9Sd=EtkK?$8t7M.!r9

export namespace=prod

kubectl -n $namespace patch deployment $p --type='json' -p='[
  {"op": "replace", "path": "/spec/template/spec/tolerations/0/value", "value": "frontend"},
  {"op": "replace", "path": "/spec/template/spec/nodeSelector/dedicated", "value": "frontend"}
]'


for p in $(kubectl get deploy -n $namespace | grep -E 'agent|lobby' | grep -v -E 'player-all-agent-service|agent-dividend-service|agent-api|agent-service'| awk '{print $1}');do \
 kubectl -n $namespace patch deployment $p --type='json' -p='[ 
  {"op": "replace", "path": "/spec/template/spec/tolerations/0/value", "value": "frontend"}, 
  {"op": "replace", "path": "/spec/template/spec/nodeSelector/dedicated", "value": "frontend"} 
 ]'; \
done;


for p in $(kubectl get deploy -n prod -l tgs.kind=game | awk '{print $1}');do \
 kubectl -n $namespace patch deployment $p --type='json' -p='[ 
  {"op": "replace", "path": "/spec/template/spec/tolerations/0/value", "value": "game"}, 
  {"op": "replace", "path": "/spec/template/spec/nodeSelector/dedicated", "value": "game"} 
 ]'; \
done;

for p in $(kubectl get deploy -n prod -l tgs.node.selector.kind=gamewagers | awk '{print $1}');do \
 kubectl -n $namespace patch deployment $p --type='json' -p='[ 
  {"op": "replace", "path": "/spec/template/spec/tolerations/0/value", "value": "gamewagers"}, 
  {"op": "replace", "path": "/spec/template/spec/nodeSelector/dedicated", "value": "gamewagers"} 
 ]'; \
done;


## revert 
for p in $(kubectl get deployments -n prod -o=jsonpath='{range .items[?(@.spec.template.spec.nodeSelector.dedicated=="game")]}{.metadata.name}{"\n"}{end}');do \
  kubectl -n $namespace patch deployment $p --type='json' -p='[ 
  {"op": "replace", "path": "/spec/template/spec/tolerations/0/value", "value": "staging"}, 
  {"op": "replace", "path": "/spec/template/spec/nodeSelector/dedicated", "value": "staging"} 
 ]'; \
done;
