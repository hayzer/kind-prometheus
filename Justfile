default:
  just -l

# Check prerequisites
prerequisites:
  kind version || echo "ERROR: missing kind"
  helm version || echo "ERROR: missing helm"
  krr version || echo "ERROR: missing krr"

# Run cluster
run-cluster:
  kind create cluster --config kind-config.yaml --name prometheus-cluster

# Delete cluster
destroy-cluster:
  kind delete cluster --name prometheus-cluster

# Add prometheus helm repo
add-helm-prometheus:
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update

# Install prometheus
install-prometheus:
  helm install prometheus prometheus-community/kube-prometheus-stack -f prometheus-values.yaml

# Uninstall prometheus
uninstall-prometheus:
  helm uninstall prometheus

# Create nodeport service for prometheus
nodeport-prometheus:
  kubectl apply -f nodeport-service.yaml

# Install krr
run-krr:
  krr simple --prometheus-url http://localhost:30000

# From zero to hero
all: 
  just prerequisites 
  just run-cluster just add-helm-prometheus 
  just install-prometheus 
  just nodeport-prometheus 
  just run-krr

