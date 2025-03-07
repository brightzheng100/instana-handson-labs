# Lab 2.3 – Website Monitoring

## Step 0: Bootstrap the single-node Kubernetes

```sh
# Clone the repo if you haven't
cd ~
git clone https://github.com/brightzheng100/instana-handson-labs.git
cd instana-handson-labs/scripts

# Bootstrap the Kubernetes
./bootstrap-k8s.sh
```

```sh
$ kubectl get node
NAME                                        STATUS   ROLES           AGE     VERSION
itz-550004ghs4-hq4f.dte.demo.ibmcloud.com   Ready    control-plane   2m16s   v1.26.3

$ kubectl get pods -A
NAMESPACE            NAME                                                                READY   STATUS    RESTARTS   AGE
kube-system          calico-kube-controllers-57b57c56f-8kggf                             1/1     Running   0          2m32s
kube-system          calico-node-pnnjg                                                   1/1     Running   0          2m32s
kube-system          coredns-787d4945fb-2cllt                                            1/1     Running   0          3m20s
kube-system          coredns-787d4945fb-t7lbd                                            1/1     Running   0          3m20s
kube-system          etcd-itz-550004ghs4-hq4f.dte.demo.ibmcloud.com                      1/1     Running   0          3m34s
kube-system          kube-apiserver-itz-550004ghs4-hq4f.dte.demo.ibmcloud.com            1/1     Running   0          3m37s
kube-system          kube-controller-manager-itz-550004ghs4-hq4f.dte.demo.ibmcloud.com   1/1     Running   0          3m34s
kube-system          kube-proxy-dtlm2                                                    1/1     Running   0          3m20s
kube-system          kube-scheduler-itz-550004ghs4-hq4f.dte.demo.ibmcloud.com            1/1     Running   0          3m36s
local-path-storage   local-path-provisioner-7f8667b75c-vnmw2                             1/1     Running   0          2m32s
```

## Step 2: Install Robot-Shop website

### On Kubernetes

```sh
# Clone the repo
cd ~
#git clone https://github.com/instana/robot-shop
git clone https://github.com/brightzheng100/robot-shop
cd robot-shop

# This branch has all my changes, including the Selenium-based load-gen
git checkout selenium-load-gen

# Create the namespace
kubectl create namespace robot-shop

# Deploy it by Helm 3
# NOTE: Use the right values generated in website config as the variables
INSTANA_EUM_REPORTING_URL="https://162.133.113.4.nip.io/eum/" && \
INSTANA_EUM_KEY="xxxxxxxxxxxxxxxxx" && \
REDIS_STORAGE_CLASS="local-path" && \
helm install robot-shop K8s/helm \
  --namespace robot-shop \
  --set image.repo=brightzheng100 \
  --set image.version=2.1.1 \
  --set eum.url="${INSTANA_EUM_REPORTING_URL}" \
  --set eum.key="${INSTANA_EUM_KEY}" \
  --set redis.storageClassName="${REDIS_STORAGE_CLASS}" \
  --set nodeport=true
```

```sh
# Check out the pods deployed
kubectl get pod -n robot-shop
```

Optionally, expose the app for remote access:

```sh
# Retrieve your public IP
ip addr

# Expose the web service to any of the suitable open ports
kubectl port-forward -n robot-shop deploy/web 8080:8080 --address 0.0.0.0
```

### On OpenShift

```sh
# Clone the repo
cd ~
#git clone https://github.com/instana/robot-shop
git clone https://github.com/brightzheng100/robot-shop
cd robot-shop

# This branch has all my changes, including the Selenium-based load-gen
git checkout selenium-load-gen
```

```sh
# Create the project
oc adm new-project robot-shop
oc project robot-shop

# Grant permissions
oc adm policy add-scc-to-user anyuid -z default -n robot-shop
oc adm policy add-scc-to-user privileged -z default -n robot-shop

# Deploy it by Helm 3
# NOTE: Use the right values generated in website config as the variables
INSTANA_EUM_REPORTING_URL="https://xxx.xxx.xxx.xxx.nip.io/eum/" && \
INSTANA_EUM_KEY="xxxxxxxxxxxxxxxxxxxxx" && \
REDIS_STORAGE_CLASS="xxx" && \
helm install robot-shop K8s/helm \
  --namespace robot-shop \
  --set image.repo=brightzheng100 \
  --set image.version=2.1.1 \
  --set eum.url="${INSTANA_EUM_REPORTING_URL}" \
  --set eum.key="${INSTANA_EUM_KEY}" \
  --set redis.storageClassName="${REDIS_STORAGE_CLASS}" \
  --set openshift=true \
  --set ocCreateRoute=true
```

```sh
# Check out the pods deployed
$ kubectl get pod -n robot-shop

# Check out the route
$ kubectl get route -n robot-shop
```

## Step 3: Install the “load-gen” app

### load-gen

```sh
# Deploy the load-gen App
kubectl -n robot-shop apply -f - <<EOF
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
            value: "0"                       # disable the error calls first
        image: brightzheng100/rs-load:2.1.1
EOF
```

```sh
# Deploy the Selenium-based EUM friendly load-gen
kubectl -n robot-shop apply -f - <<EOF
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
        image: brightzheng100/rs-website-load:2.1.1
        imagePullPolicy: Always
EOF
```
