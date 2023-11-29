# Bash script

```bash

# Create a Hub & Spoke network topology and a workload in the spoke network
# Set variables for Azure environment
rg="insert resource group name"
location="insert region value"

# Create resource group
az group create -n $rg -l $location

######## Deploy Hub Network and supporting resources ########
# Set Variables for Hub Network
hub_vnet_name=vnet-hub-eus001
hub_vnet_prefix=10.20.0.0/22
gw_subnet_name=GatewaySubnet
gw_subnet_prefix=10.20.0.0/24
azfw_subnet_name=AzureFirewallSubnet
azfw_subnet_prefix=10.20.1.0/24
bst_subnet_name=AzureBastionSubnet
bst_subnet_prefix=10.20.2.0/24

# Create Network Security Group for the Azure Bastion subnet
az network nsg create -n bastion-nsg -g $rg -l $location

# Create hub virtual network
az network vnet create -g $rg -n $hub_vnet_name --address-prefix $hub_vnet_prefix -l $location
az network vnet subnet create -g $rg -n $gw_subnet_name --vnet-name $hub_vnet_name --address-prefix $gw_subnet_prefix
az network vnet subnet create -g $rg -n $azfw_subnet_name --vnet-name $hub_vnet_name --address-prefix $azfw_subnet_prefix
az network vnet subnet create -g $rg -n $bst_subnet_name --vnet-name $hub_vnet_name --address-prefix $bst_subnet_prefix --network-security-group bastion-nsg

# Create Azure Bastion
az network public-ip create -g $rg -n bst-pip --sku standard -l $location
az network bastion create -n bastion -g $rg -l $location --public-ip-address bst-pip --vnet-name $hub_vnet_name --sku standard --no-wait
# Note. The --no-wait parameter allows Bastion to be created in the background. It does not mean that Bastion is created immediately. Bastion deployment can take 20 minutes or more. 

# Create Azure Firewall
az network firewall policy create -n azfwpolicy -g $rg --sku Premium
az network public-ip create -g $rg -n azfw-pip --sku standard --allocation-method static -l $location
azfw_ip=$(az network public-ip show -g $rg -n azfw-pip --query ipAddress -o tsv)
az network firewall create -n azfw -g $rg -l $location --tier Premium --threat-intel-mode Deny
azfw_id=$(az network firewall show -n azfw -g $rg -o tsv --query id)
az network firewall ip-config create -f azfw -n azfw-ipconfig -g $rg --public-ip-address azfw-pip --vnet-name $hub_vnet_name
az network firewall update -n azfw -g $rg
azfw_private_ip=$(az network firewall show -n azfw -g $rg --query 'ipConfigurations[0].privateIpAddress' -o tsv) # this command may take a few minutes to return the private IP address, and it could fail if the firewall is still being provisioned. If that happens, just run the command again or if you did not change your network space use 10.20.1.4

# Create and Assign Azure Firewall Policy (This is a Test rule to allow everything)
az network firewall policy rule-collection-group create -n TestRules --policy-name azfwpolicy -g $rg --priority 100
az network firewall policy rule-collection-group collection add-filter-collection --policy-name azfwpolicy --rule-collection-group-name TestRules -g $rg \
--name NetworkTraffic --collection-priority 150 --action Allow --rule-name permitAny --rule-type NetworkRule --description "Permit all traffic - TEST" \
--destination-addresses '*' --destination-ports '*' --source-addresses '*' --ip-protocols Tcp Udp Icmp                    

# Create VPN Gateway (you might want to take a break - est. provisioning time is 30-40mins)
# Set variables for VPN Gateway
gw_name=vpn-hub-eus001
gw_pip_name=pip-vpn-hub-eus001

# Create Public IP for VPN Gateway
az network public-ip create -n $gw_pip_name -g $rg --allocation-method Static

# Create VPN Gateway
az network vnet-gateway create -n $gw_name -l $location --public-ip-address $gw_pip_name -g $rg --vnet $hub_vnet_name --gateway-type Vpn --sku VpnGw1 --vpn-type RouteBased --no-wait
# Note. The --no-wait parameter allows the gateway to be created in the background. It does not mean that the VPN gateway is created immediately. A VPN gateway can take 45 minutes or more to create. 
# You can't modify the Vnet whilst the gateway is being created. You can check the status of the gateway with the following command: az network vnet-gateway list -g $rg -o table


######## Deploy Spoke Network ########
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

# Create Network Security Groups for Spoke subnets
az network nsg create -n waf-nsg -g $rg -l $location
az network nsg create -n web-nsg -g $rg -l $location
az network nsg create -n api-nsg -g $rg -l $location
az network nsg create -n db-nsg -g $rg -l $location

# Create spoke virtual network
az network vnet create -g $rg -n $spoke_vnet_name --address-prefix $spoke_vnet_prefix -l $location
az network vnet subnet create -g $rg -n $waf_subnet_name --vnet-name $spoke_vnet_name --address-prefix $waf_subnet_prefix --network-security-group waf-nsg
az network vnet subnet create -g $rg -n $web_subnet_name --vnet-name $spoke_vnet_name --address-prefix $web_subnet_prefix --network-security-group web-nsg
az network vnet subnet create -g $rg -n $api_subnet_name --vnet-name $spoke_vnet_name --address-prefix $api_subnet_prefix --network-security-group api-nsg
az network vnet subnet create -g $rg -n $db_subnet_name --vnet-name $spoke_vnet_name --address-prefix $db_subnet_prefix --network-security-group db-nsg

######## Connect Hub and Spoke Networks Peerings ########
# Peer Hub <-> Spoke networks
# Get the id for the hub network
hubvnetId=$(az network vnet show \
--resource-group $rg \
--name $hub_vnet_name \
--query id --out tsv)

# Get the id for the spoke network
spokevnetId=$(az network vnet show \
--resource-group $rg \
--name $spoke_vnet_name \
--query id \
--out tsv)

# Create Peering from Hub to Spoke
az network vnet peering create \
--name hub2spoke \
--resource-group $rg \
--vnet-name $hub_vnet_name \
--remote-vnet $spokevnetId \
--allow-vnet-access \
--allow-gateway-transit # This assumes that the gateway has been provisioned already

# Create Peering from Spoke to Hub
az network vnet peering create \
--name spoke2hub \
--resource-group $rg \
--vnet-name $spoke_vnet_name \
--remote-vnet $hubvnetId \
--allow-vnet-access \
--use-remote-gateways # This assumes that the gateway has been provisioned already

######## Create Route Tables ########
# Create Route table for workload subnets
az network route-table create -n udr-wload -g $rg -l $location --disable-bgp-route-propagation
az network route-table route create -n wload2any --route-table-name udr-wload -g $rg \
--next-hop-type VirtualAppliance --address-prefix "0.0.0.0/0" --next-hop-ip-address $azfw_private_ip

# Associate Route Table to Web and API Subnets. Make sure to create the VNET peerings first.
wload_rt_id=$(az network route-table show -n udr-wload -g $rg -o tsv --query id)
az network vnet subnet update -g $rg --vnet-name $spoke_vnet_name -n $web_subnet_name --route-table $wload_rt_id
az network vnet subnet update -g $rg --vnet-name $spoke_vnet_name -n $api_subnet_name --route-table $wload_rt_id

# Create Route table for Gateway Subnet
az network route-table create -n udr-gwsubnet -g $rg -l $location
az network route-table route create -n onprem2spoke --route-table-name udr-gwsubnet -g $rg \
--next-hop-type VirtualAppliance --address-prefix $spoke_vnet_prefix --next-hop-ip-address $azfw_private_ip

# Associate Route Table to Gateway Subnet. Make sure to create the VNET peerings first.
gw_rt_id=$(az network route-table show -n udr-gwsubnet -g $rg -o tsv --query id)
az network vnet subnet update -g $rg --vnet-name $hub_vnet_name -n $gw_subnet_name --route-table $gw_rt_id


######## Deploy YADA IaaS-based workload ########
# Update NSG Rules for YADA
echo "Updating NSGs Rules..."
az network nsg rule create -n YADAwebin --nsg-name "web-nsg" -g $rg --priority 1000 --destination-port-ranges 80 --access Allow --protocol Tcp -o none
az network nsg rule create -n YADAapiin --nsg-name "api-nsg" -g $rg --priority 1010 --destination-port-ranges 8080 --access Allow --protocol Tcp -o none
az network nsg rule create -n YADAsshin --nsg-name "api-nsg" -g $rg --priority 1020 --destination-port-ranges 22 --access Allow --protocol Tcp -o none
az network vnet subnet update -n $web_subnet_name --vnet-name $spoke_vnet_name -g $rg --network-security-group web-nsg -o none
az network vnet subnet update -n $api_subnet_name --vnet-name $spoke_vnet_name -g $rg --network-security-group api-nsg -o none

# Create Azure SQL Server and database
# Variables for SQL Server
sql_server_name=sqlsrv-yada-eus001
sql_db_name=mydb
sql_username=azure
sql_password=$(openssl rand -base64 10)  # 10-character random password
echo "Creating Azure SQL..."
az sql server create -n $sql_server_name -g $rg -l $location --admin-user "$sql_username" --admin-password "$sql_password" -o none
az sql db create -n $sql_db_name -s $sql_server_name -g $rg -e Basic -c 5 --no-wait -o none
sql_server_fqdn=$(az sql server show -n $sql_server_name -g $rg -o tsv --query fullyQualifiedDomainName) && echo $sql_server_fqdn

# Update Azure SQL Server IP firewall with Azure Firewall Public IP
echo "Adding public IP $api_public_ip to Azure SQL firewall rules..."
azfw_ip=$(az network public-ip show -g $rg -n azfw-pip --query ipAddress -o tsv)
az sql server firewall-rule create -g "$rg" -s "$sql_server_name" -n public_api_aci-source --start-ip-address "$azfw_ip" --end-ip-address "$azfw_ip" -o none

# Deploy Virtual Machines for YADA
# Variables for IaaS-based workload
offer="0001-com-ubuntu-server-focal"
publisher="Canonical"
sku="20_04-lts-gen2"
version=latest
vm_size=Standard_D2s_v3 # Depending on your scenario you may want to use a different VM size
ilb_api=10.30.2.10 # This is the private IP address of the Internal Load Balancer for the API tier
api_image='erjosito/yadaapi:1.0'
web_image='erjosito/yadaweb:1.0'

# Accept image terms
echo "Accepting image terms for $publisher:$offer:$sku..."
az vm image terms accept -p $publisher -f $offer --plan $sku

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

# Finish
echo "You can now browse to http://$azfw_ip" (if you have create a DNAT rule!)


# Next steps - Loop VM priovisioning, Add Standard Load Balancer for both tiers, Add DNAT Rule, WAF deployment, AFD
