# Challenge 4: Design and implement web application security

## Background

CMC requires web application security due to regulatory compliance. In this challenge, you will design a solution which meets their requirements and integrates with your existing network design.

The objective of this challenge is to ensure you understand how to integrate solutions into your design as it begins to scale.

## Challenge

Due to regulatory compliance a web application firewall is required for any application hosted on the CMC network. CMC needs you to design a solution so all web applications including YADA can’t be directly exposed to the internet. The application team requires the original IP address of the application client to be visible to the application servers. They require web application firewalling, SSL offloading (note: your coach will provide with a public DNS name and an SSL certificate), and path-based routing.

CMC wants to prevent DDoS and keep the app up and running. They want to prevent their website from crashing by incorporating application security measures, however currently the cost of Azure DDoS Standard is prohibitive for CMC.

## Requirements

CMC has the following requirements:

- A regional Web Application Firewall needs to be included in the design to protect the web application from web-based security vulnerabilities.
- The original IP address of the application client needs to be visible to the application servers.
- Both the web and API tiers must be accessible via a single URL, and cannot be be directly exposed to the internet.
- The solution should be a reliable service with built-in availability and redundancy. The uptime requirement is 99.99%.
- Ensure that malicious users can’t bypass the WAF, irrespective of their location.
- Prevent DDoS attacks while keeping the cost low.
- There is no requirement to hit the web front end from any CMC's private networks.

## Success Criteria

- Present an updated environment diagram.
- Inbound traffic must be encrypted and has to traverse the WAF. Outbound traffic must still go via the firewall.
- The subnet in which WAF is deployed must be secured with NSG rules.
- The solution must be configured to visualize security-relevant WAF events across several filterable panels.
- The solution must be configured to visualize WAF rule violations and help with triaging those so to facilitate tuning the WAF against valid traffic.
- Explain how you have arrived at your design decisions based on the requirements above.
- Explain how DDoS attacks are being prevented in the CMC environment.
- Demo how your solution is designed to prevent any malicious users from bypassing the WAF.

## References

- [Load-balancing options - Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/guide/technology-choices/load-balancing-overview?toc=%2Fazure%2Fnetworking%2Ffundamentals%2Ftoc.json)
- [Azure DDoS Protection Tiers](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-sku-comparison)
- [What is Azure Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/overview?toc=%2Fazure%2Fnetworking%2Ffundamentals%2Ftoc.json)
 - [Azure WAF Workbook](https://github.com/Azure/Azure-Network-Security/tree/master/Azure%20WAF/Workbook%20-%20WAF%20Monitor%20Workbook)
 - [Azure WAF Triage Workbook](https://github.com/Azure/Azure-Network-Security/tree/master/Azure%20WAF/Workbook%20-%20AppGw%20WAF%20Triage%20Workbook)

