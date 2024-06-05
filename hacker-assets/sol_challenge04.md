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

########--------------------------########

# Deploy Azure Application Gateway with WAF v2
az network application-gateway create \
    --name appgateway \
    --resource-group $rg \
    --location $location \
    --vnet-name $spoke_vnet_name \
    --subnet $waf_subnet_name \
    --sku WAF_v2 \
    --http-settings-cookie-based-affinity Disabled \
    --frontend-port 80 \
    --http-settings-port 80 \
    --http-settings-protocol Http \
    --routing-rule-type Basic \
    --servers "10.30.1.10" \
    --capacity 2

########--------------------------#######