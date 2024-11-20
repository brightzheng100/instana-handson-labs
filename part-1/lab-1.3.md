# Lab 1.3 – Install Instana Classic Edition by Ansible Playbooks

## 1. Clone the repo:

```sh
git clone https://github.com/brightzheng100/instana-server-ansible.git

cd instana-server-ansible
```

## 2. Generate SSH key and copy the public key to the server:

```sh
# Let's generate the SSH key pair and save them to current folder as `id_rsa` and `id_rsa.pub`
# Don't worry, these files will be ignored by this repo's .gitignore
$ ssh-keygen

# Copy the generated public key to the server and trust it
# Replace <USER> and <INSTANA_SERVER_IP> with proper values
# Note:
# 1. The <USER> must be the user that configuired in next step in `hosts`
# 2. If we have to authenticate by SSH key to run `ssh-copy-id` command, with custom SSH port, use this command instead:
#       ssh-copy-id -i id_rsa.pub -o 'IdentityFile <THE-PATH-TO-YOUR-KEY-FOR-AUTHENTICATION>' -p <SSH CUSTOM PORT> <USER>@<INSTANA_SERVER_IP>
#    For example:
#       ssh-copy-id -f -i id_rsa.pub -o 'IdentityFile original_key.pem' -p 2223 itzuser@168.1.53.214
$ ssh-copy-id -i id_rsa.pub <USER>@<INSTANA_SERVER_IP>
```

## 3. Create a `hosts` file
 
> NOTE: 
> 1. There is a `hosts.sample` file for your reference
> 2. DO USE THE RIGHT IP FOR BELOW COMMAND!
> 3. If the OS user is not `root` and/or the port is not `22`, we must explicitly specify like: `xxx.xxx.xxx.xxx ansible_user=itzuser ansible_port=2223`

```sh
$ cat > hosts <<EOF
[instana]
# The IP/FQDN of your Instana Server
# Optionally, we can specify OS user, SSH port etc. like: 
# xxx.xxx.xxx.xxx ansible_user=itzuser ansible_port=2223
xxx.xxx.xxx.xxx
EOF
```

## 4. Create a `settings.json` with required variables.

There are a few required variables:
- `instana_server_fqdn`: the FQDN of Instana Server. Using IP is also fine
- `instana_tenant`: the tenant code, which should be your company name, for example `ibm`
- `instana_unit`: the unit code, which could be the owner department, for example `apac`
- `instana_agent_key`: the agent key that you got from Instana license request
- `instana_download_key`: the download key that you got from Instana license request, typically same as agent key
- `instana_sales_key`: the sales key that you got from Instana license request

> NOTE: DE USE THE RIGHT VALUES FOR BELOW COMMAND!

```bash
$ cat > settings.json <<EOF
{
  "instana_server_fqdn":    "<The FQDN, or IP of Instana Server>",
  "instana_tenant":         "<The tenant code, e.g. ibm>",
  "instana_unit":           "<The unit code, e.g. apac>",
  "instana_agent_key":      "<The agent key from the Instana license request>",
  "instana_download_key":   "<The download key from the Instana license request>",
  "instana_sales_key":      "<The sales key from the Instana license request>",
  "instana_metrics_mount":  "/mnt/metrics",
  "instana_traces_mount":   "/mnt/traces",
  "instana_data_mount":     "/mnt/data"
}
EOF
```

For example, we may have exposed some sensitive elements and apply the command like this:

```sh
# Expose some sensitive elements first
# All these 3 keys are from Instana license request
export instana_agent_key="xxx"
export instana_download_key="xxx"
export instana_sales_key="xxx"

# Then run it
$ instana_server_fqdn="168.1.53.214.nip.io" && \
  instana_tenant="ibm" && \
  instana_unit="apac" && \
  cat > settings.json <<EOF
{
  "instana_server_fqdn":    "${instana_server_fqdn}",
  "instana_tenant":         "${instana_tenant}",
  "instana_unit":           "${instana_unit}",
  "instana_agent_key":      "${instana_agent_key}",
  "instana_download_key":   "${instana_download_key}",
  "instana_sales_key":      "${instana_sales_key}",
  "instana_metrics_mount":  "/mnt/metrics",
  "instana_traces_mount":   "/mnt/traces",
  "instana_data_mount":     "/mnt/data"
}
EOF
```

## 5. Run Ansible Playbooks

Follow [this document](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) to install Ansible on MacOS/Windows/Linux, if you haven't done so.

Then kick off the installation process with Ansible:

```bash
$ ansible-playbook main.yml --extra-vars "@settings.json"
```

It would typically take around 30-50mins to complete the whole process.

At the end of the output, you should be able to see something like this:

```log
...
TASK [instana : debug] ******************************
ok: [168.1.53.214] => {
    "logs.stdout_lines[-5:]": [
        "Welcome to the World of Automatic Infrastructure and Application Monitoring",
        "",
        "https://168.1.53.214.nip.io",
        "E-Mail: admin@instana.local",
        "Password: xxxxxxxxx"
    ]
}
```

Please note that Ansible playbooks are kind of idempotent from end-user perspective, re-run it if you encountered intermittent errors.
