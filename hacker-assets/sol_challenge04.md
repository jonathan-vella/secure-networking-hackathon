# Secure Networking Artifacts
## Challenge 4: Design and implement web application security

You can use these commands to deploy an Azure Application Gateway in an existing virtual network (note that you need to update some of the variables):

```bash
######## Deploy Azure Application Gateway ########

########--------------------------########

# Variables for Azure environment
rg=your-resource-group-name
location=your-location

# Set Variables for Spoke Network
spoke_vnet_name=vnet-spoke-eus001
waf_subnet_name=WafSubnet

# Set Variables for Application Gateway
name=waf-yada-swc01
pip=pip-waf-yada-swc01

########--------------------------########

# Create Public IP for WAF
az network public-ip create -g $rg -n $pip --sku standard -l $location

# Create WAF Policy
az network application-gateway waf-policy create \
    --name YadaWafPolicy --resource-group $rg --location $location

# Deploy Azure Application Gateway with WAF v2
az network application-gateway create \
    --name $name \
    --resource-group $rg \
    --location $location \
    --vnet-name $spoke_vnet_name \
    --subnet $waf_subnet_name \
    --sku WAF_v2 \
    --public-ip-address $pip \
    --http-settings-cookie-based-affinity Disabled \
    --frontend-port 80 \
    --http-settings-port 80 \
    --http-settings-protocol Http \
    --routing-rule-type Basic \
    --priority 100 \
    --servers "10.30.1.10" \
    --waf-policy YadaWafPolicy \
    --capacity 3 \
    --zones 1,2,3 \
    --no-wait

########--------------------------#######