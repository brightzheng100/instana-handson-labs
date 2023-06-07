# Lab 2.3 – Website Monitoring

## Step 0: Bootstrap the single-node Kubernetes

```sh
# Clone the repo if you haven't
cd ~
git clone https://github.com/brightzheng100/instana-handson-labs.git
cd instana-handson-labs
git checkout labs-v3

# Bootstrap the Kubernetes
cd scripts
# Run this if you're with RHEL/CentOS
./bootstrap-k8s-on-rhel.sh
# Or run this if you're with Ubuntu
./bootstrap-k8s-on-ubuntu.sh
```

It will take roughly 3-5 minutes to fully bootstrap the VM as a single-node Kubernetes.
You may verify the readiness by:

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

If you're seeing similar results where the node is "Ready" and all Pods are "Running", you're good to go.
Otherwise, please fix the issue before proceeding.


## Step 2: Install Robot-Shop website

### On Kubernetes

```sh
# Create the namespace
kubectl create namespace robot-shop

# Clone the repo
cd ~
#git clone https://github.com/instana/robot-shop
git clone https://github.com/brightzheng100/robot-shop
cd robot-shop
git checkout selenium-load-gen

# Deploy it by Helm 3
# NOTE: Use the right values generated in website config as the variables
INSTANA_EUM_REPORTING_URL="https://xxx.xxx.xxx.xxx.nip.io:446/eum/" && \
INSTANA_EUM_KEY="xxxxxxxxxxxxxxxxx" && \
  helm install robot-shop K8s/helm \
    --namespace robot-shop \
    --set image.repo=brightzheng100 \
    --set image.version=2.1.1 \
    --set redis.storageClassName="local-path" \
    --set nodeport=true \
    --set eum.url="${INSTANA_EUM_REPORTING_URL}" \
    --set eum.key="${INSTANA_EUM_KEY}"
```

```sh
# Check out the pods deployed
$ kubectl get pod -n robot-shop
```

```sh
# Expose the app if you want – this is optional for the lab
$ NODEPORT=$( kubectl get svc web -o=jsonpath='{.spec.ports[0].nodePort}' -n robot-shop ) && \
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

### Selenium-based load-gen

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

