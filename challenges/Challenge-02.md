# Challenge 2: Deploy the first application

## Background

The application team has asked to have YADA be the first project deployed on Azure. Your task is to deploy the web and application tiers reliably in Azure. This will be the first of many applications deployed. Be sure to plan your network design accordingly.

The objective of this challenge is to ensure you understand how to design a network architecture that enables organizations to start as small as needed and scale alongside their business requirements.

## Challenge

The first app being deployed consists of 2 tiers that will be hosted in Azure (web and application) and a data tier that will remain on-premises. Although this pattern is not a public cloud best practice, CMC’s legal team has strongly recommended this approach in spite of the potential latency problems between the application and database tiers, for data residency reasons.

The front end is a public facing web server, middle tier is a REST API. The application team has provided the template that will deploy the web server and application. Your team needs to ensure the Azure virtual network is designed to support the high availability of this new 2-tiered application. Application should be resilient to the outage of any Azure VM. The on-premises database does not need to be considered in your resilient network design.

CMC has gone viral and has experienced unprecedented growth and the networking team has identified sporadic timeouts in outbound connections. In this challenge, you will also need to increase scalability of outbound connections to prevent application timeouts.

At this point the application is not a critical asset for CMC, implementing network security is not a requirement to fulfill this challenge.

Work with your team to plan and deploy a solution.

![Application diagram](images/app_vm.png)

## Requirements

CMC has the following requirements:

- The application requires a load balancing solution that can direct requests to the available endpoints to ensure application availability.
- The application needs to be able to communicate to the database resources on premises (the username is `demouser`, the password is `demo!pass123`).
- The application should be resilient to single VM failures.
- Solution should be a cost-effective solution leveraging cloud native tools
- Solution must enable the middle tier to communicate to external internet endpoints without attaching a public IP to any VM.
- Solution components should take advantage of cloud resiliency to individually meet an SLA requirement of 99.99% when possible
- The templates created by the Azure consultants will download container images from an online image repository, but they could not tell you more details about that.

## Recommendations

- Azure consultants have provided reusable ARM templates to automate the deployment of the application but have not configured the network design

  - web_template_uri='https://raw.githubusercontent.com/jonathan-vella/secure-networking-hackathon/main/hacker-assets/deploy_web_to_vm.json'
  - api_template_uri='https://raw.githubusercontent.com/jonathan-vella/secure-networking-hackathon/main/hacker-assets/deploy_api_to_vm.json'

- Some caveats for the templates have been provided by the Azure consultants:

  - These templates deploy virtual machines from the image "kinvolk:flatcar-container-linux-free:stable-gen2:latest". You might need to accept the terms for this image and change the existing Azure Policies applied to the subscription so that the templates work.
  - The Virtual Network needs to be in the same resource group as the VM being deployed through the template.
  - The ARM template will only deploy a VM, but no network configuration around it such as Network Security Groups or public IP addresses.

- In the ARM template the following parameters need to be specified for the API tier:

  - Name of the VM (`vmName`)
  - Admin credentials for the VM (`AdminUsername` and `AdminPassword`)
  - VNet and Subnet name (`virtualNetworkName`, `subnetName`)
  - SQL server FQDN or IP address (`sqlServerFQDN`)
  - SQL server credentials Username and Password (`sqlServerUser`, `sqlServerPassword`)
  - Optionally provide an availability zone (`availabilityZone`)

- In the ARM template the following parameters need to be specified for the web tier:
  - VNet and Subnet name (`virtualNetworkName`, `subnetName`)
  - App tier URL (`apiUrl`)
  - Optionally provide an availability zone (`availabilityZone`)

## Success Criteria

To successfully complete this challenge as a team you must:

- Present updated environment diagram with network segmentation
- Demonstrate application load balancing in real time
- Validate application is highly available and traffic is redirected in the case of an outage
- Validate application can communicate to the database on prem
- Validate application is working correctly and can access the internet to get its Public IP address
- Justify the cost of your solution to your coach
- Present the metrics to show the front end and backend availability is 100%

## References

- [Load-balancing options - Azure architecture center](https://learn.microsoft.com/azure/architecture/guide/technology-choices/load-balancing-overview)
- [Azure regions and availability zones](https://learn.microsoft.com/azure/availability-zones/az-overview)
- [What is Azure Virtual Network NAT](https://learn.microsoft.com/en-us/azure/virtual-network/nat-gateway/nat-overview)

_(c) Microsoft 2022_
