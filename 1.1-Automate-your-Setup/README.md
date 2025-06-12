
# Automate Your Environment Setup 

If you have Terraform configured, you can run these Terraform files to provision the Ubuntu VM with the below specification.

#### ☁️ Recommended VM Capacity

For a smooth experience, especially when running Kind clusters and monitoring tools:

| Resource     | Recommended Minimum |
|--------------|---------------------|
| **CPU**      | 2 vCPUs             |
| **RAM**      | 8 GB ideal          |
| **Storage**  | 30 GB SSD           |
| **OS**       | Ubuntu 22.04 LTS    |

---

## 📦 Setup Instructions

### 0. Create the Infrastructure

> Please ensure you have properly configured the Terraform backend for state management and AWS authentication. For this project I used HCP Terraform for my backend. 

Clone this repository. 
```
git clone https://github.com/frankfolabi/learn-cloud-native.git
cd learn-cloud-native/1.1-Automate-your-Setup
```

Run the following commands to initialize Terraform
```
terraform init
terraform plan
terraform apply
```
Terrafom output displays the Public IP and marks the private key as a sensitive data. 

Obtain the private key and connect to the Ubuntu instance:
```
terraform output private_key_pem > lab_key.pem
chmod 0600 lab_key.pem
ssh -i lab_key.pem ubuntu@<Public IP>
```
The `lab_key.pem` is a sensitive data. Never add it to your version control system.

### 1. Upgrade System and Install Docker

You may use scp to first transfer the [docker-setup.sh](./docker-setup.sh) script to the VM and execute or copy and run the script in the SSH terminal session.

***⚠️ The script logs you out for the Docker group to apply. Start a new SSH session to continue.***

### 2. Install Kubernetes
You may choose to scp [k8s-setup.sh](./k8s-setup.sh) script to the VM and execute or copy and run the script in the SSH terminal session.

### 3. System Check 

Verify that all the packages were properly installed.

```
kubectl cluster-info
docker --version
kubectl version --client
kind version
helm version
git --version
```

A common error is connection refused and this can be fixed with 

```
kubectl config use-context kind-tws-cluster
```

### 4.  Optional but helpful
- [x] Install Visual Studio Code on your Local PC (for Remote SSH extension)

- [x] Install tmux on your VM, for managing multiple sessions

```
sudo apt install -y tmux
```

* Other useful commands with tmux
```
# start a session
tmux new -s mysession

#view all sessions
tmux ls

#attach a session
tmux attach -t mysession
```

Enjoy the k8s journey with me!
---