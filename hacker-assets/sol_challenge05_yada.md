# Secure Networking Artifacts
## Challenge 05 - Deploying YADA in Germany West Central

You can use these commands to deploy the YADA app to an existing resource group (note that you will need to update some of the variables):

```bash
# Set variables for Azure environment
# Note. You can change the values of these variables to suit your environment.
# Define the Azure location where you want to deploy the resources
location=germanywestcentral

# Define the name of the resource groups
rg=rg-yada-gwc01

# Note. This script assumes that you have not already created a resource group in Azure.
# You can use the following command to create one:
# Create resource groups
az group create -n $rg -l $location

######## Deploy Spoke Network aka Workload Network ########
# Set Variables for Spoke Network
spoke_vnet_name=vnet-yada-gwc01
spoke_vnet_prefix=10.2.16.0/22
web_subnet_name=WebSubnet
web_subnet_prefix=10.2.16.0/26
api_subnet_name=ApiSubnet
api_subnet_prefix=10.2.16.64/26

# Create Network Security Groups for Spoke subnets
az network nsg create -n web-nsg -g $rg -l $location
az network nsg create -n api-nsg -g $rg -l $location

# Create spoke virtual network
az network vnet create -g $rg -n $spoke_vnet_name --address-prefix $spoke_vnet_prefix -l $location
az network vnet subnet create -g $rg -n $web_subnet_name --vnet-name $spoke_vnet_name --address-prefix $web_subnet_prefix --network-security-group web-nsg
az network vnet subnet create -g $rg -n $api_subnet_name --vnet-name $spoke_vnet_name --address-prefix $api_subnet_prefix --network-security-group api-nsg

######## Update NSG Rules for Spoke Network ########
# Update NSG Rules for Spoke Network (These are just sample starter rules. You will need to update them to allow and deny your specific traffic.)
echo "Updating NSGs Rules..."
az network nsg rule create -n WebIn --nsg-name "web-nsg" -g $rg --priority 1000 --destination-port-ranges 80 --access Allow --protocol Tcp -o none
az network nsg rule create -n AdminIn --nsg-name "web-nsg" -g $rg --priority 1020 --destination-port-ranges 22 3389 --access Allow --protocol Tcp -o none
az network nsg rule create -n ApiIn --nsg-name "api-nsg" -g $rg --priority 1010 --destination-port-ranges 8080 --access Allow --protocol Tcp -o none
az network nsg rule create -n AdminIn --nsg-name "api-nsg" -g $rg --priority 1020 --destination-port-ranges 22 3389 --access Allow --protocol Tcp -o none
az network vnet subnet update -n $web_subnet_name --vnet-name $spoke_vnet_name -g $rg --network-security-group web-nsg -o none
az network vnet subnet update -n $api_subnet_name --vnet-name $spoke_vnet_name -g $rg --network-security-group api-nsg -o none

######## Deploy YADA ########

########--------------------------########

# Variables for SQL Server
# You can use either IP address or FQDN
sql_server_fqdn=10.0.2.4
sql_db_name=mydb
sql_username=sqladmin@yourAzureSqlServerName
sql_password='demo!pass123'

# Variables for IaaS-based workload
offer="0001-com-ubuntu-server-focal"
publisher="Canonical"
sku="20_04-lts-gen2"
version=latest
vm_size=Standard_D2s_v3 # Depending on your scenario you may want to use a different VM size
ilb_api=10.2.16.68 # Update this with the private IP address of the Internal Load Balancer for the API tier
api_image='erjosito/yadaapi:1.0'
web_image='erjosito/yadaweb:1.0'

# Credentials for IaaS-based workload
adminuser='demouser'
pw='demo!pass123'

########--------------------------########

# Deploy Virtual Machines for YADA

########--------------------------########

# Accept image terms
# echo "Accepting image terms for $publisher:$offer:$sku..."
# az vm image terms accept -p $publisher -f $offer --plan $sku

########--------------------------########

# Create API VMs
# Create Cloud init file for API VMs
api_cloudinit_file=/tmp/api_cloudinit.txt
cat <<EOF > $api_cloudinit_file
#!/bin/bash
apt update
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
apt install -y docker-ce
docker run --restart always -d -p 8080:8080 -e "SQL_SERVER_FQDN=$sql_server_fqdn" -e "SQL_SERVER_USERNAME=$sql_username" -e "SQL_SERVER_PASSWORD=$sql_password" --name api $api_image
EOF

# Create API Virtual Machines
echo "Create API Virtual Machines..."
for i in `seq 1 2`; do
az vm create -n vm-yada-api-swc0$i -g $rg -l $location --image "${publisher}:${offer}:${sku}:${version}" --generate-ssh-keys --size $vm_size \
--admin-username $adminuser --admin-password $pw \
--vnet-name $spoke_vnet_name --subnet $api_subnet_name --nsg "" --public-ip-address "" \
--zone=$i \
--custom-data $api_cloudinit_file -o none
done

########--------------------------########

# Create Web VMs
# Create Cloud init file for Web VMs
web_cloudinit_file=/tmp/web_cloudinit.txt
cat <<EOF > $web_cloudinit_file
#!/bin/bash
apt update
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
apt install -y docker-ce
docker run --restart always -d -p 80:80 -e "API_URL=http://${ilb_api}:8080" --name web $web_image
EOF

# Create Web Virtual Machines
echo "Create Web Virtual Machines..."
for i in `seq 1 2`; do
az vm create -n vm-yada-web-swc0$i -g $rg -l $location --image "${publisher}:${offer}:${sku}:${version}" --generate-ssh-keys --size $vm_size \
--admin-username $adminuser --admin-password $pw \
--vnet-name $spoke_vnet_name --subnet $web_subnet_name --nsg "" --public-ip-address "" \
--zone=$i \
--custom-data $web_cloudinit_file -o none
done
```



