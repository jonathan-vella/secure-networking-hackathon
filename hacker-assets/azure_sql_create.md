# Bash script

```bash

# Create Azure SQL Server and database

# Create a random suffix
suffix=$(head /dev/urandom | tr -dc a-z0-9 | head -c 5 ; echo '')

# Set Variables for Resource Group 
rg='your_resource_group'
location='your_azure_region'

# Set Variables for SQL Server
sql_server_name=sqlsrv$suffix
sql_db_name=mydb
sql_username=azure
sql_password=$(openssl rand -base64 10)  # 10-character random password

# Create Azure SQL
echo "Creating Azure SQL..."
az sql server create -n $sql_server_name -g $rg -l $location --admin-user "$sql_username" --admin-password "$sql_password" -o none
az sql db create -n $sql_db_name -s $sql_server_name -g $rg -e Basic -c 5 --no-wait -o none

# Get Azure SQL FQDN
sql_server_fqdn=$(az sql server show -n $sql_server_name -g $rg -o tsv --query fullyQualifiedDomainName) && echo $sql_server_fqdn

# Update Azure SQL Server IP firewall with Azure Firewall Public IP
echo "Adding public IP $api_public_ip to Azure SQL firewall rules..."
azfw_ip=your_azure_firewall_public_ip # This is the public IP address used by the YADA VMs for outbound internet access
az sql server firewall-rule create -g "$rg" -s "$sql_server_name" -n public_api_vm-source --start-ip-address "$azfw_ip" --end-ip-address "$azfw_ip" -o none

