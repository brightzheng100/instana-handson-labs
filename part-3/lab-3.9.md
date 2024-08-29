# Lab 3.8 – Language-specific app monitoring practices - Python

## Step 1. Let’s take a look the Node.js web app

```sh
$ git clone https://github.com/brightzheng100/nodejs-example.git
$ cd nodejs-example
```

## Step 2. Setup the app

```sh
$ npm install
```

## Step 3. Run the app

```sh
$ npm start

# Or
$ PORT=8080 npm start
```

```sh
$ nohup bash -c "PORT=8080 npm start" &> app.out & echo $! > app.pid
```

```sh
$ curl -sS -D – 127.0.0.1:8080
```

## Step 4. Generate some traffic

```sh
$ nohup bash -c "while true; do curl -sS -D – 127.0.0.1:8080; sleep 1; done;" &> load.out & echo $! > load.pid
```

## Step 5. What we’ve got?

## Step 6. Make Node.js work happily with Instana

```sh
$ npm install --save @instana/collector
```

```sh
$ kill -9 $(cat app.pid)
$ nohup bash -c "NODE_OPTIONS='--require ./node_modules/@instana/collector/src/immediate' PORT=8080 npm start" &> app.out & echo $! > app.pid
```

```sh
$ kill -9 $(cat app.pid)
$ nohup bash -c "NODE_OPTIONS='--require ./node_modules/@instana/collector/src/immediate' INSTANA_SERVICE_NAME=my-cool-nodejs-app INSTANA_DEBUG=true PORT=8080 npm start" &> app.out & echo $! > app.pid
```

## Step 7. Final outcomes

## Clean Up

```sh
# Kill the load-gen
$ kill -9 $(cat load.pid)

# Kill the app
$ kill -9 $(cat app.pid)
```
