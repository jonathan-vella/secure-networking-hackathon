# Secure Networking hackathon Deployment

## Prerequisites

### Permissions

To deploy this lab environment, you will need an Azure account that has at least [Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor) access to the subscription.

### Tools

For deploying the hackathon environment you will need the following:

- [Azure PowerShell](https://learn.microsoft.com/powershell/azure/install-az-ps?view=azps-8.3.0) installed locally, or within[Azure Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed locally, or within [Azure Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview)
- If using a local installation, ensure you have the latest version
- We highly recommend using Azure Cloud Shell for this deployment to avoid any potential issues with local tooling.

## Deployment

> Note: This script will often take 30-45 minutes on average to execute. It assumes that you have already all tooling installed and that you are logged in to your Azure account. If you are using Azure Cloud Shell, you can skip the login step.

The ARM template, located [here](./OnPrem/cmc-arm.json) will deploy a network topology in Azure which simulate an on-premises DC. It will create the following resources:
- 1. On-Premises Network
- 2. Management VM
- 3. SQL Server VM
- 4. On-Premises VPN Gateway

If using PowerShell: 

1. Sign in to Azure:

    ```Powershell
    Connect-AzAccount
    ```
2. Deploy the script     

    ```Powershell    
    $RGname = 'rg-cmc-onprem'
    $location = 'swedencentral'

    New-AzResourceGroup -Name $RGname -Location $location

    New-AzResourceGroupDeployment -ResourceGroupName $RGname -TemplateFile cmc-arm.json
    ```
If using CLI

1. Sign in to Azure:

```sh
az login
```

2. Deploy the script 

```sh
 $RGname = 'rg-cmc-onprem'
 $location = 'swedencentral'

az group create --name $RGname --location $location
az deployment group create --resource-group $RGname --template-file cmc-arm.json            
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
