# Run Robot Shop App in Docker

I've made necessary changes to simplify how to run Robot Shop app in Docker.

Firstly, let's expose some system variables:

```sh
export INSTANA_AGENT_KEY="<YOUR AGENT KEY>"
export INSTANA_DOWNLOAD_KEY="<YOUR DOWNLOAD KEY, which typically is the same as INSTANA_AGENT_KEY>"
export INSTANA_EUM_REPORTING_URL="<YOUR EUM REPORTING URL, e.g. https://162.133.113.8.nip.io:446/eum/, that can be seen in your website->Configuration>"
export INSTANA_AGENT_ENDPOINT="<YOUR BACKEND ENDPOINT, e.g. 162.133.113.8.nip.io>"

export INSTANA_EUM_KEY="<YOUR WEBSITE EUM KEY, e.g. sWavnYHnRD-zs7WiHaRJMx, that can be seen in your website->Configuration>"
export INSTANA_AGENT_ZONE="<YOUR ZONE, e.g. Student-x-Zone>
```

## Remove the kind and footloose environment

You may remove the exisiting `kind` and `footloose` env, by doing this in your assigned sandbox:

```sh
cd ~
footloose delete -c footloose.yaml
kind delete cluster -n kind
```

If you've installed the agent into the sandbox VM, you should stop and remove it as well:

```sh
sudo systemctl stop instana-agent
sudo apt-get remove instana-agent-dynamic
```

## App

```sh
# Clone the repo with the right branch
cd ~
git clone https://github.com/brightzheng100/robot-shop.git robot-shop-bright
cd ~/robot-shop-bright
git checkout selenium-load-gen


# Install Docker Compose
sudo apt-get install docker-compose -y


# Run it
# If first time we should have --build flag to build images locally
docker-compose -f docker-compose.yaml -f docker-compose-load.yaml up -d --build
# Subsequently, run it without --build
docker-compose -f docker-compose.yaml -f docker-compose-load.yaml up -d

# Shut it down if needed
# docker-compose -f docker-compose.yaml -f docker-compose-load.yaml down
```

## Agent

The Instana agent can be deployed on either Docker or the host directly.

For now, let's install the agent on Docker.

```sh
# Delete: docker rm instana-agent -f
docker run \
    --detach \
    --name instana-agent \
    --volume /var/run:/var/run \
    --volume /run:/run \
    --volume /dev:/dev:ro \
    --volume /sys:/sys:ro \
    --volume /var/log:/var/log:ro \
    --privileged \
    --net=host \
    --pid=host \
    --env="INSTANA_AGENT_ENDPOINT=${INSTANA_AGENT_ENDPOINT}" \
    --env="INSTANA_AGENT_ENDPOINT_PORT=1444" \
    --env="INSTANA_AGENT_KEY=${INSTANA_AGENT_KEY}" \
    --env="INSTANA_DOWNLOAD_KEY=${INSTANA_DOWNLOAD_KEY}" \
    --env="INSTANA_AGENT_ZONE=${INSTANA_AGENT_ZONE}" \
    --cpus=0.5 --memory=512m \
    icr.io/instana/agent

# Check the logs
docker logs instana-agent -f
```

> Note: the agent's extra custom configuration can be injected by volume mount. For example:

```sh
cat > configuration-statsd.yaml <<EOF
com.instana.plugin.statsd:
  enabled: true
  ports:
    udp: 8125
    mgmt: 8126
  bind-ip: "0.0.0.0" # all IPs by default
  flush-interval: 10 # in seconds
EOF

docker rm instana-agent -f

docker run \
    --detach \
    --name instana-agent \
    --volume /var/run:/var/run \
    --volume /run:/run \
    --volume /dev:/dev:ro \
    --volume /sys:/sys:ro \
    --volume /var/log:/var/log:ro \
    --privileged \
    --net=host \
    --pid=host \
    --env="INSTANA_AGENT_ENDPOINT=${INSTANA_AGENT_ENDPOINT}" \
    --env="INSTANA_AGENT_ENDPOINT_PORT=1444" \
    --env="INSTANA_AGENT_KEY=${INSTANA_AGENT_KEY}" \
    --env="INSTANA_DOWNLOAD_KEY=${INSTANA_DOWNLOAD_KEY}" \
    --env="INSTANA_AGENT_ZONE=${INSTANA_AGENT_ZONE}" \
    --cpus=0.5 --memory=512m \
    --volume configuration-statsd.yaml:/opt/instana/agent/etc/instana/configuration-statsd.yaml \
    icr.io/instana/agent
```