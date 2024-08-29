# Instana Hands-on Labs' Scripts / Commands

## Overview

This repo contains the copy-paste friendly scripts/commands for my Instana hands-on labs.

Currently, the labs incllude 3 parts:

```
Part 1. Instana Backend Installation
Lab 1.1 – Install Instana Classic Edition Manually
Lab 1.2 – Install Instana Classic Edition by Ansible Playbooks
Lab 1.3 – Install Instana Standard Edition by “stanctl”

Part 2. Core Capabilities & Use Cases
Lab 2.1 – A Quick Instana Tour
Lab 2.2 – The “Classic” App Stack Monitoring
Lab 2.3 – Website Monitoring
Lab 2.4 – Install & Manage Agents
Lab 2.5 – Application Monitoring
Lab 2.6 – Infrastructure Monitoring

Part 3. Advanced Topics
Lab 3.1 – Events, Analytics and Troubleshooting
Lab 3.2 – Alerts & Channels
Lab 3.3 – SLO Monitoring with Custom Dashboard
Lab 3.4 – RBAC & User Onboarding
Lab 3.5 – Custom Metrics (e.g. Cert Expiry Check)
Lab 3.6 – Configuration-based Instrumentation
Lab 3.7 – OpenTelemetry Support in Instana
Lab 3.8 – Language-specific apps monitoring practices - Python
Lab 3.9 – Language-specific apps monitoring practices - Node.js
```

## How to obtain the scripts/commands?

```sh
git clone https://github.com/brightzheng100/instana-handson-labs.git
cd instana-handson-labs
ls -l
```

## Versions

The labs are evolving.

## Current Labs Architecture, aka V3

Current labs architecture is dynamic, which will be transitioned from VM-based to Kubeadm-bootstrapped Kubernetes based experience.

This is the current labs architecture:

![Labs Architecture v3](./misc/labs-architecture-v3.jpg)

```sh
git clone https://github.com/brightzheng100/instana-handson-labs.git
cd instana-handson-labs
ls -l
```

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
