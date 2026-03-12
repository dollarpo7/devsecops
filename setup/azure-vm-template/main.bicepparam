// Parameter file for Azure VM Deployment
using './main.bicep'

param location = 'westeurope'
param networkInterfaceName = 'devsecops-cloud801'
param enableAcceleratedNetworking = true
param networkSecurityGroupName = 'devsecops-cloud-nsg'
param networkSecurityGroupRules = [
  {
    name: 'allow-all'
    properties: {
      priority: 100
      protocol: '*'
      access: 'Allow'
      direction: 'Inbound'
      sourceApplicationSecurityGroups: []
      destinationApplicationSecurityGroups: []
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '*'
    }
  }
  {
    name: 'default-allow-ssh'
    properties: {
      priority: 1000
      protocol: 'TCP'
      access: 'Allow'
      direction: 'Inbound'
      sourceApplicationSecurityGroups: []
      destinationApplicationSecurityGroups: []
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '22'
    }
  }
]
param subnetName = 'default'
param virtualNetworkName = 'devsecops-cloud_group-vnet'
param addressPrefixes = [
  '10.0.0.0/16'
]
param subnets = [
  {
    name: 'default'
    properties: {
      addressPrefix: '10.0.0.0/24'
    }
  }
]
param publicIpAddressName = 'devsecops-cloud-ip'
param publicIpAddressType = 'Static'
param publicIpAddressSku = 'Basic'
param virtualMachineName = 'devsecops-cloud'
param virtualMachineComputerName = 'devsecops-cloud'
param virtualMachineRG = 'devsecops-cloud_group'
param osDiskType = 'StandardSSD_LRS'
param dataDisks = [
  {
    lun: 0
    createOption: 'attach'
    caching: 'ReadOnly'
    writeAcceleratorEnabled: false
    id: null
    name: 'devsecops-cloud_DataDisk_0'
    storageAccountType: null
    diskSizeGB: null
    diskEncryptionSet: null
  }
]
param dataDiskResources = [
  {
    name: 'devsecops-cloud_DataDisk_0'
    sku: 'StandardSSD_LRS'
    properties: {
      diskSizeGB: 512
      creationData: {
        createOption: 'empty'
      }
    }
  }
]
param virtualMachineSize = 'Standard_D4s_v3'
param adminUsername = 'devsecops'
param adminPassword = '' // Set this value before deployment
