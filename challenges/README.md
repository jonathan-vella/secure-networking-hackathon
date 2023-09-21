# Welcome to the _Secure Networking_ hackathon

Hello and welcome to the Secure-Networking hackathon, a challenge-oriented hack event from Microsoft. You will be presented with a series of challenges, each one more difficult than the one before.

During this hack your team will focus on designing and implementing networking solutions in Azure that meet the demanding needs of today’s global enterprise organizations. You will analyze the customers’ on-premises environment and design a secure networking solution for their workloads as they are migrated to Azure.

At the end of the hack, you will be able to design and deploy a scalable network architecture on Azure and securely connect Azure workloads to on-premises and external environments. You will know how to identify potential networking design pitfalls, how to architect and implement networking solutions to improve workload performance, scalability, and security in Azure. You will be able to identify multiple design solutions and evaluate which solution is best for the presented scenario.

## The Challenges

Each challenge will lead you through a stage of the technical investigation as you gather technical requirements and understand the success criteria. These investigations become more technically challenging as you progress.

You will work as a team to complete each challenge and present your solution to your coach before moving on to the next.

We do not provide guides or instructions to solve the challenges, just a few hints and documentation references that you may find useful. There are multiple ways to solve each challenge, and very likely some we haven't thought of. We're interested in seeing your own unique solutions to each problem, and you should absolutely work with your coaches and the hackathon Team to validate that your solution meets the success criteria.

## hackathon Scenario

Contoso Mortgage Company (CMC) is in the process of expanding their cloud footprint and needs a secure global cloud network. They have tasked you and your team with designing and deploying their Azure network environment and gradually scaling up to meet the demands of their enterprise level security and network requirements. CMC is currently focused on leveraging a combination of PaaS and IaaS resources in Azure. It is up to you to present the best design based on their requirements.

CMC had a team of Microsoft Azure Consultants evaluate their workloads and provide solutions to modernize their applications.

## Architecture

CMC uses several on-premises web applications to service loan applications today. One of these applications, OHND App, is a public-facing website where customers can make requests for mortgages, check the status of their mortgage application, and learn more about the company's offerings.

As the existing applications are migrated and some modernized to PaaS your mission is to provide secure networking services in Azure to keep the applications accessible on the network.

Contoso Mortgage Company wants to target the OHND App for deployment to Azure. This application consists of a web tier, an application (API) tier, and a data tier utilized by both the public-facing and employee-facing sites.

The different tiers are segmented and constrained in communication. The web front ends are accessible over port 80 to end-users. The application tier is only accessible over port 8080 by the respective web server, and the database tier is only accessible by the application tiers over port 1433. The web and application components have healthcheck endpoints that can be used for health monitoring:

- Web: /healthcheck.html
- API: /api/healthcheck

## Prerequisites

- Download and install the latest version of PowerShell 7.x
- Download and install the latest version of Azure CLI and the Azure PowerShell Module
- Install your choice of Integrated Development Environment (IDE) software, such as Visual Studio or Visual Studio Code

## Recommendations

Please read these suggestions from our coaches to have an optimal hackathon experience:

- Diagram. Every. Step. Diagrams will help you to keep track of what your team is doing and will also help you to avoid making mistakes. Whether you use Paint, PowerPoint, Whiteboard, Visio or draw.io is not important, but the more you diagram, the faster you will be.
- Use Infrastructure-as-Code approaches (ARM, Bicep, Terraform, CLI, Powershell) as much as you can. Which tool you use is not important, but especially for repetitive tasks (for example creating virtual machines), scripting them can help you save time.
- Work as a team! There are multiple members in your team, use this to your advantage! You can parallelize repetitive activities, or you can split the roles of the team members. For example, in hybrid challenges part of the team can take on the on-premises configuration, while the other tackles the Azure resources, or you can have dedicated team members for activities like diagrams or creating IaC snippets.

_(c) Microsoft 2022_
