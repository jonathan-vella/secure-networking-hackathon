# Secure Networking Artifacts
## Challenge 5: CMC goes global

You can use these commands to deploy Azure Front Door in an existing resource group (note that you need to update some of the variables):

```bash
######## Deploy Azure Front Door #########

########--------------------------########

# Variables for Azure environment
rg=rg-yada-eus01
location=eastus

# Variables for Azure Front Door
profilename=afdyadas
afdwafpolicyname=afdwafpolicy

########--------------------------########

# Create Azure Front Door profile
az afd profile create \
    --profile-name $profilename \
    --resource-group $rg \
    --sku Premium_AzureFrontDoor \
    --no-wait

# Create Azure Front Door WAF profile
az network front-door waf-policy create \
    --name $afdwafpolicyname \
    --resource-group $rg \
    --sku Premium_AzureFrontDoor \
    --disabled false \
    --mode Prevention

# Assign managed rules to the WAF policy
az network front-door waf-policy managed-rules add \
    --policy-name $afdwafpolicyname \
    --resource-group $rg \
    --type Microsoft_DefaultRuleSet \
    --action Block \
    --version 2.1

az network front-door waf-policy managed-rules add \
    --policy-name $afdwafpolicyname \
    --resource-group $rg \
    --type Microsoft_BotManagerRuleSet \
    --version 1.0

########--------------------------########
```