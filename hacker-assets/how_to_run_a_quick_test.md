# Secure Networking Artifacts

You can use this example to deploy the demo app to a new resource group to verify functionality (note the following example follows Linux bash functionality):

```bash
# Variables
rg=rg$RANDOM
location=eastus
vnet_name=myvnet
vnet_prefix=172.16.0.0/24
api_subnet_name=api
api_subnet_prefix=172.16.0.0/26
api_nsg_name=api
web_subnet_name=web
web_subnet_prefix=172.16.0.64/26
web_nsg_name=web
sql_server_name=sqlserver$RANDOM
sql_db_name=mydb
sql_username=demouser
sql_password='demo!pass123'
web_template_uri='https://raw.githubusercontent.com/jonathan-vella/secure-networking-hackathon/hacker-assets/main/deploy_web_to_vm.json'
api_template_uri='https://raw.githubusercontent.com/jonathan-vella/secure-networking-hackathon/hacker-assets/main/deploy_api_to_vm.json'

# Create Resource Group and VNet
echo "Creating RG and VNet..."
az group create -n $rg -l $location -o none
az network vnet create -n $vnet_name -g $rg --address-prefixes $vnet_prefix --subnet-name $web_subnet_name --subnet-prefixes $web_subnet_prefix -o none
az network vnet subnet create --vnet-name $vnet_name --name $api_subnet_name -g $rg --address-prefixes $api_subnet_prefix -o none

# Create NSG and assign it to the web subnet
echo "Creating NSG..."
az network nsg create -n "$web_nsg_name" -g $rg -l $location -o none
az network nsg rule create -n WEBin --nsg-name "$web_nsg_name" -g $rg --priority 1000 --destination-port-ranges 80 --access Allow --protocol Tcp -o none
az network nsg rule create -n SNMPin --nsg-name "$web_nsg_name" -g $rg --priority 1010 --destination-port-ranges 161 --access Allow --protocol Udp -o none
az network nsg rule create -n SSHin --nsg-name "$web_nsg_name" -g $rg --priority 1020 --destination-port-ranges 22 --access Allow --protocol Tcp -o none
az network nsg create -n "$api_nsg_name" -g $rg -l $location -o none
az network vnet subnet update -n $web_subnet_name --vnet-name $vnet_name -g $rg --network-security-group $web_nsg_name -o none
az network vnet subnet update -n $api_subnet_name --vnet-name $vnet_name -g $rg --network-security-group $api_nsg_name -o none

# Create Azure SQL Server
echo "Creating Azure SQL server and database..."
az sql server create -n $sql_server_name -g $rg -l $location --admin-user "$sql_username" --admin-password "$sql_password" -o none
az sql db create -n $sql_db_name -s $sql_server_name -g $rg -e Basic -c 5 --no-wait -o none
sql_server_fqdn=$(az sql server show -n $sql_server_name -g $rg -o tsv --query fullyQualifiedDomainName) && echo "Azure SQL Server FQDN is $sql_server_fqdn"

# Create VM for API tier
echo "Creating API VM..."
az deployment group create -n app$RANDOM -g $rg --template-uri $api_template_uri --parameters vmName=api virtualNetworkName=$vnet_name sqlServerFQDN=$sql_server_fqdn sqlServerUser=$sql_username "sqlServerPassword=$sql_password" subnetName=$api_subnet_name availabilityZone=1 -o none
api_nic_id=$(az vm show -n api -g "$rg" --query 'networkProfile.networkInterfaces[0].id' -o tsv)
api_private_ip=$(az network nic show --ids $api_nic_id --query 'ipConfigurations[0].privateIpAddress' -o tsv) && echo "API VM private IP is $api_private_ip"

# Create VM for web tier with cyan background and WTH branding. Other colors you can use: #92cb96 (green), #fcba87 (orange), #fdfbc0 (yellow)
echo "Creating web VM..."
az deployment group create -n web$RANDOM -g $rg --template-uri $web_template_uri --parameters vmName=web virtualNetworkName=$vnet_name "apiUrl=http://${api_private_ip}:8080" subnetName=$web_subnet_name availabilityZone=1 -o none
web_nic_id=$(az vm show -n web -g "$rg" --query 'networkProfile.networkInterfaces[0].id' -o tsv)
web_nic_name=$(echo $web_nic_id | cut -d/ -f 9)
web_ipconfig_name=$(az network nic show --ids $web_nic_id --query 'ipConfigurations[0].name' -o tsv)

# Create public IP and assign it to the web VM
echo "Assigning public IP to web VM..."
az network public-ip create -g $rg --sku Standard -n web-pip -o none
az network nic ip-config update -n $web_ipconfig_name --nic-name $web_nic_name -g $rg --public-ip-address web-pip -o none

# Finish
web_pip_address=$(az network public-ip show -n web-pip -g $rg --query ipAddress -o tsv)
echo "You can point your browser to http://${web_pip_address}"
```
