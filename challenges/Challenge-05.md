# Challenge 5: CMC goes global

## Background

CMC is set to expand globally. Your task is to design a network that supports CMC's worldwide growth. This network must adapt to the company's evolving needs, utilizing multiple Azure regions and establishing global connectivity between VNets. The goal of this challenge is to ensure you can integrate multiple regions into your scalable design.

## Challenge

CMC is getting ready to deploy a modernized version of YADA in Germany, where their second largest customer base is. You are tasked with scaling the network to reach the new region and ensure that in the very near future user traffic can be routed to the application based on the geo-location of the user to enhance application delivery performance.

> [!NOTE]  
> This challenge focuses solely on solution design. Implementation of the solution is not required.

## Requirements

CMC has the following requirements:

- Network presence in a new Azure region: Germany West Central.
- The revised requirements for both instances now includes a WAF at a global level and mandatory SSL offloading. These are on top of the requirements described in the previous challenge.
- Optimize the traffic routing based on geo-location and performance
- Ensure end-users can still access the application in the case of a regional outage
- All users should be using a single URL regardless of what region they are accessing the application from. Note: Your coach will share with you the new public DNS name/s you will be using for this challenge.
- Incoming traffic (i.e., global to regional) should only be allowed to originate from CMC's own global resources deployed in Azure.

## Success Criteria

- Present to your coach CMC's global network design with an updated environment diagram.
- Explain your design decisions based on the requirements above.
- Present the single URL for the app by accessing the application (currently deployed in Sweden) from a browser.
- Explain how your solution design would respond in the case of a regional outage from an end-user perspective and from the Azure administrator teams’ perspective that manage the workload.
- Explain how the solution would respond to a simulated DDoS attack.

### Survey and Feedback

Congratulations on reaching this point in the hackathon experience! To ensure the quality of our product for future iterations, it is vital to have the thoughts and opinions of people like you who have experienced hackathon firsthand.

To that end, feedback is considered by the hackathon team as your "cost of participating". We request that you take a few moments to provide feedback on our survey, which should take from 3 to 7 minutes, at the conclusion of this exercise.

We appreciate your efforts and your partnership in the growth and improvement of hackathon. Good luck on the rest of your learning journey!

[Please submit your feedback here](https://forms.office.com/)

## References

- [Microsoft global network](https://learn.microsoft.com/en-us/azure/networking/microsoft-global-network?toc=%2Fazure%2Fnetworking%2Ffundamentals%2Ftoc.json)
- [Azure Traffic Manager](https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-overview?toc=%2Fazure%2Fnetworking%2Ffundamentals%2Ftoc.json)
- [Architecture: Global transit network architecture](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-global-transit-network-architecture)
- [Hub-spoke network topology in Azure](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli)
