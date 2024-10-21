# Secure Networking hackathon Deployment

## Prerequisites

### Permissions

To deploy this lab environment, you will need an Azure account that has at least [Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor) access to the subscription.

### Tools

For deploying the hackathon environment you will need the following:

- [Bicep Tools](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install) installed locally.
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed locally, or within [Azure Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview).
- We highly recommend using Azure Cloud Shell for this deployment.

## Deployment

> Note: This script will often take 30-45 minutes on average to execute. It assumes that you have already installed Bicep Tools and the Azure CLI, and that you are logged in to your Azure account. If you are using Azure Cloud Shell, you can skip the login step.

The Bicep file, which is located [here](/setup/OnPrem/cmconprem.bicep) will deploy a network topology in Azure which simulate an on-premises DC. It will create the following resources:
- 1. On-Premises Network
- 2. Management VM
- 3. Azure SQL Server with a Private Endpoint
- 4. On-Premises VPN Gateway

Using Azure CLI

1.  If you are NOT using Azure Cloud Shell, you need to sign in to Azure:

    ```sh
    az login
    ```

2.  Set Azure subscription:

    ```sh
    az account set --subscription "your-subscription-name"
    ```

3. Execute the script

    ```sh
    # Define variables
    rgname="rg-cmc-onprem"
    location="swedencentral"
    
    # Create Resource Group
    az group create --name $rgname --location $location

    # Create a random suffix
    suffix=$(head /dev/urandom | tr -dc a-z0-9 | head -c 5 ; echo '')

    # Deploy local Bicep file
    az deployment group create --name cmconprem$suffix \
    --resource-group $rgname \
    --template-file <path-to-cmconprem.bicep>

    # Deploy remote Bicep file
    # Currently this is not supported in Azure CLI.
    ```

### Provisioned Resources

The following are resources deployed as part of the deployment script (per team). This is a subset of the resources required during the hackathon.

Attendees will be deploying additional resources during the hackathon such as Azure Front Door, Azure Firewall, Azure VPN Gateway, Azure Application Gateway, Azure Virtual Machines, Azure SQL, Azure App Services, Azure Bastion, etc.

| Azure resource                | Pricing tier/SKU | Purpose                                          |
| ----------------------------- | ---------------- | ------------------------------------------------ |
| Azure Virtual Network         | n/a              | Network space for on premises                    |
| Azure Network Security Group  | n/a              | SQL subnet, and mgmt subnet NSG                  |
| Azure Public IP               | Standard         | On-premises VPN gateway public IP                |
| Azure Virtual Machine         | Standard D2S v3  | SQL Server VM                                    |
| Azure Virtual Machine         | Standard D2S v3  | Windows VM                                       |
| Azure Virtual Network Gateway | VPNGW1           | On-premises Gateway                              |
