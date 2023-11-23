# lobby
export lobby=lobby-689
export image=lobby-t2
export lang=zh-CN
export domain=
export token=

envsubst < lobby-prod.yaml > sample.yaml
kubectl apply -f sample.yaml

# agent
export agent=lobby-689
export image=lobby-t2
export lang=zh-CN
export site=
export domain=
export token=

envsubst < agent-prod.yaml > sample.yaml
kubectl apply -f sample.yaml