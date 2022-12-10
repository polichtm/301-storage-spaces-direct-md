@description('Naming prefix for each new resource created. 3-char min, 8-char max, lowercase alphanumeric')
@minLength(3)
@maxLength(8)
param namePrefix string

param location string = resourceGroup().location

@description('DNS domain name for existing Active Directory domain')
param domainName string

@description('Name of the Administrator of the existing Active Directory Domain')
param adminUsername string

@description('Password for the Administrator account of the existing Active Directory Domain')
@minLength(12)
@secure()
param adminPassword string

@description('Resource ID for existing vnet/subnet to which VM NICs should be attached')
param nicSubnetUri string

@description('Size of the S2D VMs to be created')
param vmSize string

@description('Enable (true) or Disable (false) Accelerated Networking - if enabling, make sure you are selecting appropriate VM Size and Region')
param enableAcceleratedNetworking bool

@description('Number of S2D VMs to be created in cluster (Min=2, Max=3)')
@minValue(2)
@maxValue(3)
param vmCount int

@description('Size of each data disk in GB on each S2D VM (Min=128, Max=1023)')
@minValue(128)
@maxValue(1023)
param vmDiskSize int

@description('Number of data disks on each S2D VM (Min=2, Max=32). Ensure that the VM size you\'ve selected will support this number of data disks.')
@minValue(2)
@maxValue(32)
param vmDiskCount int

@description('Name of clustered Scale-Out File Server role')
param sofsName string

@description('Name of shared data folder on clustered Scale-Out File Server role')
param shareName string

@description('Day to perform scheduled cluster-aware updating each week')
param scheduledUpdateDay string

@description('Time to begin scheduled cluster-aware updating on selected day')
param scheduledUpdateTime string

@description('True or False to enable realtime antimalware scanning')
param realtimeAntimalwareEnabled string

@description('True or False to enable scheduled antimalware scanning')
param scheduledAntimalwareEnabled string

@description('Minutes past midnight to begin scheduled antimalware scanning each day')
param scheduledAntimalwareTime string
param imagePublisher string = 'MicrosoftWindowsServer'
param imageOffer string = 'WindowsServer'
param imageSku string = '2016-Datacenter-Server-Core'
param imageVersion string = 'latest'
param _artifactsLocation string
@secure()
param _artifactsLocationSasToken string

var apiVersionStorage = '2016-01-01'
var witnessStorageName = '${namePrefix}${uniqueString(resourceGroup().id)}cw'
var witnessStorageType = 'Standard_LRS'
var vmNamePrefix = '${namePrefix}-s2d-'
var vmAvailabilitySetName = '${vmNamePrefix}as'
var clusterName = '${vmNamePrefix}c'
var s2dPrepModulesURL = '${_artifactsLocation}/dsc/prep-s2d.ps1.zip${_artifactsLocationSasToken}'
var s2dPrepFunction = 'PrepS2D.ps1\\PrepS2D'
var s2dConfigModulesURL = '${_artifactsLocation}/dsc/config-s2d.ps1.zip${_artifactsLocationSasToken}'
var s2dConfigFunction = 'ConfigS2D.ps1\\ConfigS2D'

resource vmAvailabilitySet 'Microsoft.Compute/availabilitySets@2016-04-30-preview' = {
  name: vmAvailabilitySetName
  location: location
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 2
    managed: true
  }
}

resource witnessStorage 'Microsoft.Storage/storageAccounts@2016-01-01' = {
  name: witnessStorageName
  location: location
  sku: {
    name: witnessStorageType
  }
  kind: 'Storage'
}

resource vmNamePrefix_nic 'Microsoft.Network/networkInterfaces@2016-09-01' = [for i in range(0, vmCount): {
  name: '${vmNamePrefix}${i}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: nicSubnetUri
          }
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
  }
}]

module vmNamePrefix_newVM './newVM.bicep' = [for i in range(0, vmCount): {
  name: '${vmNamePrefix}${i}-newVM'
  params: {
    vmName: '${vmNamePrefix}${i})'
    vmAvailabilitySetName: vmAvailabilitySetName
    vmSize: vmSize
    vmDiskCount: vmDiskCount
    vmDiskSize: vmDiskSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    region: location
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSKU: imageSku
    imageVersion: imageVersion
  }
  dependsOn: [
    vmNamePrefix_nic
    vmAvailabilitySet
  ]
}]

resource vmNamePrefix_1_s2dPrep 'Microsoft.Compute/virtualMachines/extensions@2015-06-15' = [for i in range(0, (vmCount - 1)): {
  name: '${vmNamePrefix}${(i + 1)}/s2dPrep'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.23'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: s2dPrepModulesURL
      configurationFunction: s2dPrepFunction
      properties: {
        domainName: domainName
        adminCreds: {
          userName: adminUsername
          password: 'PrivateSettingsRef:adminPassword'
        }
      }
    }
    protectedSettings: {
      items: {
        adminPassword: adminPassword
      }
    }
  }
  dependsOn: [
    vmNamePrefix_newVM
  ]
}]

resource vmNamePrefix_0_s2dConfig 'Microsoft.Compute/virtualMachines/extensions@2015-06-15' = {
  name: '${vmNamePrefix}0/s2dConfig'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.23'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: s2dConfigModulesURL
      configurationFunction: s2dConfigFunction
      properties: {
        domainName: domainName
        clusterName: clusterName
        sofsName: sofsName
        shareName: shareName
        vmNamePrefix: vmNamePrefix
        vmCount: vmCount
        vmDiskSize: vmDiskSize
        scheduledUpdateDay: scheduledUpdateDay
        scheduledUpdateTime: scheduledUpdateTime
        witnessStorageName: witnessStorageName
        witnessStorageKey: {
          userName: 'PLACEHOLDER-DO-NOT-USE'
          password: 'PrivateSettingsRef:witnessStorageKey'
        }
        adminCreds: {
          userName: adminUsername
          password: 'PrivateSettingsRef:adminPassword'
        }
      }
    }
    protectedSettings: {
      items: {
        adminPassword: adminPassword
        witnessStorageKey: listKeys(witnessStorage.id, apiVersionStorage).keys[0].value
      }
    }
  }
  dependsOn: [
    vmNamePrefix_newVM
    vmNamePrefix_1_s2dPrep

  ]
}

resource vmNamePrefix_IaaSAntimalware 'Microsoft.Compute/virtualMachines/extensions@2015-06-15' = [for i in range(0, vmCount): {
  name: '${vmNamePrefix}${i}/IaaSAntimalware'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.5'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: 'true'
      RealtimeProtectionEnabled: realtimeAntimalwareEnabled
      ScheduledScanSettings: {
        isEnabled: scheduledAntimalwareEnabled
        scanType: 'Quick'
        day: '0'
        time: scheduledAntimalwareTime
      }
    }
    protectedSettings: null
  }
  dependsOn: [
    vmNamePrefix_newVM
    vmNamePrefix_1_s2dPrep
    vmNamePrefix_0_s2dConfig
  ]
}]

output sofsName string = sofsName
output shareName string = shareName