# Instana Labs' Scripts / Commands

## Overview

This repo contains the copy-paste friendly scripts/commands for my Instana hands-on labs.

How to obtain it?

```sh
git clone https://github.com/brightzheng100/instana-handson-labs.git
cd instana-handson-labs
ls -l
```

## Versions

The labs are evolving.

## Previous Labs Architecture, aka V1, V2

V1, v2 were based on `Kind` for Kubernetes and `footloose` for VM-based experience, like this:

![Labs Architecture v1, v2](./misc/labs-architecture-v1-2.jpg)

But actually these environments are not officially supported even they work.

If you really want to try it out, do this:

```sh
git clone https://github.com/brightzheng100/instana-handson-labs.git
cd instana-handson-labs
git checkout labs-v2
ls -l
```

## Current Labs Architecture, aka V3

Current labs architecture is dynamic, which will be transitioned from VM-based to Kubeadm-bootstrapped Kubernetes based experience, like this:

![Labs Architecture v3](./misc/labs-architecture-v3.jpg)

This is the current labs architecture:

```sh
git clone https://github.com/brightzheng100/instana-handson-labs.git
cd instana-handson-labs
ls -l
```
