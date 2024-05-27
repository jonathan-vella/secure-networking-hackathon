# Challenge 6: Secure access to Azure PaaS services

## Background

In this challenge, you will integrate and secure PaaS resources into your network design and configure DNS.

The objective of this challenge is to demonstrate your understanding of PaaS and DNS services available in Azure and how they can be securely integrated into a virtual network.

## Challenge

CMC needs you to ensure all PaaS services hosted on Azure that need to communicate to each other are leveraging the Microsoft Azure Backbone and do not go out to the public internet and back to the private network.

A team of Azure consultants have strongly recommended modernizing YADA, and your team has been tasked with executing their recommendation.

## Requirements

CMC has the following requirements:

The app architecture:

![Modern application diagram](images/app_webapp.png)

- The web tier needs to be deployed with an Azure web app with this docker container image: erjosito/yadaweb:1.0 and the following configurations:
  - Linux OS
  - Under docker configuration select a single container, Docker hub as your image source
- The app tier will be modernized at a later stage.
- The web app can’t be directly exposed to the internet, and all users must be directed through a WAF before accessing the application
- With the exception of Azure Firewall, no other public IP addresses should be used
- Ensure that clients can’t bypass the firewall by using \*.azurewebsites.net
- An Azure SQL database with SQL authentication in the S0 tier with locally redundant storage
- The Database should not be publicly accessible and needs to be only accessible with a private IP
- Ensure a secure connection policy
- The Azure SQL DB requires Private DNS integration
- Encrypt connections
- There is no need to populate the database since the DBAs will do that once you have secured the Azure SQL DB to the network

## Success Criteria

- Present an updated environment diagram.
- EWith the exception of Azure Firewall, no other public IP addresses should be used
- Verify users in various regions are directed to the closest workload.
- Ensure that the app tier is using a private IP address to access the DB and not able to access the public IP of your Azure SQL DB.
- DNS concepts should be understood and explained in the solution.

## References

- [Private Link and DNS integration at scale](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/private-link-and-dns-integration-at-scale)
- [Network-hardened web app](https://learn.microsoft.com/en-us/azure/architecture/example-scenario/security/hardened-web-app)
- [Securely managed web applications](https://learn.microsoft.com/en-us/azure/architecture/example-scenario/apps/fully-managed-secure-apps)
