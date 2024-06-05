# Challenge 4: Design and implement web application security

## Background

CMC requires web application security due to regulatory compliance. In this challenge, you will design a solution which meets their requirements and integrates with your existing network design.

The objective of this challenge is to ensure you understand how to integrate solutions into your design as it begins to scale.

## Challenge

Due to regulatory compliance a web application firewall is required for any application hosted on the CMC network. CMC needs you to design a solution so all web applications including YADA can’t be directly exposed to the internet. The application team requires the original IP address of the application client to be visible to the application servers. They require web application firewalling, SSL offloading (note: your coach will provide with a public DNS name and an SSL certificate), and path-based routing.

CMC wants to prevent DDoS and keep the app up and running. They want to prevent their website from crashing by incorporating application security measures, however currently the cost of Azure DDoS Standard is prohibitive for CMC.

## Requirements

CMC has the following requirements:

- A Web Application Firewall needs to be included in the design to protect web application from web-based security vulnerabilities.
- The original IP address of the application client needs to be visible to the application servers.
- Both the web and API tiers must be accessible via a single URL, and cannot be be directly exposed to the internet.
- The solution should be a reliable service with built-in availability and redundancy.
- Ensure that malicious users can’t bypass the WAF, irrespective of their location.
- Prevent DDoS attacks while keeping the cost low.
- There is no requirement to hit the web front end from any CMC's private networks.

## Success Criteria

- Present an updated environment diagram.
- Inbound traffic must be encrypted and has to traverse the WAF. Outbound traffic must still go via the firewall.
- Explain how you arrived at your design decisions based on the requirements above.
- Explain how DDoS attacks are being prevented in the CMC environment.
- Demo how your solution is designed to prevent any malicious users from bypassing the WAF.

## References

- [Load-balancing options - Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/guide/technology-choices/load-balancing-overview?toc=%2Fazure%2Fnetworking%2Ffundamentals%2Ftoc.json)
- [What is Azure Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/overview?toc=%2Fazure%2Fnetworking%2Ffundamentals%2Ftoc.json)
- [Azure Front Door](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-overview?toc=%2Fazure%2Fnetworking%2Ffundamentals%2Ftoc.json)
- [Self-signed certificate](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-self-signed-certificate)
