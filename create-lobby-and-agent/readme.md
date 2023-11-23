export lobby=lobby-689
export image=lobby-t2
export domain=
export token=


envsubst < lobby-prod.yaml > sample.yaml
kubectl apply -f sample.yaml