# Challenge 5: CMC goes global

## Background

CMC is ready to go global. In this challenge, you will expand the network architecture to multiple Azure regions and establish global connectivity between VNets in the Azure regions. Your network design must continue to evolve to meet the growing needs as the company expands.

The objective of this challenge is to ensure you understand how to integrate multiple regions into your design as it begins to scale.

## Challenge

CMC is ready to deploy YADA in Sweden – where their second largest customer base is. You are tasked with scaling the network to reach the new region and ensure user traffic can route to the application incorporating geo-location and performance.

## Requirements

CMC has the following requirements:

- Network presence in a new Azure region: Sweden Central
- The second instance of YADA has the same network security and application security requirements as the challenges before.
  - WAF / SSL offloading
  - Firewall
  - On prem connectivity to database server
- Optimize the traffic routing based on geo-location and performance
- Ensure end-users can still access the application in the case of a regional outage
- All users should be using a single URL regardless of what region they are accessing the application from

## Success Criteria

- Present to your coach CMCs global network design with an updated environment diagram.
- Explain your design decisions based on the requirements above.
- Present the single URL for the app.
- Demonstrate how the solution would respond in the case of a regional outage from an end-user perspective and from the Azure administrator teams’ perspective that manage the workload.
- Validate that the second instance of YADA has access to the on-premises database.

### Survey and Feedback

Congratulations on reaching this point in the hackathon experience! To ensure the quality of our product for future iterations, it is vital to have the thoughts and opinions of people like you who have experienced hackathon firsthand.

To that end, feedback is considered by the hackathon team as your "cost of participating". We request that you take a few moments to provide feedback on our survey, which should take from 3 to 7 minutes, at the conclusion of this exercise.

We appreciate your efforts and your partnership in the growth and improvement of hackathon. Good luck on the rest of your learning journey!

[Please submit your feedback here](https://forms.office.com/pages/responsepage.aspx?id=v4j5cvGGr0GRqy180BHbRxtjKWqqyqBEupdKhig1hI5UOFQ1MFYyTVdKRFFJQlRNUTQ5NUhPVzRGVC4u)

## References

- [Microsoft global network](https://learn.microsoft.com/en-us/azure/networking/microsoft-global-network?toc=%2Fazure%2Fnetworking%2Ffundamentals%2Ftoc.json)
- [Azure Traffic Manager](https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-overview?toc=%2Fazure%2Fnetworking%2Ffundamentals%2Ftoc.json)
- [Architecture: Global transit network architecture](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-global-transit-network-architecture)
- [Hub-spoke network topology in Azure](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli)
