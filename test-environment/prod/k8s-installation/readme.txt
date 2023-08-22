改用helm upgrade -i 安裝

kubectl create namespace logging

REF: https://docs.fluentbit.io/manual/installation/kubernetes#installation

先依照文件設定helm repo
helm repo add fluent https://fluent.github.io/helm-charts

升級時，先執行
helm repo update

安裝daemonset的fluent-bit
helm upgrade -i fluent-bit fluent/fluent-bit -f edge-values.yaml -n logging

安裝center
helm upgrade -i log-center fluent/fluent-bit -f center-values.yaml --set replicaCount=1 -n logging

再重新執行helm upgrade指令

安裝完成後使用 kubectl edit ds fluent-bit 修改 forward port，增加hostPort: 24224