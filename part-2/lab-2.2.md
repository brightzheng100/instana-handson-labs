# Lab 2.2 – Website Monitoring

## 2. Install Robot-Shop website

### On Kubernetes

```sh
# Create the namespace
$ kubectl create namespace robot-shop

# Clone the repo
$ git clone https://github.com/instana/robot-shop

# Then cd into it
$ cd robot-shop

# Deploy it by Helm 3
# NOTE: Use the right values generated in website config as the variables
$ INSTANA_EUM_REPORTING_URL="https://168.1.53.231.nip.io:446/eum/" && \
  INSTANA_EUM_KEY="xxxxxxxxxxxxxxxxx" && \
  helm install robot-shop K8s/helm \
    --namespace robot-shop \
    --set image.version=2.1.0 \
    --set eum.url="${INSTANA_EUM_REPORTING_URL}" \
    --set eum.key="${INSTANA_EUM_KEY}"
```

```sh
# Check out the pods deployed
$ kubectl get pod -n robot-shop
```

```sh
# Expose the app if you want – this is optional for the lab
$ NODEPORT=$( kg svc web -o=jsonpath='{.spec.ports[0].nodePort}' -n robot-shop ) && \
  docker run -d --restart always \
    --name kind-proxy-${NODEPORT} \
    --publish 0.0.0.0:${NODEPORT}:${NODEPORT} \
    --link kind-control-plane:target \
    --network kind \
    alpine/socat -dd \
    tcp-listen:${NODEPORT},fork,reuseaddr tcp-connect:target:${NODEPORT} && \
  echo "you now can access the app through: http://<HOST IP>:${NODEPORT}"
```

### On OpenShift

```sh
# Create the project
$ oc adm new-project robot-shop
$ oc project robot-shop

# Grant permissions
$ oc adm policy add-scc-to-user anyuid -z default -n robot-shop
$ oc adm policy add-scc-to-user privileged -z default -n robot-shop

# Clone the repo
$ git clone https://github.com/instana/robot-shop

# Then cd into it
$ cd robot-shop

# Deploy it by Helm 3
# NOTE: Use the right values generated in website config as the variables
$ INSTANA_EUM_REPORTING_URL="https://168.1.53.231.nip.io:446/eum/" && \
  INSTANA_EUM_KEY="xxxxxxxxxxxxxxxxx" && \
  helm install robot-shop K8s/helm \
    --namespace robot-shop \
    --set image.version=2.1.0 \
    --set eum.url="${INSTANA_EUM_REPORTING_URL}" \
    --set eum.key="${INSTANA_EUM_KEY}"
    --set openshift=true
    --set ocCreateRoute=true
```

```sh
# Check out the pods deployed
$ kubectl get pod -n robot-shop

# Check out the route
$ kubectl get route -n robot-shop
```

## 3. Install the “load-gen” app

```sh
# Deploy the load-gen App
$ kubectl -n robot-shop apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: load
  labels:
    service: load
spec:
  replicas: 1
  selector:
    matchLabels:
      service: load
  template:
    metadata:
      labels:
        service: load
    spec:
      containers:
      - name: load
        env:
          - name: HOST
            value: "http://web:8080/"
          - name: NUM_CLIENTS
            value: "5"
          - name: SILENT
            value: "1"
          - name: ERROR
            value: "0"                  # disable the error calls first
        image: robotshop/rs-load:latest
EOF
```

```sh
# Deploy the Selenium-based EUM friendly load-gen
$ kubectl -n robot-shop apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rs-website-load
  labels:
    service: rs-website-load
spec:
  replicas: 1
  selector:
    matchLabels:
      service: rs-website-load
  template:
    metadata:
      labels:
        service: rs-website-load
    spec:
      containers:
      - name: rs-website-load
        env:
          - name: HOST
            value: "http://web:8080/"
        image: brightzheng100/rs-website-load:2.1.0
        imagePullPolicy: Always
EOF
```

