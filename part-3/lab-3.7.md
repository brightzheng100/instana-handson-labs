# Lab 3.6 – OpenTelemetry Support in Instana

## Step 1: Start up the Spring Boot app, with OpenTelemetry agent enabled

```sh
cat <<EOF | sudo tee /opt/instana/agent/etc/instana/configuration-otel.yaml
com.instana.plugin.opentelemetry:
  grpc:
    enabled: true   # grpc endpoint
  http:
    enabled: true   # http endpoint
EOF
```

```sh
cat <<EOF | sudo tee /opt/instana/agent/etc/instana/configuration-javatrace.yaml
com.instana.plugin.javatrace:
  instrumentation:
    enabled: false
EOF
```

```sh
sudo systemctl restart instana-agent
```

```sh
cd ~/springboot-swagger-jpa-stack

wget https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar
```

```sh
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317

nohup bash -c "mvn spring-boot:run -Dspring-boot.run.jvmArguments=\"-javaagent:`pwd`/opentelemetry-javaagent.jar\"" &> app.out & echo $! > app.pid
```

```sh
# Health Check
curl http://localhost:8080/actuator/health | jq
```

## Step 2: Run the load-gen.sh

```sh
nohup bash -c "./load-gen.sh" &> load.out & echo $! > load.pid
```
