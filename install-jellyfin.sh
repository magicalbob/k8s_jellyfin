unset USE_KIND
# Check if kubectl is available in the system
if kubectl 2>/dev/null >/dev/null; then
  # Check if kubectl can communicate with a Kubernetes cluster
  if kubectl get nodes 2>/dev/null >/dev/null; then
    echo "Kubernetes cluster is available. Using existing cluster."
    export USE_KIND=0
  else
    echo "Kubernetes cluster is not available. Creating a Kind cluster..."
    export USE_KIND=X
  fi
else
  echo "kubectl is not installed. Please install kubectl to interact with Kubernetes."
  export USE_KIND=X
fi

if [ "X${USE_KIND}" == "XX" ]; then
    # Make sure cluster exists if using Kind
    kind  get clusters 2>&1 | grep "kind-jellyfin"
    if [ $? -gt 0 ]
    then
        envsubst < kind-config.yaml.template > kind-config.yaml
        kind create cluster --config kind-config.yaml --name kind-jellyfin
    fi

    # Make sure create cluster succeeded
    kind  get clusters 2>&1 | grep "kind-jellyfin"
    if [ $? -gt 0 ]
    then
        echo "Creation of cluster failed. Aborting."
        exit 666
    fi
fi

echo add metrics
kubectl apply -f https://dev.ellisbs.co.uk/files/components.yaml

echo install local storage
kubectl apply -f  local-storage-class.yaml

echo create jellyfin namespace, if it does not exist
kubectl get ns jellyfin 2> /dev/null
if [ $? -eq 1 ]
then
    kubectl create namespace jellyfin
fi

# sort out persistent volume
if [ "X${USE_KIND}" == "XX" ]; then
  export NODE_NAME=$(kubectl get nodes |grep control-plane|cut -d\  -f1|head -1)
  envsubst < jellyfin.pv.kind.template > jellyfin.pv.yml
else
  export NODE_NAME=$(kubectl get nodes | grep -v ^NAME|grep -v control-plane|cut -d\  -f1|head -1)
  envsubst < jellyfin.pv.linux.template > jellyfin.pv.yml
  echo mkdir -p ${PWD}/jellyfin-media|ssh -o StrictHostKeyChecking=no ${NODE_NAME}
  echo mkdir -p ${PWD}/jellyfin-config|ssh -o StrictHostKeyChecking=no ${NODE_NAME}
fi
kubectl apply -f jellyfin.pv.yml

echo create deployment
kubectl apply -f jellyfin.deployment.yaml

echo create service
kubectl apply -f jellyfin.service.yaml

echo wait for deployment to be running
until kubectl get all -n jellyfin|grep ^pod/|grep 1/1; do
  sleep 5
done

echo create port-forward to access jellyfin on port 8096
if ! nc -z -w1 0.0.0.0 8096; then
  # Port 4566 is not already forwarded, so execute the port-forwarding command
  kubectl port-forward service/jellyfin-service -n jellyfin --address 0.0.0.0 8096:8096 &
else
  echo "Port 8096 is already forwarded."
fi
