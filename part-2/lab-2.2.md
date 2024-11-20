# Lab 2.2 – The “Classic” App Stack Monitoring

## Step 1: Let’s start up our Spring Boot app

```sh
# Clone the Spring Boot app
cd ~
git clone https://github.com/brightzheng100/springboot-swagger-jpa-stack.git
cd springboot-swagger-jpa-stack

# Start it up
# Make sure you see something like:
# ==> [INFO] TomcatWebServer(220) - Tomcat started on port(s): 8080 (http) with context path ''
# ==> [INFO] Application(61) - Started Application in 3.977 seconds (JVM running for 4.631)
mvn spring-boot:run

# Ctrl + C to stop it

# And start it again at the background
nohup bash -c "mvn spring-boot:start" &> app.out & echo $! > app.pid

# Tail the logs 
tail -f app.out

# Ctrl + C to quit tailing

# Perform some checks
# Health Check
curl http://localhost:8080/actuator/health | jq
```


## Step 2: Run the load-gen.sh

```sh
nohup bash -c "./load-gen.sh" &> load.out & echo $! > load.pid
```


## Step 4: Deploy the VM-based agent

Optional, after deploying the agent script, if you want to further control the agent resource:

```sh
sudo systemctl edit instana-agent
```

Add this as the content:

```conf
[Service]
CPUAccounting=true
CPUQuota=50%            # 0.5 CPU
MemoryAccounting=true
MemoryMax=750M          # 750M memory, defaults to 512M
```

Restart:

```sh
sudo systemctl daemon-reload
sudo systemctl restart instana-agent
```


## Step 6: Tune the agent’s configuration

```sh
# You may take a look at the default configuraiton files
ls /opt/instana/agent/etc/instana/

# Touch the file just to show you it's a new file actually
touch /opt/instana/agent/etc/instana/configuration-zone.yaml

# Make sure you're using your identifier to replace the "x" here
# So it may look like: INSTANA_ZONE="Student-99-Zone" ...
INSTANA_ZONE="Student-x-Zone" && \
cat <<EOF | sudo tee /opt/instana/agent/etc/instana/configuration-zone.yaml
# Hardware & Zone
com.instana.plugin.generic.hardware:
  enabled: true
  availability-zone: "${INSTANA_ZONE}"
EOF
```


## Step 7: How if I deploy new technologies now?

Run this if you're with `RHEL/Centos`:

```sh
# Install httpd
sudo dnf install httpd -y

# Enable server status
cat <<EOF | sudo tee -a /etc/httpd/conf/httpd.conf
ExtendedStatus on
<Location /server-status>
  SetHandler server-status
  Order deny,allow
  Allow from 127.0.0.1
</Location>
EOF

# Start up
sudo systemctl start httpd
```

Or this if you're with `Ubuntu`:

```sh
# Install apache2
sudo apt-get install -y apache2

# Enable server status
cat <<EOF | sudo tee -a /etc/apache2/apache2.conf
ExtendedStatus on
<Location /server-status>
  SetHandler server-status
  Order deny,allow
  Allow from 127.0.0.1
</Location>
EOF

# Start up
sudo systemctl start apache2
```


## Clean Up

Assuming we're in the Git repository's directory, say `~/springboot-swagger-jpa-stack`.

```sh
# 1. Kill the load-gen
kill $(cat load.pid)

# 2. Stop the app
mvn spring-boot:stop

# 3. Uninstall the Apache HTTPd
# Run this in RHEL/CentOS
sudo dnf remove httpd -y
# Or, run this in Ubuntu
sudo apt-get remove apache2 -y

# 4. Stop Instana agent (as we need it later in Part 3 of the labs)
sudo systemctl stop instana-agent
```
