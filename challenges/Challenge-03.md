# Challenge 3: Design and implement network security

## Background

In this challenge, you will address the network security requirements presented by CMC.

The objective of this challenge is to ensure you understand how to translate network security requirements into solutions.

## Challenge

The Network Security team requires central control over the security aspects, such as Firewall, and requires granular management capabilities for each workload.

The company needs a highly secured environment where traffic between security zones (VNets) will be deep packet inspected by a network firewall. Traffic inside of security zones can be inspected using other technologies, but it still needs to be controlled and logged. A solution to prevent data exfiltration needs to be implemented. The solution should leverage cloud native services to provide built-in high availability and cloud scalability.

You need to make sure that the firewall is inspecting all Internet traffic from the Virtual Machines, as well as traffic going from Azure to on-premises. At this point, CMC is not looking yet into Web Application Firewall technologies: implementing a WAF is not a requirement to fulfill this challenge.

## Requirements

CMC has the following requirements:

- Log IP traffic flowing though the network security solution
- Generate insights into the traffic flow of the Azure virtual networks
- Require ingress traffic inspected by a firewall
- Prevent data exfiltration
- Ensure the web layer is only accessible to inbound traffic from the internet that has been inspected
- Ensure app layer only receives traffic from the web layer and can communicate to the database on prem
- Deploy a test VM in a test spoke network to validate connectivity
- Threat intelligence-based filtering can alert and deny traffic from/to known malicious IP addresses
- Document and present if malicious traffic is trying to access the application

## Success Criteria

- Present updated environment diagram
- Present Firewall logs and demonstrate that traffic traverses the firewall.
- Present NSG flow logs and show if there are any malicious IPs trying to access the application
- Present insights that visualize the traffic activity of the application
- Ensure the spoke VMs can reach each other with the added security measures in place.
- Ensure the VMs are not accessible on any nonrequired TCP or UDP port.
- Validate that the firewall inspects traffic from any VM in the hub or the spoke going to the public Internet or to another spoke.
- Validate that the firewall inspects traffic from any on-premises client going to the hub or any spokes.
- Identify the client source IP as seen by each web server and explain it.
- The solution should be independent of network administrators adding, changing, or removing prefixes in the on-premises network in the future.

## References

- [Azure Firewall architecture overview](https://learn.microsoft.com/en-us/azure/architecture/example-scenario/firewalls/)
- [What is Azure Firewall?](https://learn.microsoft.com/en-us/azure/firewall/overview?toc=%2Fazure%2Fnetworking%2Ffundamentals%2Ftoc.json)
- [Azure traffic analytics](https://learn.microsoft.com/en-us/azure/network-watcher/traffic-analytics)

_(c) Microsoft 2022_
