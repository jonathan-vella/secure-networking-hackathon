# Challenge 7: Integrating name resolution between Azure and on-premises

## Background

In this challenge, you will learn advanced DNS techniques to manage and integrate your private DNS on-premises and in Azure.

The objective of this challenge is to understand how to manage and integrate your private DNS on-premises and in Azure.

## Challenge

## Requirements

- CMC requires all names on-premises to be resolvable from Azure resources
- The on-premises VM needs to access the new SQL DB via FQDN & Private Link
- Ensure requests are being forwarded appropriately from on-premises to Azure
  - Leverage the existing windows VM as the on-prem DNS server
- Azure VMs need to resolve on-premises names (cmcsqlserver.cmc.corp)

## Success Criteria

- Design your DNS solution. Solution must include at least 2 options for name resolution in the context of Private DNS & Private Endpoints in Azure. Discuss pros & cons with your coach.
- Azure workloads can resolve on-prem names
- On-prem workloads can resolve Azure workload names

## References

- [What is IP address 168.63.129.16?](https://learn.microsoft.com/azure/virtual-network/what-is-ip-address-168-63-129-16)
- [What is Azure DNS private resolver](https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview)
- [Implement DNS forwarding](https://learn.microsoft.com/en-us/training/modules/implement-windows-server-dns/5-implement-dns-forwarding)
- [Manage DNS for Azure AD Domain Services](https://learn.microsoft.com/en-us/azure/active-directory-domain-services/manage-dns)
