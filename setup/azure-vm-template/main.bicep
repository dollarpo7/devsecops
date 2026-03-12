// Azure VM Deployment - Bicep Template
@description('Azure region for all resources')
param location string

@description('Name of the network interface')
param networkInterfaceName string

@description('Enable accelerated networking')
param enableAcceleratedNetworking bool

@description('Name of the network security group')
param networkSecurityGroupName string

@description('Network security group rules')
param networkSecurityGroupRules array

@description('Name of the subnet')
param subnetName string

@description('Name of the virtual network')
param virtualNetworkName string

@description('Virtual network address prefixes')
param addressPrefixes array

@description('Virtual network subnets')
param subnets array

@description('Name of the public IP address')
param publicIpAddressName string

@description('Public IP allocation method')
@allowed([
  'Dynamic'
  'Static'
])
param publicIpAddressType string

@description('Public IP SKU')
@allowed([
  'Basic'
  'Standard'
])
param publicIpAddressSku string

@description('Name of the virtual machine')
param virtualMachineName string

@description('Computer name for the virtual machine')
param virtualMachineComputerName string

@description('Resource group name')
param virtualMachineRG string

@description('OS disk storage type')
@allowed([
  'Standard_LRS'
  'StandardSSD_LRS'
  'Premium_LRS'
])
param osDiskType string

@description('Data disk configurations')
param dataDisks array

@description('Data disk resource configurations')
param dataDiskResources array

@description('Virtual machine size')
param virtualMachineSize string

@description('Admin username')
param adminUsername string

@description('Admin password')
@secure()
param adminPassword string

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: networkSecurityGroupRules
  }
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
  }
}

// Public IP Address
resource publicIp 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: publicIpAddressSku
  }
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
}

// Network Interface
resource nic 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

// Data Disks
resource dataDisksResources 'Microsoft.Compute/disks@2023-01-02' = [for disk in dataDiskResources: {
  name: disk.name
  location: location
  sku: {
    name: disk.sku
  }
  properties: disk.properties
}]

// Virtual Machine
resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      dataDisks: [for (disk, i) in dataDisks: {
        lun: disk.lun
        createOption: disk.createOption
        caching: disk.caching
        diskSizeGB: disk.diskSizeGB
        managedDisk: {
          id: disk.id ?? (disk.name != null ? resourceId('Microsoft.Compute/disks', disk.name) : null)
          storageAccountType: disk.storageAccountType
        }
        writeAcceleratorEnabled: disk.writeAcceleratorEnabled
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        patchSettings: {
          patchMode: 'ImageDefault'
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  dependsOn: [
    dataDisksResources
  ]
}

// Outputs
output adminUsername string = adminUsername
output vmId string = vm.id
output publicIpAddress string = publicIp.properties.ipAddress
output networkInterfaceId string = nic.id
