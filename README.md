# Instana Hands-on Labs' Scripts / Commands

## Overview

This repo contains the copy-paste friendly scripts/commands for my Instana hands-on labs.

Currently, the labs incllude 3 parts:

```
PART 1. INSTANA SERVER INSTALLATION
LAB 1.1 – INSTALL INSTANA SERVER MANUALLY
LAB 1.2 – INSTALL INSTANA SERVER BY ANSIBLE PLAYBOOKS


PART 2. CORE CAPABILITIES & USE CASES
LAB 2.1 – A QUICK INSTANA TOUR
LAB 2.2 – THE “CLASSIC” APP STACK MONITORING
LAB 2.3 – WEBSITE MONITORING
LAB 2.4 – INSTALL & MANAGE AGENTS
LAB 2.5 – APPLICATION MONITORING
LAB 2.6 – INFRASTRUCTURE MONITORING


PART 3. ADVANCED TOPICS
LAB 3.1 – EVENTS, ANALYTICS AND TROUBLESHOOTING
LAB 3.2 – ALERTS & CHANNELS
LAB 3.3 – SLO MONITORING WITH CUSTOM DASHBOARD
LAB 3.4 – RBAC & USER ONBOARDING
LAB 3.5 – CUSTOM METRICS (E.G. CERT EXPIRY CHECK)
LAB 3.6 – CONFIGURATION-BASED INSTRUMENTATION
LAB 3.7 – OPENTELEMETRY SUPPORT IN INSTANA
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
