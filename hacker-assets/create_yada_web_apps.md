# Bash script

```bash

# YADA - Web App version
# Set Variables
random_suffix=$RANDOM
rg=rgyada$random_suffix
location=eastus
sql_server_name=sqlsrv$randomsuffix
sql_db_name=mydb
sql_username=azure
sql_password=$(openssl rand -base64 10)  # 10-character random password
api_image='erjosito/yadaapi:1.0'
web_image='erjosito/yadaweb:1.0'

# Create Resource Group
echo "Creating resource group..."
az group create -n $rg -l $location -o none

# Create Azure SQL Server and database
echo "Creating Azure SQL..."
az sql server create -n $sql_server_name -g $rg -l $location --admin-user "$sql_username" --admin-password "$sql_password" -o none
az sql db create -n $sql_db_name -s $sql_server_name -g $rg -e Basic -c 5 --no-wait -o none
sql_server_fqdn=$(az sql server show -n $sql_server_name -g $rg -o tsv --query fullyQualifiedDomainName) && echo $sql_server_fqdn

# Run API on Web App
svcplan_name=webappplan
svcplan_sku=S1
app_name_api=api-$random_suffix
echo "Creating webapp for API..."
az appservice plan create -n $svcplan_name -g $rg --sku $svcplan_sku --is-linux -o none
az webapp create -n $app_name_api -g $rg -p $svcplan_name --deployment-container-image-name $api_image -o none
az webapp config appsettings set -n $app_name_api -g $rg --settings "WEBSITES_PORT=8080" "SQL_SERVER_USERNAME=$sql_username" "SQL_SERVER_PASSWORD=$sql_password" "SQL_SERVER_FQDN=${sql_server_fqdn}" -o none
az webapp restart -n $app_name_api -g $rg -o none
app_url_api=$(az webapp show -n $app_name_api -g $rg --query defaultHostName -o tsv) && echo $app_url_api

# Update Azure SQL Server IP firewall with ACI container IP
api_egress_ip=$(curl -s "https://${app_url_api}/api/ip" | jq -r .my_public_ip)
az sql server firewall-rule create -g "$rg" -s "$sql_server_name" -n public_api_aci-source --start-ip-address "$api_egress_ip" --end-ip-address "$api_egress_ip"

# Run on Web App
app_name_web=web-$random_suffix
echo "Creating webapp for frontend..."
az webapp create -n $app_name_web -g $rg -p $svcplan_name --deployment-container-image-name $web_image -o none
az webapp config appsettings set -n $app_name_web -g $rg --settings "API_URL=https://api-12632.azurewebsites.net" -o none
az webapp restart -n $app_name_web -g $rg -o none
app_url_web=$(az webapp show -n $app_name_web -g $rg --query defaultHostName -o tsv) && echo $app_url_web
