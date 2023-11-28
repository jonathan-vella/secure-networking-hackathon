# Secure Networking hackathon Artifacts

You can find in this repository assets required for the Secure Networking hackathon to deploy the application required (you can find the source code for the application [here](https://github.com/Microsoft/YADA)).

## hackathon Network Diagnostics (YADA) application

The Secure Networking hackathon uses the Network Diagnostics application (aka YADA) throughout all of the exercises. The application's tier components can be deployed via ARM templates to Azure virtual machines.

For the application tier, the template needs the following parameters:

- VNet and subnet name
- SQL FQDN and credentials
- Optionally an Availability Zone

Here is an example of how to deploy SQL and the application tier to an Azure Virtual machine:

# Bash script

# Resource Group Variables
rg='your_resource_group'
location='your_azure_region'

# SQL Server Variables (if you want to create Azure SQL instead of using the on-premises SQL deployment)
sql_server_name=sqlserver$random_suffix
sql_db_name=mydb
sql_username=azure
sql_username='your_sql_server_username'
sql_password='your_sql_server_password'

# Create Azure SQL Server and database
echo "Creating Azure SQL..."
az sql server create -n $sql_server_name -g $rg -l $location --admin-user "$sql_username" --admin-password "$sql_password" -o none
az sql db create -n $sql_db_name -s $sql_server_name -g $rg -e Basic -c 5 --no-wait -o none
sql_server_fqdn=$(az sql server show -n $sql_server_name -g $rg -o tsv --query fullyQualifiedDomainName) && echo $sql_server_fqdn

# API Tier Variables
vnet_name='your_vnet_name'
api_subnet_name='your_app_subnet'
vm_username='demouser'
vm_password='your_vm_password'
sql_server_fqdn='fully_qualified_domain_name_of_a_SQL_server'
api_template_uri='https://raw.githubusercontent.com/jonathan-vella/secure-networking-hackathon/main/hacker-assets/deploy_api_to_vm.json'

# Create VM for API tier
echo "Creating API VM..."
az deployment group create -n appvm -g $rg --template-uri $api_template_uri \
    --parameters vmName=api \
                 adminUsername=$vm_username \
                 adminPassword=$vm_password \
                 virtualNetworkName=$vnet_name \
                 sqlServerFQDN=$sql_server_fqdn \
                 sqlServerUser=$sql_username \
                 "sqlServerPassword=$sql_password" \
                 subnetName=$api_subnet_name \
                 availabilityZone=1
                 
# Create VM for API tier
echo "Creating API VM..."
az deployment group create -n appvm -g $rg --template-uri $api_template_uri \
    --parameters vmName=api \
                 adminUsername=$vm_username \
                 adminPassword=$vm_password \
                 virtualNetworkName=$vnet_name \
                 sqlServerFQDN=$sql_server_fqdn \
                 sqlServerUser=$sql_username \
                 "sqlServerPassword=$sql_password" \
                 subnetName=$api_subnet_name \
                 availabilityZone=1
```

Similarly, for the web tier you will need to provide the following parameters:

- VNet and subnet name
- URL to access the API
- Optionally an Availability Zone

Here an example of how to deploy the web tier to an Azure Virtual Machine:

```bash
# Variables
rg='your_resource_group'
location='your_azure_region'
vnet_name='your_vnet_name'
web_subnet_name='your_web_subnet'
vm_username='demouser'
vm_password='your_vm_password'
api_ip_address='1.2.3.4'
web_template_uri='https://raw.githubusercontent.com/jonathan-vella/secure-networking-hackathon/main/hacker-assets/deploy_web_to_vm.json'

# Create VM for web tier
echo "Creating web VM..."
az deployment group create -n webvm -g $rg --template-uri $web_template_uri \
    --parameters vmName=web \
                 adminUsername=$vm_username \
                 adminPassword=$vm_password \
                 virtualNetworkName=$vnet_name \
                 "apiUrl=http://${api_ip_address}:8080" \
                 subnetName=$web_subnet_name \
                 availabilityZone=1
```

## Testing

After deploying both the API and web VMs, you can access the application:

- The full application is available on the IP address of the web VM (TCP port 80)
- You can individually access the API on the IP address of the API VM (TCP port 8080)
- The web VM is deployed with an SNMP daemon, you can access it on UDP port 161. For example, from Linux:
  - `snmpget -v2c -c public <ip_address_of_web_vm> 1.3.6.1.2.1.1.1.0`

## Troubleshooting

- Make sure that the VM has Internet connectivity, otherwise it will not be able to download the container images.
- You can SSH into the deployed VM and check that the container apps are running, with the command `sudo docker ps`. You should have at least a container named `web` running, and possibly another one called `snmp` (only if you set the ARM parameter `deploySNMPContainer` to `no` you wouldn't have it).
- The default settings deploy a VM from the marketplace, that you need to accept first. If you don't have enough permissions to accept Marketplace offers, you can try the `ubuntu` VM (with the ARM parameter `vmType`, see below).
- If a given VM type such as `flatcar` has issues, try a different OS such as `ubuntu`.
- If the application doesn't get correctly deployed, you can log into the Virtual Machine (via SSH, Azure Bastion or Azure Serial Console), and investigate the cloudinit logs of the Virtual Machine. You can usually find cloudinit logs for Ubuntu VMs in the `/var/log/cloud-init-output.log` file.
- Remember that you deployed a B-series VM. This might impact the behaviour of the application.

## Other options

The ARM template supports some additional parameters for deployment:

- `vmType`: can be either `kinvolk` (default) or `ubuntu`. It is the OS of the VM where the application will be deployed. It can be verified via SNMP.
- `backgroundColor` (web only): background color for the web app, defaults to `#d3d3d3`.
- `headerName`, `headerValue` (web only): If specified, the app will make sure that this HTTP header (name and value) is present in the request.
- `deploySNMPContainer` (web only): can be either `yes` (default) or `no`. Whether an SNMP container will be deployed along the web application.
