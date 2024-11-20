# Lab 3.5 – Custom Metrics (e.g. Cert Expiry Check)

## Step 0: Bring back VM-based agent

Clean up Kubeadm-bootstrapped Kubernetes cluster:

```sh
node="`k get no -o json | jq -r ".items[0].metadata.name"`"
kubectl drain ${node} --delete-emptydir-data --force --ignore-daemonsets
kubeadm reset --force

sudo systemctl disable kubelet
sudo systemctl stop kubelet
sudo systemctl disable crio
sudo systemctl stop crio

sudo rm -rf /etc/kubernetes /var/lib/kubelet /var/lib/etcd
sudo iptables --flush
rm -rf ~/.kube
```

```sh
# Check the status
sudo systemctl status instana-agent

# If not in running state, start it up
sudo systemctl start instana-agent
```

## Step 1: Enable built-in statsd collector

```sh
# Install netstat if you don't have it on your VM
# Do this in RHEL
sudo dnf install net-tools -y
# Or this in Ubuntu
sudo apt install net-tools -y

# Have a quick test
netstat -an|grep 8125

# Enable agent's built-in statsd sensor, which will act as statsd deamon
cat <<EOF | sudo tee /opt/instana/agent/etc/instana/configuration-statsd.yaml
com.instana.plugin.statsd:
  enabled: true
  ports:
    udp: 8125
    mgmt: 8126
  bind-ip: "0.0.0.0"
  flush-interval: 10 # in seconds
EOF

# Have a check after
netstat -an|grep 8125
```

## Step 2: Let’s have a quick try

```sh
# Install nc or netcat
# Run this in RHEL
sudo dnf install nc -y
# Or this in Ubuntu
apt-get install netcat -y
```

```sh
echo "hits:1|c" | nc -u -w1 127.0.0.1 8125
echo "custom.metrics.my_metric_name:10|g|#host:ubuntu-0" | nc -u -w1 127.0.0.1 8125
```

## Step 3: Create a simple script

```sh
cat > check-tls-cert-expiry.sh <<'EOF'
#!/bin/bash

TARGET="google.com:443";

echo "checking when the certificate of $TARGET expires";

date_cmd="date"
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v gdate &> /dev/null
    then
        echo "GNU date command is required. You may install it by: brew install coreutils"
        exit
    fi
    date_cmd="gdate"
fi

# Example: Not After : Aug 29 08:29:45 2022 GMT
expiry_date="$( echo | openssl s_client -servername $TARGET -connect $TARGET 2>/dev/null \
                               | openssl x509 -noout -dates \
                               | grep 'notAfter' \
                               | cut -d "=" -f 2 )"
echo "expiry date: $expiry_date"

# Expire in seconds
expire_in_seconds=$( $date_cmd -d "$expiry_date" '+%s' ); 
echo "expire in seconds: $expire_in_seconds"

# Expire in days
expire_in_days=$((($expire_in_seconds-$(date +%s))/86400));
echo "expire in days: $expire_in_days"

# Send the generated metrics to Instana agent
echo "metrics generated: CertExpiresInDays:$expire_in_days|g"
echo "CertExpiresInDays:$expire_in_days|g" | nc -u -w1 127.0.0.1 8125
EOF
```

## 4. Run the script

```sh
chmod +x check-tls-cert-expiry.sh
```

```sh
while true; do ./check-tls-cert-expiry.sh; sleep 5; done
```
