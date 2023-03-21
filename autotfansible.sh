#!/bin/bash
clear
echo "####################################"
echo "##    AUTOMATE DEVOPS SCRIPT      ##"
echo "####################################"
echo "------------------------------------"
echo "Terraform with Ansible Integration  "
echo "Build infraestructure on Azure Cloud"
echo "----------------------------------"
echo "#    By: Francisco León - UNIR   #" 
echo "----------------------------------"
echo "#  For: Expert DevOps & Cloud    #"
echo "----------------------------------"

folder="$PWD/terraform"

echo ""
echo "** If you want to install Azure CLI, Terraform, Ansible and kubectl." 
echo "$ Type: (install)"
echo ""
echo "** If you want to login with Microsoft Azure Cloud" 
echo "$ Type: (login)"
echo ""
echo "** If you want to destroy terraform infraestructure" 
echo "$ Type: (destroy)"
echo ""
echo "** For planning the builds, the first step is to create a plan:"
echo "$ Type: (plan)"
echo ""
echo "** To execute a full build using Terraform & Ansible"
echo "$ Type: (full)" 
echo ""
echo "** Exit script"
echo "$ Type: (exit)"
echo ""
echo -e "** Your choice is: \c"
read type
echo ""
if [ "$type" == "install" ];then
echo "** Installing AZ CLI"
echo ""
sudo apt-get update
sudo apt-get install libcurl4 curl jq sed python3-pip
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
echo ""
echo "** Installing Terraform"
echo ""
if [  -n "$(uname -a | grep Ubuntu)" ]; then
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform 
else
sudo yum install -y yum-utils curl jq sed python3-pip
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
fi
echo ""
echo "** Installing Ansible"
echo ""
/usr/bin/python3 -m pip install --user ansible
echo "** Updating Installed Ansible"
/usr/bin/python3 -m pip install --upgrade --user ansible
# Added ansible bin to PATH
export PATH="$HOME/.local/bin:$PATH"
echo ""
echo "** Installing kubectl cli"
echo ""
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
echo ""
echo "** All installations were finished successfully"
echo ""
echo "** Reopen script in 5 seconds"
sleep 5
./autotfansible.sh
exit;
elif [ "$type" == "login" ];then
echo "** Microsoft Azure - AZ Login"
echo ""
az login &>/dev/null 
idset=$(az account show | jq -r '.id')
az account set --subscription="$idset"
if [ $? -eq 0 ]; then
    echo "** The login was successful"
else
    echo "** An error ocurred, please try again"
fi
echo ""
echo "** Reopen script in 5 seconds"
sleep 5
./autotfansible.sh
exit;
elif [ "$type" == "destroy" ];then
for i in {1..3}; do terraform -chdir="$folder" destroy -auto-approve;done
echo ""
echo "** All terraform resources were destroyed"
echo ""
echo "** Reopen script in 5 seconds"
sleep 5
./autotfansible.sh
exit;
elif [ "$type" == "plan" ];then
echo "Showing a terraform plan"
echo ""
if [ -d "$folder/.terraform/" ]; then
    echo "** .terraform folder exists"
    terraform -chdir="$folder" init -upgrade
else
   echo "** The .terraform folder does not exist. A new 'terraform init' command will be executed"
terraform -chdir="$folder" init 
fi
terraform -chdir="$folder" plan
echo ""
echo "** This is the planning for the terraform infraestructure."
provider=$(cat "$folder"/main.tf | grep -i provider | sed -n '2s/{//p' | cut -d '"' -f 2-2)
echo ""
echo "** PROVIDER: $provider"
echo ""
read -p "** Press enter to reopen script "
./autotfansible.sh
exit;
elif [ "$type" == "exit" ];then
exit;
elif [ "$type" == "full" ];then
echo ""
echo "** Full option was selected"
echo ""
else
echo "** NO valid option was choice"
exit;
fi
echo "------------------------------"
echo "- Starting terraform process -"
echo "------------------------------"
echo ""
echo "** Validating terraform files with TF format"
terraform -chdir="$folder" fmt
if [ $? -eq 0 ]; then
    echo ""
    echo "The files with TF format were correct"
else
    echo ""
    echo "The format was fixed/modified in selected files"
fi
echo ""
if [ -d "$folder/.terraform/" ]; then
    echo "** .terraform folder exists"
    terraform -chdir="$folder" init -upgrade
else
   echo "** The .terraform folder does not exist. A new 'terraform init' command will be executed"
terraform -chdir="$folder" init 
fi
echo ""
echo "*** Validating files with TF code"
echo ""
terraform -chdir="$folder" validate

echo "** Planning the infraestructure with terraform"
echo ""
terraform -chdir="$folder" plan

echo ""
echo ""
provider=$(cat "$folder"/main.tf | grep -i provider | sed -n '2s/{//p' | cut -d '"' -f 2-2)
echo "** PROVIDER: $provider"
echo ""
echo "** Starting build of infraestructure with Terraform"
echo "** Select (yes) if you want to proceed"
echo ""

terraform -chdir="$folder" apply
if [ $? -eq 0 ]; then
    echo ""
else
    echo "** Sorry an error was produced"
    echo "** Please, fix it and try again"
exit
./autotfansible.sh
fi

echo "----------------------------------"
echo "- Finished with Terraform builds -"
echo "----------------------------------"
echo "** We will wait 1 minute"
echo "** Before starting ansible process"

sleep 30

terraform -chdir="$folder" apply -auto-approve &>/dev/null 

echo ""
echo "---------------------------------"
echo "- Starting builds with ansible  -"
echo "---------------------------------"
echo ""

IP=$(terraform -chdir="$folder" output --json public_ip | jq -r '.[0]')

echo "The IP in Azure VM is: $IP"
echo ""
echo "Creating inventory file with: $IP"
echo ""

inventario="azure_hosts"

if [ -f "$inventario" ]; then
    echo "The inventory file exists, the file will be deleted"
    echo ""
    rm "$inventario"
    touch "$inventario"
else
    touch "$inventario"
    echo "** A new inventory file was created"
fi

uservm="franlov@"

echo "[unir_azure]" > "$inventario" 
echo "$uservm$IP" >> "$inventario"

cat "$inventario"
echo ""
echo "** Creating file for ansible variables"
echo ""

varsfile="vars_acr.yml"
vardir="ansible/vars/"
if [ -f "$vardir$varsfile" ]; then
    echo "The variables file exists, the file will be deleted"
    rm "$vardir$varsfile"
else
    touch "$vardir$varsfile"
    echo "** A new variables file was created $vardir$varsfile"
fi

user_reg=$(terraform -chdir="$folder" output admin_username) 

echo "user_reg: $user_reg" >> "$vardir$varsfile"

password_reg=$(terraform -chdir="$folder" output admin_password) 

echo "password_reg: $password_reg" >> "$vardir$varsfile"

url_reg=$(terraform -chdir="$folder" output acr_login_server)

echo "url_reg: $url_reg" >> "$vardir$varsfile"
echo ""
echo "** The variables file was written"
echo ""
echo "** Starting ansible process"
playbook="ansible/podman.yml"
ansible-playbook -i "$inventario" "$playbook"
if [ $? -eq 0 ]; then
echo 
else
    echo "** An error was produced"
    echo "** Please fix it and try again"
    echo ""
read -p "** Press enter to reopen script "
./autotfansible.sh
exit
fi
echo ""
playbook_pod="ansible/image_pod.yml"
ansible-playbook -i "$inventario" "$playbook_pod"
if [ $? -eq 0 ]; then
echo ""
else
    echo "** An error was produced"
    echo "** Please fix it and try again"
    echo ""
read -p "** Press enter to reopen script "
./autotfansible.sh
exit
fi
echo "-----------------------------------------------------------"
echo "- Starting builds with AKS - Azure Kubernetes Cluster     -"
echo "-----------------------------------------------------------"
echo ""
rg=$(az group list | jq -r '.[1].name')
name_aks=$(az group list | jq -r '.[2].tags."aks-managed-cluster-name"')
fqdn=$(az aks show --resource-group $rg --name $name_aks --query fqdn -o tsv)
echo "AKS Cluster fqdn: $fqdn"
echo ""
kubeconfig="$HOME/.kube/config"
if [ -f "$kubeconfig" ]; then
    echo "The kube-config file exists, the file will be renamed"
    echo ""
    mv "$kubeconfig" "$kubeconfig"_old
else
    echo "** A new kubeconfig file will be create"
    echo ""
fi
name_aks=$(az group list | jq -r '.[2].tags."aks-managed-cluster-name"')
echo "AKS Cluster name in resource group: $rg is: $name_aks"
echo ""
id_suscription=$(az aks show --resource-group $rg --name $name_aks --query id -o tsv | cut -d '/' -f 3-3)
echo "** Logging with AKS suscription"
az account set --subscription $id_suscription
echo ""
echo "** Obtain credentials to Azure Resource Group"
az aks get-credentials --resource-group $rg --name $name_aks
echo ""
playbook_aks="ansible/aks_cluster.yml"
ansible-playbook "$playbook_aks"
if [ $? -eq 0 ]; then
echo ""
namespace=$(kubectl get namespaces | awk 'NR==2{print $1}')
echo "** Showing all resources on $fqdn"
echo ""
kubectl get all -n $namespace
echo ""
echo "** Showing the pod on namespace $namespace"
echo ""
kubectl get pods -n $namespace
echo ""
echo "** Showing services from namespace $namespace"
echo ""
kubectl get services -n $namespace
echo ""
echo "** Loading Load Balancer external IP, wait 30 seconds please."
echo ""
sleep 30
ip_ext=$(kubectl get services -n $namespace | awk 'NR==2{print $4}')
echo "** The Load Balancer external IP to connect is: $ip_ext"
echo ""
echo "** Encripting sensible data file, please enter a password to encrypt"
echo ""
ansible-vault encrypt $vardir$varsfile
echo ""
    echo "#############################################"
    echo "All commands were executed without any errors"
    echo "#############################################"
    echo "# AUTOMATE DEVOPS SCRIPT BY FRANCISCO LEON  #"
    echo "#############################################" 
    echo ""
else
    echo "** An error was produced"
    echo "** Please fix it and try again"
    echo ""
read -p "** Press enter to reopen script "
fi















