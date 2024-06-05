# Secure Networking Artifacts
## Challenge 5: CMC goes global

You can use these commands to deploy Azure Front Door in an existing resource group (note that you need to update some of the variables):

```bash
######## Deploy Azure Front Door ########

########--------------------------########

# Variables for Azure environment
rg=your-resource-group-name
location=your-location

# Variables for Azure Front Door
AfdWafPolicy=AfdWafPolicy
name=afd-yada-eus01
backend_address=yada.azurewebsites.net
frontend_host_name=yada.azurefd.net

########--------------------------########

az network front-door waf-policy create \
    --name $AfdWafPolicy --resource-group $rg --location $location

# Deploy Azure Front Door
az network front-door create \
    --name $name \
    --resource-group $rg \
    --location $location \
    --forwarding-protocol HttpsOnly \
    --backend-address $backend_address \
    --frontend-host-name $frontend_host_name \
    --routing-rule-type Forward \
    --session-affinity Enabled \
    --ttl 30 \
    --no-wait

########--------------------------#######



AfdWafPolicy=AfdWafPolicy
name=afd-yada-eus01
backend_address=yada.azurewebsites.net
frontend_host=yada.azurefd.net
frontend_host_header=yada.azurefd.net
```