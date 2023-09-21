# Challenge 8: Centrally manage Azure Virtual Networks at scale

## Background

In this challenge, you will operationalize your network design by leveraging cloud native scaling and management tools.

The objective of this challenge is to understand how to achieve network management and security at scale.

## Challenge

CMC wants to leverage the built-in management tools Azure has to offer. They need a solution to centrally manage their Azure Virtual Networks.

## Requirements

- Ensure denial of internet traffic over TCP port 23 is manageable at scale by making sure every VM regardless of its NSG configuration does not allow inbound communication on TCP port 23.
- NSG admin rules should not be applied if the vnet has a specific tag "securityneeded=No".
- CMC has identified that traffic between spokes requires very low latency and requires a solution to reduce the current latency in an automated fashion.
- The resource tag "securityneeded=No" should not affect the low-latency connectivity between spokes
- Inter-spoke traffic between networks does not need to be filtered by the firewall regardless of the region
- Automate the processes for onboarding a spoke network as much as possible

## Success Criteria

- Show central management of denial of traffic over TCP port 23 at scale
- Confirm applied configuration and show how any new VNets will be managed under your solution
- Demonstrate automation when creating a new VNet, with and without the resource tag "securityneeded=no"

## References

- [Common use cases for Azure Virtual Network Manager](https://learn.microsoft.com/en-us/azure/virtual-network-manager/concept-use-cases)
