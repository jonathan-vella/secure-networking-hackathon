@description('The admin user name for both Azure Virtual Machines.')
param adminUserName string = 'demouser'

@description('The admin password for both Azure Virtual Machines.')
@secure()
param adminPassword string = 'demo!pass123'
param mocOnpremNetwork object = {
  name: 'network-cmc-onprem'
  addressPrefix: '10.0.0.0/16'
  subnetName: 'mgmt'
  subnetPrefix: '10.0.1.128/25'
}
param mocOnpremGateway object = {
  name: 'vpn-gateway-cmc-onprem'
  subnetName: 'GatewaySubnet'
  subnetPrefix: '10.0.255.224/27'
  publicIPAddressName: 'pip-onprem-vpn-gateway'
}
param sqldatabase object = {
  name: 'sqlservervm'
  subnetName: 'dataSubnet'
  subnetPrefix: '10.0.3.0/24'
}
param vmSize string = 'Standard_D2s_v3'
param configureSitetosite bool = true
param location string = 'swedencentral'
param localNetworkGateway string = 'local-gateway-cmc-onprem'
param localGatewayIpAddress string = '1.1.1.1'
param VpnGwBgpAsn int = 65001
param azureCloudVnetPrefix string = '10.1.0.0/16'

@description('The name of the SQL VM')
param virtualMachineName string = 'sqlservervm'

@description('The virtual machine size.')
param virtualMachineSize string = 'Standard_D2s_v3'

@description('Windows Server and SQL Offer')
@allowed([
  'sql2019-ws2019'
  'sql2017-ws2019'
  'SQL2017-WS2016'
  'SQL2016SP1-WS2016'
  'SQL2016SP2-WS2016'
  'SQL2014SP3-WS2012R2'
  'SQL2014SP2-WS2012R2'
])
param imageOffer string = 'sql2019-ws2019'

@description('SQL Server Sku')
@allowed([
  'Standard'
  'Enterprise'
  'SQLDEV'
  'Web'
  'Express'
])
param sqlSku string = 'SQLDEV'

@description('The admin user name of the SQL VM')
param sqladminUsername string = 'demouser'

@description('The admin password of the SQL VM')
@secure()
param sqladminPassword string = 'demo!pass123'

@description('SQL Server Workload Type')
@allowed([
  'General'
  'OLTP'
  'DW'
])
param storageWorkloadType string = 'General'

@description('Amount of data disks (1TB each) for SQL Data files')
@minValue(1)
@maxValue(8)
param sqlDataDisksCount int = 1

@description('Path for SQL Data files. Please choose drive letter from F to Z, and other drives from A to E are reserved for system')
param dataPath string = 'F:\\SQLData'

@description('Amount of data disks (1TB each) for SQL Log files')
@minValue(1)
@maxValue(8)
param sqlLogDisksCount int = 1

@description('Path for SQL Log files. Please choose drive letter from F to Z and different than the one used for SQL data. Drive letter from A to E are reserved for system')
param logPath string = 'G:\\SQLLog'

var nicNameWindows_var = 'vm-windows-nic'
var vmNameWindows_var = 'vm-windows'
var windowsOSVersion = '2022-Datacenter'
var networkInterfaceName = '${virtualMachineName}-nic'
var networkSecurityGroupName = '${virtualMachineName}-nsg'
var networkSecurityGroupRules = [
  {
    name: 'RDP'
    properties: {
      priority: 300
      protocol: 'Tcp'
      access: 'Allow'
      direction: 'Inbound'
      sourceAddressPrefix: '10.1.0.0/16'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '3389'
    }
  }
]
var publicIpAddressName = '${virtualMachineName}-publicip-${uniqueString(virtualMachineName)}'
var publicIpAddressType = 'Static'
var publicIpAddressSku = 'Standard'
var diskConfigurationType = 'NEW'
var nsgId = networkSecurityGroup.id
var dataDisksLuns = array(range(0, sqlDataDisksCount))
var logDisksLuns = array(range(sqlDataDisksCount, sqlLogDisksCount))
var dataDisks = {
  createOption: 'Empty'
  caching: 'ReadOnly'
  writeAcceleratorEnabled: false
  storageAccountType: 'Premium_LRS'
  diskSizeGB: 1023
}
var tempDbPath = 'D:\\SQLTemp'

resource mocOnpremNetwork_name 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: mocOnpremNetwork.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        mocOnpremNetwork.addressPrefix
      ]
    }
    subnets: [
      {
        name: mocOnpremNetwork.subnetName
        properties: {
          addressPrefix: mocOnpremNetwork.subnetPrefix
        }
      }
      {
        name: mocOnpremGateway.subnetName
        properties: {
          addressPrefix: mocOnpremGateway.subnetPrefix
        }
      }
      {
        name: sqldatabase.subnetName
        properties: {
          addressPrefix: sqldatabase.subnetPrefix
          networkSecurityGroup: {
            id: nsgId
          }
        }
      }
    ]
  }
  dependsOn: []
}

resource mocOnpremGateway_publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = if (configureSitetosite) {
  name: mocOnpremGateway.publicIPAddressName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    1
  ]
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  dependsOn: []
}

resource mocOnpremGateway_name 'Microsoft.Network/virtualNetworkGateways@2019-11-01' = if (configureSitetosite) {
  name: mocOnpremGateway.name
  location: location
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              mocOnpremNetwork.name,
              mocOnpremGateway.subnetName
            )
          }
          publicIPAddress: {
            id: mocOnpremGateway_publicIPAddress.id
          }
        }
        name: 'vnetGatewayConfig'
      }
    ]
    bgpSettings: {
      asn: VpnGwBgpAsn
    }
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: true
  }
  dependsOn: [
    mocOnpremNetwork_name
  ]
}

resource nicNameWindows 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: nicNameWindows_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              mocOnpremNetwork.name,
              mocOnpremNetwork.subnetName
            )
          }
        }
      }
    ]
  }
  dependsOn: [
    mocOnpremNetwork_name
  ]
}

resource vmNameWindows 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vmNameWindows_var
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmNameWindows_var
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: windowsOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicNameWindows.id
        }
      ]
    }
  }
}

resource localNetworkGateway_resource 'Microsoft.Network/localNetworkGateways@2020-05-01' = {
  name: localNetworkGateway
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: [
        azureCloudVnetPrefix
      ]
    }
    gatewayIpAddress: localGatewayIpAddress
  }
  dependsOn: []
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: publicIpAddressSku
  }
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
  dependsOn: [
    mocOnpremNetwork_name
  ]
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: networkSecurityGroupRules
  }
  dependsOn: []
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', mocOnpremNetwork.name, sqldatabase.subnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress.id
          }
        }
      }
    ]
    enableAcceleratedNetworking: true
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    mocOnpremNetwork_name
  ]
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      dataDisks: [
        for j in range(0, length(range(0, (sqlDataDisksCount + sqlLogDisksCount)))): {
          lun: range(0, (sqlDataDisksCount + sqlLogDisksCount))[j]
          createOption: dataDisks.createOption
          caching: ((range(0, (sqlDataDisksCount + sqlLogDisksCount))[j] >= sqlDataDisksCount)
            ? 'None'
            : dataDisks.caching)
          writeAcceleratorEnabled: dataDisks.writeAcceleratorEnabled
          diskSizeGB: dataDisks.diskSizeGB
          managedDisk: {
            storageAccountType: dataDisks.storageAccountType
          }
        }
      ]
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: imageOffer
        sku: sqlSku
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: sqladminUsername
      adminPassword: sqladminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
  }
  dependsOn: [
    mocOnpremNetwork_name
  ]
}

resource Microsoft_SqlVirtualMachine_sqlVirtualMachines_virtualMachine 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2021-11-01-preview' = {
  name: virtualMachineName
  location: location
  properties: {
    virtualMachineResourceId: virtualMachine.id
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    serverConfigurationsManagementSettings: {
      sqlConnectivityUpdateSettings: {
        connectivityType: 'Public'
        port: 1433
        sqlAuthUpdateUserName: sqladminUsername
        sqlAuthUpdatePassword: sqladminPassword
      }
    }
    storageConfigurationSettings: {
      diskConfigurationType: diskConfigurationType
      storageWorkloadType: storageWorkloadType
      sqlDataSettings: {
        luns: dataDisksLuns
        defaultFilePath: dataPath
      }
      sqlLogSettings: {
        luns: logDisksLuns
        defaultFilePath: logPath
      }
      sqlTempDbSettings: {
        defaultFilePath: tempDbPath
      }
    }
  }
  dependsOn: [
    mocOnpremNetwork_name
  ]
}
