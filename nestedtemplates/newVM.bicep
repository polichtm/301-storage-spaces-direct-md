param vmName string
param vmAvailabilitySetName string
param vmSize string
param vmDiskCount int
param vmDiskSize int
param adminUsername string
param region string

@secure()
param adminPassword string
param imagePublisher string
param imageOffer string
param imageSKU string
param imageVersion string

module vmName_diskSelection './diskSelection.bicep' = {
  name: '${vmName}-diskSelection'
  params: {
    vmDiskCount: vmDiskCount
    vmDiskSize: vmDiskSize
    diskCaching: 'None'
    diskNamingPrefix: '${vmName}-data'
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2016-04-30-preview' = {
  location: region
  name: vmName
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    availabilitySet: {
      id: resourceId('Microsoft.Compute/availabilitySets/', vmAvailabilitySetName)
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSKU
        version: imageVersion
      }
      osDisk: {
        name: '${vmName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
      dataDisks: vmName_diskSelection.outputs.dataDiskArray
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmName}-nic')
        }
      ]
    }
  }
  dependsOn: [
    vmName_diskSelection
  ]
}

output vmName string = vmName