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
