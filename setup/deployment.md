# Secure Networking hackathon Deployment

## Prerequisites

### Permissions

To deploy this lab environment, you will need an Azure account that has at least [Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor) access to the subscription.

### Tools

For deploying the hackathon environment you will need the following:

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed locally, or within [Azure Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview)
- If using a local installation, ensure you have the latest version

## Deployment

> Note: This script will often take 30-45 minutes on average to execute. It assumes that you have already installed the Azure CLI and are logged in to your Azure account. If you are using Azure Cloud Shell, you can skip the login step. If you have not installed the Azure CLI, you can find the instructions here: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

This script will deploy a network topology in Azure which simulate an on-premises DC. It will create the following resources:
- 1. On-Premises Network
- 2. Management VM
- 3. Azure SQL Server with a Private Endpoint
- 4. On-Premises VPN Gateway

Using Azure CLI

1.  Sign in to Azure:

    ```sh
    az login
    ```

2.  Set Azure subscription:

    ```sh
    az account set --subscription "your-subscription-name"
    ```

3. Execute the script

    ```sh
    # Set variables for Azure environment. You can change the values of these variables to suit your environment.

    # Define the Azure location where you want to deploy the resources
    location=eastus2

    # Define the name of the resource groups
    rg=cmc-on-prem

    # Create resource groups
    az group create -n $rg -l $location

    ######## Deploy On-Premises Network ########
    # Set Variables for On-Premises Network
    vnet_name=network-cmc-onprem
    vnet_prefix=10.0.0.0/16
    mgmt_subnet_name=MgmtSubnet
    mgmt_subnet_prefix=10.0.1.0/24
    sql_subnet_name=SqlSubnet
    sql_subnet_prefix=10.0.2.0/24
    gw_subnet_name=GatewaySubnet
    gw_subnet_prefix=10.0.0.0/24

    # Create Network Security Groups for VM subnets
    az network nsg create -n sql-nsg -g $rg -l $location
    az network nsg create -n mgmt-nsg -g $rg -l $location

    # Create On-Premises virtual network
    az network vnet create -g $rg -n $vnet_name --address-prefix $vnet_prefix -l $location
    az network vnet subnet create -g $rg -n $gw_subnet_name --vnet-name $vnet_name --address-prefix $gw_subnet_prefix
    az network vnet subnet create -g $rg -n $mgmt_subnet_name --vnet-name $vnet_name --address-prefix $mgmt_subnet_prefix --network-security-group mgmt-nsg
    az network vnet subnet create -g $rg -n $sql_subnet_name --vnet-name $vnet_name --address-prefix $sql_subnet_prefix --network-security-group sql-nsg

    ######## Update NSG Rules for VM Subnets ########
    # Update NSG Rules for VM Subnets
    echo "Updating NSGs Rules..."
    az network nsg rule create -n AdminIn --nsg-name "mgmt-nsg" -g $rg --priority 1000 --destination-port-ranges 22 3389 --access Allow --protocol Tcp -o none
    az network nsg rule create -n AdminIn --nsg-name "sql-nsg" -g $rg --priority 1000 --destination-port-ranges 22 3389 --access Allow --protocol Tcp -o none
    az network nsg rule create -n SqlIn --nsg-name "sql-nsg" -g $rg --priority 1010 --destination-port-ranges 1433 --access Allow --protocol Tcp -o none
    az network vnet subnet update -n $mgmt_subnet_name --vnet-name $vnet_name -g $rg --network-security-group mgmt-nsg -o none
    az network vnet subnet update -n $sql_subnet_name --vnet-name $vnet_name -g $rg --network-security-group sql-nsg -o none

    ######## Deploy Management Virtual Machine ########

    # Variables for IaaS-based workload
    vm_size=Standard_D2s_v3 # Depending on your scenario you may want to use a different VM size

    # Credentials for IaaS-based workload
    adminuser='demouser'
    pw='demo!pass123'

    # Create Mgmt Virtual Machine
    echo "Create Mgmt Virtual Machine..."
    for i in `seq 1`; do
    az vm create -n vm-mgmt-0$i -g $rg -l $location --image Win2022Datacenter --size $vm_size \
    --admin-username $adminuser --admin-password $pw \
    --vnet-name $vnet_name --subnet $mgmt_subnet_name --nsg "" --public-ip-address "" \
    --zone=$i
    done

    ########--------------------------########

    # Create an Azure SQL Server with a Private Endpoint to simulate an on-premises SQL Server

    # Create a random suffix
    suffix=$(head /dev/urandom | tr -dc a-z0-9 | head -c 5 ; echo '')

    # Define variables for Azure SQL Server
    sql_server_name=sqlsrv$suffix
    sql_admin_username="sqladmin"
    sql_admin_password='demo!pass123'
    sql_database_name="mydb"

    # Create Azure SQL Server
    az sql server create \
    --name $sql_server_name \
    --resource-group $rg \
    --location $location \
    --admin-user $sql_admin_username \
    --admin-password $sql_admin_password

    # Create a database in the server with the S0 tier
    az sql db create \
    --resource-group $rg \
    --server $sql_server_name \
    --name $sql_database_name \
    --service-objective S0

    id=$(az sql server list \
        --resource-group $rg \
        --query '[].[id]' \
        --output tsv)

    az network private-endpoint create \
        --name sql-onprem-pre \
        --resource-group $rg \
        --vnet-name $vnet_name --subnet $sql_subnet_name \
        --private-connection-resource-id $id \
        --group-ids sqlServer \
        --connection-name sql-Connection

    ########--------------------------########

    ######## Deploy on-premises VPN Gateway ########

    # Create VPN Gateway - you might want to take a break after this part - est. provisioning time is 30-40mins.
    # Set variables for VPN Gateway
    gw_name=vpn-on-prem
    gw_pip_name=pip-vpn-on-prem

    # Create Public IP for VPN Gateway
    az network public-ip create -n $gw_pip_name -g $rg --allocation-method Static

    # Create VPN Gateway
    az network vnet-gateway create -n $gw_name -l $location --public-ip-address $gw_pip_name -g $rg --vnet $vnet_name --gateway-type Vpn --sku VpnGw1 --vpn-type RouteBased --no-wait
    watch ls

    # Note. The --no-wait parameter allows the gateway to be created in the background.
    # It does not mean that the VPN gateway is created immediately. A VPN gateway can take 45 minutes or more to create. 
    # You cannot modify the Vnet whilst the gateway is being created.
    # You can check the status of the gateway with the following command: az network vnet-gateway list -g $rg -o table
```

## Provisioned Resources

The following are resources deployed as part of the deployment script (per team). This is a subset of the resources required during the hackathon.

Attendees will be deploying additional resources during the hackathon such as Azure Front Door, Azure Firewall, Azure VPN Gateway, Azure Application Gateway, Azure Virtual Machines, Azure SQL, Azure App Services, Azure Bastion, etc.

| Azure resource                | Pricing tier/SKU | Purpose                                          |
| ----------------------------- | ---------------- | ------------------------------------------------ |
| Azure Virtual Network         | n/a              | Network space for on premises                    |
| Azure Network Security Group  | n/a              | SQL subnet, and mgmt subnet NSG                  |
| Azure Public IP               | Standard         | On-premises VPN gateway public IP                |
| Azure SQL                     | S0               | Azure SQL Server & Database                      |
| Azure Virtual Machine         | Standard D2S v3  | Windows VM                                       |
| Azure Virtual Network Gateway | VPNGW1           | On-premises Gateway                              |
