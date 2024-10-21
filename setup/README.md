# Microsoft hackathon Bring your Own Subscription (BYOS)

Bring your own subscription (BYOS) enables you to participate in a Microsoft hackathon using your own Azure subscription(s). The documentation in this repository provides guidance on how to setup each hackathon in your subscription as well as an overview of some of the differences you will see when interacting with the coach and attendee portals of hackathon when using your own subscription.

**Contents**

<!-- TOC -->

- [Microsoft hackathon Bring your Own Subscription (BYOS)](#microsoft-hackathon-bring-your-own-subscription-byos)
  - [Timing Alert](#timing-alert)
  - [Azure Subscription Guidance](#azure-subscription-guidance)
    - [User and Team Structure](#user-and-team-structure)
    - [Azure Subscription Structure](#azure-subscription-structure)
    - [Azure AD Permissions](#azure-ad-permissions)
    - [Azure Consumption Estimate](#azure-consumption-estimate)

<!-- /TOC -->

## Timing Alert

Setup of environment may take extensive time. For safe measure, please start running the hackathon on your Azure subscription(s) at least 48 hours before the kickoff of the event.

## Azure Subscription Guidance

### User and Team Structure

Participants work together as a team (usually around 5-6 people per team). In the diagrams below you will see user accounts specified as hackerXXXX@yourtenant.onmicrosoft.com. You can optionally use generated accounts in that format just for the hackathon or you can use your users' real user accounts.

### Azure Subscription Structure

The approach is to provide ownership access at the subscription level for hackathon participants. This approach is the most open and flexible method to allow attendees to use the widest range of tools at their disposal to complete the hackathon. The tradeoff is attendees have full control over any resource that can be created in the subscription.

![Azure Subscription per Team](images/subscription-per-team-style.png "Azure Subscription per Team")

### Azure AD Permissions

This hackathon does not require additional permissions in Azure AD. It is **not recommended** to run this hackathon in a production Azure AD tenant.

### Azure Consumption Estimate

Estimated Azure Consumption per team is of $400 assuming that "on-premises" is deployed 2-3 days prior to the hackathon and that all resources are deleted at the end of the hackathon.
The below are resources deployed as part of the deployment script (per team). This is a subset of the resources required during the hackathon. Attendees will be deploying additional resources during the hackathon such as Azure Front Door, Azure Firewall, Azure VPN Gateway, Azure Application Gateway, Azure Virtual Machines, Azure SQL, Azure App Services, Azure Bastion, etc.

| Azure resource                | Pricing tier/SKU | Purpose                                          |
| ----------------------------- | ---------------- | ------------------------------------------------ |
| Azure Virtual Network         | n/a              | Network space for on premises                    |
| Azure Network Security Group  | n/a              | SQL subnet, and mgmt subnet NSG                  |
| Azure Public IP               | Standard         | On-premises VPN gateway public IP                |
| Azure Virtual Machine         | Standard D2S v3  | SQL Server VM                                    |
| Azure Virtual Machine         | Standard D2S v3  | Windows VM                                       |
| Azure Virtual Network Gateway | VPNGW1           | On-premises Gateway                              |
