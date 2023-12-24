# start minikube
ensure we can access 8080 and 5000 port from nodePort
```
minikube start --extra-config=apiserver.service-node-port-range=1-65535
```
# setup api
```
helm repo add demo-backend https://yushiwho.github.io/charts
```

## Download values file
```bash
curl -sL https://raw.githubusercontent.com/yushiwho/charts/master/charts/demo-backend/local-minikube.yaml
```

## install 
```bash
helm install demo-backend demo-backend/demo-backend  --values local-minikube.yaml -n demo-backend
```

# setup sys-stats
```
helm repo add demo-frontend https://yushiwho.github.io/charts
```

## Download values file
```
curl -sL https://raw.githubusercontent.com/yushiwho/charts/master/charts/demo-frontend/local-minikube.yaml
```

## Update backend url
```
backend=$(minikube service list | grep demo-backend | awk '{print $8}' | cut -c 8-)
sed -i s/192.168.49.2:5001/${backend}/g local-minikube.yaml
```
edit deployment.backendHost to match URL you will connect to api

## install 
```bash
helm install demo-frontend demo-frontend/demo-frontend  --values local-minikube.yaml -n demo-frontend
```

# accessing
`minikube service list | grep demo-frontend` get URL, eg: http://192.168.49.2:8080, Open in your browser