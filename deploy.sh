#needed or installation of ./charts/rabbitmq-sample-app will faile due to missing image
#docker build . --no-cache -t theryanbaker/ryantest:latest


helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace rabbitmq-scaling-demo
helm upgrade --install --namespace rabbitmq-scaling-demo rabbitmq-server-scaling-demo bitnami/rabbitmq  -f charts/rabbitmq/values.yaml
helm upgrade --install --namespace rabbitmq-scaling-demo prometheus-scaling-demo prometheus-community/prometheus

# prevent error on docker-desktop https://github.com/prometheus-community/helm-charts/issues/467
# maybe newly added and referenced charts/prometheus/values.yaml is sufficent too?!
kubectl -n  rabbitmq-scaling-demo patch ds prometheus-scaling-demo-prometheus-node-exporter --type "json" -p '[{"op": "remove", "path" : "/spec/template/spec/containers/0/volumeMounts/2/mountPropagation"}]'

helm upgrade --install --namespace rabbitmq-scaling-demo prometheus-adapter-scaling-demo prometheus-community/prometheus-adapter -f charts/prometheus-adapter/config.yaml
helm upgrade --install --namespace rabbitmq-scaling-demo rabbitmq-scaling-demo-app ./charts/rabbitmq-sample-app
