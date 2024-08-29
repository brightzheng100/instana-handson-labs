# Lab 3.8 – Language-specific app monitoring practices - Python

## Step 1. Let’s take a look the Python web app

```sh
$ git clone https://github.com/brightzheng100/python-example.git
$ cd python-example
```

## Step 2. Setup the app env

```sh
$ python3 -m venv .venv --prompt app
$ source .venv/bin/activate
$ python -m pip install Flask
```

## Step 3. Run the app

```sh
$ nohup bash -c "python -m flask --app board run --host=0.0.0.0 --port 8080" &> app.out & echo $! > app.pid
```

## Step 4. Generate some traffic

```sh
$ nohup bash -c "while true; do curl -sS -D – 127.0.0.1:8080; sleep 1; done;" &> load.out & echo $! > load.pid
```

## Step 5. What we’ve got?

## Step 6. Make Python work happily with Instana

```sh
$ pip install git+https://github.com/instana/python-sensor@v2.5.2
```

```sh
$ kill -9 $(cat app.pid)
$ nohup bash -c "AUTOWRAPT_BOOTSTRAP=instana INSTANA_SERVICE_NAME=my-cool-python-app INSTANA_DEBUG=true python -m flask --app board run --host=0.0.0.0 --port 8080" &> app.out & echo $! > app.pid
```

## Step 7. Final outcomes

## Step 8. Extra Reading

```sh
$ cat <<EOF >> ~/.bashrc
export AUTOWRAPT_BOOTSTRAP=instana
EOF

$ kill -9 $(cat app.pid)
$ nohup bash -c "INSTANA_SERVICE_NAME=my-cool-python-app python -m flask --app board run --host=0.0.0.0 --port 8080" &> app.out & echo $! > app.pid
```

```sh
$ sudo systemctl edit abc
```

```conf
[Service]
Environment="AUTOWRAPT_BOOTSTRAP=instana"
Environment="INSTANA_SERVICE_NAME=my-cool-python-app"
```

```sh
$ sudo systemctl daemon-reload
$ sudo systemctl restart abc
```

## Clean Up

```sh
# Kill the load-gen
$ kill -9 $(cat load.pid)

# Kill the app
$ kill -9 $(cat app.pid)
```
