# Secure Networking hackathon Deployment

## Prerequisites

### Permissions

To deploy this lab environment, you will need an Azure account that has at least [Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor) access to the subscription.

### Tools

For deploying the hackathon environment you will need one of the following:

- [Azure PowerShell](https://learn.microsoft.com/powershell/azure/install-az-ps?view=azps-8.3.0) installed locally, or within[Azure Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed locally, or within [Azure Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview)
- If using a local installation, ensure you have the latest version

## Deployment

> Note: This script will often take 30-45 minutes on average to execute. Files are located in the [OnPrem](./OnPrem) folder

If using PowerShell:

1.  Sign in to Azure:

    ```Powershell
    Connect-AzAccount
    ```

2.  Set Azure subscription:

    ```Powershell
    Set-AzContext -SubscriptionName "your-subscription-name"
    ```
    
3.  Deploy the script

        ```Powershell
        $RGname = 'cmc-on-prem'
        $location = 'northeurope'
        $templateuri = 'https://raw.githubusercontent.com/jonathan-vella/secure-networking-hackathon/main/setup/OnPrem/onpremdeploy.json'

        New-AzResourceGroup -Name $RGname -Location $location

        New-AzResourceGroupDeployment -ResourceGroupName $RGname -TemplateFile $templateuri
        ```

    If using CLI

1.  Sign in to Azure:

```sh
az login
```

2.  Set Azure subscription:

```sh
az account set --subscription "your-subscription-name"
```

3. Deploy the script

```sh
 $RGname = 'cmc-on-prem'
 $location = 'northeurope'
 $templateuri = 'https://raw.githubusercontent.com/jonathan-vella/secure-networking-hackathon/main/setup/OnPrem/onpremdeploy.json'

az group create --name $RGname --location $location
az deployment group create --resource-group $RGname --template-uri $templateuri
```

## Provisioned Resources

The following are resources are deployed as part of the deployment script (per team). This is a subset of the resources required during the hackathon. Attendees will be deploying additional resources during the hackathon such as Azure Front Door, Azure Firewall, Azure VPN Gateway, Azure Application Gateway, Azure Virtual Machines, Azure SQL, etc.

| Azure resource                | Pricing tier/SKU | Purpose                                          |
| ----------------------------- | ---------------- | ------------------------------------------------ |
| Azure Virtual Network         | n/a              | Network space for on premises                    |
| Azure Bastion                 | Basic            | Securely connect to Azure VMs                    |
| Azure Local network gateway   | n/a              | Represents CMC's Azure network address space     |
| Azure Network Security Group  | n/a              | Bastion subnet, data subnet, and mgmt subnet NSG |
| Azure Public IP               | Standard         | Bastion Public IP                                |
| Azure Public IP               | Basic            | on-prem VPN gateway public IP                    |
| Azure Virtual Machine         | Standard D2S v3  | SQL VM                                           |
| Azure Virtual Machine         | Standard D2S v3  | Windows VM                                       |
| Azure Virtual Network Gateway | Basic            | On-prem Gateway                                  |
