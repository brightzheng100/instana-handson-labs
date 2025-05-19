# Preparing the “manage-to” Host, on Ubuntu

## Patch the /etc/hosts

Just to avoid the potentially annoying warning like “sudo: unable to resolve host xxx: Name or service not known” in TechZone's Ubuntu:

```sh
sudo sed -i "1s/$/ `hostname`/" /etc/hosts
```

## Install JDK

```sh
sudo apt-get update
sudo apt-get install openjdk-8-jdk -y
```

> Note: if you want to install other OpenJDK version, pick your own desired version instead:

```sh
# To install OpenJDK v11, do this:
sudo apt-get install openjdk-11-jdk -y

# To install OpenJDK v17, do this:
sudo apt-get install openjdk-17-jdk -y
```

You may verify that by:

```sh
$ java -version
openjdk version "1.8.0_362"
OpenJDK Runtime Environment (build 1.8.0_362-8u372-ga~us1-0ubuntu1~20.04-b09)
OpenJDK 64-Bit Server VM (build 25.362-b09, mixed mode)
```

## Install Maven

```sh
# Download Maven
wget https://dlcdn.apache.org/maven/maven-3/3.9.8/binaries/apache-maven-3.9.8-bin.tar.gz

# Untar it
tar -xvf apache-maven-3.9.8-bin.tar.gz

# Add the path into ~/.bashrc
echo 'PATH=$HOME/apache-maven-3.9.8/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

You may verify that by:

```sh
$ mvn -version
Maven home: /home/itzuser/apache-maven-3.9.8
Java version: 1.8.0_362, vendor: Private Build, runtime: /usr/lib/jvm/java-8-openjdk-amd64/jre
Default locale: en, platform encoding: UTF-8
OS name: "linux", version: "5.4.0-139-generic", arch: "amd64", family: "unix"
```

## Install Node.js

```sh
$ sudo apt-get install nodejs npm -y
$ node --version
$ npm --version
```


## Install other necessary tools

```sh
# Git should have been installed by default
# If not, run this
sudo apt-get install git -y

# jq
sudo apt-get install jq -y

# Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
