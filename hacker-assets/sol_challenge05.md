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
backend_address=your-backend-address
frontend_host=your-frontend-host
frontend_host_header=your-frontend-host-header

########--------------------------########
# Deploy Azure Front Door
az network front-door create \
    --name cmc-frontdoor \
    --resource-group $rg \
    --location $location \
    --backend-address $backend_address \
    --frontend-host $frontend_host \
    --frontend-host-header $frontend_host_header \
    --routing-rule-type Forward \
    --session-affinity Enabled \
    --ttl 30

########--------------------------#######