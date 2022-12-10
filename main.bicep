@description('Naming prefix for each new resource created. 3-char min, 8-char max, lowercase alphanumeric')
@minLength(3)
@maxLength(8)
param namePrefix string = 'i20'

param location string = resourceGroup().location

@description('Size of the S2D VMs to be created')
param vmSize string = 'Standard_D4s_v3'

@description('Enable (true) or Disable (false) Accelerated Networking - if enabling, make sure you are selecting appropriate VM Size and Region')
param enableAcceleratedNetworking bool = true

@description('Operating System Image to use for provisioning each S2D VM')
@allowed([
  '2016-Datacenter-Server-Core'
  '2016-Datacenter'
  '2019-Datacenter-Core'
  '2022-datacenter-core'
  '2022-datacenter-azure-edition-core'
])
param imageSku string = '2022-datacenter-azure-edition-core'

@description('Number of S2D VMs to be created in cluster (Min=2, Max=3)')
@minValue(2)
@maxValue(3)
param vmCount int = 2

@description('Size of each data disk in GB on each S2D VM (Min=128, Max=1023)')
@minValue(128)
@maxValue(1023)
param vmDiskSize int = 1023

@description('Number of data disks on each S2D VM (Min=2, Max=32). Ensure that the VM size you\'ve selected will support this number of data disks.')
@minValue(2)
@maxValue(32)
param vmDiskCount int = 2

@description('DNS domain name for existing Active Directory domain')
param existingDomainName string

@description('Name of the Administrator of the existing Active Directory Domain')
param adminUsername string

@description('Password for the Administrator account of the existing Active Directory Domain')
@minLength(12)
@secure()
param adminPassword string

@description('Resource Group Name for the existing VNET.')
param existingVirtualNetworkRGName string

@description('Name of the existing VNET.')
param existingVirtualNetworkName string

@description('Name of the existing subnet in the existing VNET to which the S2D VMs should be deployed')
param existingSubnetName string

@description('Name of clustered Scale-Out File Server role')
param sofsName string = 'fs01'

@description('Name of shared data folder on clustered Scale-Out File Server role')
param shareName string = 'data'

@description('Day to perform scheduled cluster-aware updating each week')
@allowed([
  'Sunday'
  'Monday'
  'Tuesday'
  'Wednesday'
  'Thursday'
  'Friday'
  'Saturday'
])
param scheduledUpdateDay string = 'Tuesday'

@description('Time to begin scheduled cluster-aware updating on selected day')
param scheduledUpdateTime string = '3:00AM'

@description('True or False to enable realtime antimalware scanning')
@allowed([
  'true'
  'false'
])
param realtimeAntimalwareEnabled string = 'true'

@description('True or False to enable scheduled antimalware scanning')
@allowed([
  'true'
  'false'
])
param scheduledAntimalwareEnabled string = 'true'

@description('Minutes past midnight to begin scheduled antimalware scanning each day')
param scheduledAntimalwareTime string = '120'

@description('Location of resources that the script is dependent on such as linked templates and DSC modules')
param _artifactsLocation string = 'https://raw.githubusercontent.com/polichtm/301-storage-spaces-direct-md/master/'

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param _artifactsLocationSasToken string = ''

var subnetRef = resourceId(existingVirtualNetworkRGName, 'Microsoft.Network/virtualNetworks/subnets', existingVirtualNetworkName, existingSubnetName)

module deployS2DCluster './nestedtemplates/deploy-s2d-cluster.bicep' = {
  name: 'deployS2DCluster'
  params: {
    namePrefix: namePrefix
    location: location
    domainName: existingDomainName
    adminUsername: adminUsername
    adminPassword: adminPassword
    nicSubnetUri: subnetRef
    imageSku: imageSku
    vmSize: vmSize
    enableAcceleratedNetworking: enableAcceleratedNetworking
    vmCount: vmCount
    vmDiskSize: vmDiskSize
    vmDiskCount: vmDiskCount
    sofsName: sofsName
    shareName: shareName
    scheduledUpdateDay: scheduledUpdateDay
    scheduledUpdateTime: scheduledUpdateTime
    realtimeAntimalwareEnabled: realtimeAntimalwareEnabled
    scheduledAntimalwareEnabled: scheduledAntimalwareEnabled
    scheduledAntimalwareTime: scheduledAntimalwareTime
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
  }
  dependsOn: []
}

output sofsPath string = '\\\\${deployS2DCluster.outputs.sofsName}\\${deployS2DCluster.outputs.shareName}'