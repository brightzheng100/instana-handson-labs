# Preparing the “manage-to” Host, on Red Hat Enterprise Linux (aka RHEL)

## Install JDK

```sh
sudo dnf install java-1.8.0-openjdk-devel -y
```

> Note: if you want to install other OpenJDK version, pick your own desired version instead:

```sh
# To install OpenJDK v1.8, do this:
sudo dnf install java-1.8.0-openjdk-devel -y

# To install OpenJDK v11, do this:
sudo dnf install java-11-openjdk-devel -y

# To install OpenJDK v17, do this:
sudo dnf install java-17-openjdk-devel -y
```

You may verify that by:

```sh
$ java -version
openjdk version "1.8.0_372"
OpenJDK Runtime Environment (build 1.8.0_372-b07)
OpenJDK 64-Bit Server VM (build 25.372-b07, mixed mode)
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
Apache Maven 3.9.8 (c9616018c7a021c1c39be70fb2843d6f5f9b8a1c)
Maven home: /home/itzuser/apache-maven-3.9.8
Java version: 1.8.0_372, vendor: Red Hat, Inc., runtime: /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.372.b07-4.el8.x86_64/jre
Default locale: en_US, platform encoding: ANSI_X3.4-1968
OS name: "linux", version: "4.18.0-425.19.2.el8_7.x86_64", arch: "amd64", family: "unix"
```

## Install Node.js

```sh
$ sudo dnf install nodejs -y
$ node --version
$ npm --version
```

## Install other necessary tools

```sh
# Git
sudo dnf install git -y

# jq
sudo dnf install jq -y

# Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
