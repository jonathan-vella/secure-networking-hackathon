# Secure Networking Artifacts

You can use these commands to deploy the YADA app to an existing resource group (note that you need to update some of the variables):

```bash
# Variables
######## Deploy YADA ########

########--------------------------########

# Variables for Azure environment
rg=your-resource-group-name
location=your-location

# Set Variables for Spoke Network
spoke_vnet_name=vnet-spoke-eus001
spoke_vnet_prefix=10.30.0.0/21
waf_subnet_name=WafSubnet
waf_subnet_prefix=10.30.0.0/24
web_subnet_name=WebSubnet
web_subnet_prefix=10.30.1.0/24
api_subnet_name=ApiSubnet
api_subnet_prefix=10.30.2.0/24
db_subnet_name=DbSubnet
db_subnet_prefix=10.30.3.0/24

# Variables for SQL Server
sql_server_name=server-ip-address
sql_db_name=mydb
sql_username=azure
sql_password=WhoNeedsPasswords

# Variables for IaaS-based workload
offer="0001-com-ubuntu-server-focal"
publisher="Canonical"
sku="20_04-lts-gen2"
version=latest
vm_size=Standard_D2s_v3 # Depending on your scenario you may want to use a different VM size
ilb_api=10.30.2.10 # Update this with the private IP address of the Internal Load Balancer for the API tier
api_image='erjosito/yadaapi:1.0'
web_image='erjosito/yadaweb:1.0'

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
az vm create -n vm-yada-apib$i -g $rg -l $location --image "${publisher}:${offer}:${sku}:${version}" --generate-ssh-keys --size $vm_size \
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
az vm create -n vm-yada-web$i -g $rg -l $location --image "${publisher}:${offer}:${sku}:${version}" --generate-ssh-keys --size $vm_size \
--vnet-name $spoke_vnet_name --subnet $web_subnet_name --nsg "" --public-ip-address "" \
--zone=$i \
--custom-data $web_cloudinit_file -o none
done
