# Lab 2.3 – Install & Manage Agents

## 6. Linux VM agent – Install agent

Run this in the Host VM:

```sh
# cd to the home folder
$ cd ~

# List out the footloose-powered VMs we have
$ footloose show -c footloose.yaml

# Log into the Ubuntu VM
$ footloose ssh root@ubuntu-0 -c footloose.yaml
```

Once SSH'ed into the Ubuntu "VM" powered by `footloose`:

```
root@ubuntu-0:~# apt-get update
root@ubuntu-0:~# apt-get install gpg apt-utils -y

root@ubuntu-0:~# curl -o setup_agent.sh https://setup.instana.io/agent && chmod 700 ./setup_agent.sh && sudo ./setup_agent.sh -a xxxxxxxxxxxxxxxxxx -d xxxxxxxxxxxxxxxxxx -t dynamic -e 168.1.53.231.nip.io:1444 -y 
```

```
# By default, the agent is not up and running after installation
root@ubuntu-0:~# systemctl status instana-agent
```


```
# Configure zone
root@ubuntu-0:~# touch /opt/instana/agent/etc/instana/configuration-zone.yaml
root@ubuntu-0:~# INSTANA_ZONE="Student-1-Zone" && \
cat <<EOF | sudo tee /opt/instana/agent/etc/instana/configuration-zone.yaml
# Hardware & Zone
com.instana.plugin.generic.hardware:
  enabled: true
  availability-zone: "${INSTANA_ZONE}"
EOF

# (optional) Configure host, like tags
# Do change them accordingly
root@ubuntu-0:~# touch /opt/instana/agent/etc/instana/configuration-host.yaml
root@ubuntu-0:~# cat <<EOF | sudo tee /opt/instana/agent/etc/instana/configuration-host.yaml
# Host
com.instana.plugin.host:
  tags:
    - 'labs'
    - 'poc'
    - 'instana'
EOF
```

```
# Start it up
root@ubuntu-0:~# systemctl enable instana-agent
root@ubuntu-0:~# systemctl start instana-agent

# We can trace the logs too
root@ubuntu-0:~# journalctl -flu instana-agent
```
