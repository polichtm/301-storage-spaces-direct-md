@minValue(2)
@maxValue(32)
param vmDiskCount int

@minValue(128)
@maxValue(1023)
param vmDiskSize int

@allowed([
  'None'
  'ReadOnly'
  'ReadWrite'
])
param diskCaching string = 'None'
param diskNamingPrefix string

var diskArray = [
  {
    name: '${diskNamingPrefix}disk0'
    diskSizeGB: vmDiskSize
    lun: 0
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk1'
    diskSizeGB: vmDiskSize
    lun: 1
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk2'
    diskSizeGB: vmDiskSize
    lun: 2
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk3'
    diskSizeGB: vmDiskSize
    lun: 3
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk4'
    diskSizeGB: vmDiskSize
    lun: 4
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk5'
    diskSizeGB: vmDiskSize
    lun: 5
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk6'
    diskSizeGB: vmDiskSize
    lun: 6
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk7'
    diskSizeGB: vmDiskSize
    lun: 7
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk8'
    diskSizeGB: vmDiskSize
    lun: 8
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk9'
    diskSizeGB: vmDiskSize
    lun: 9
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk10'
    diskSizeGB: vmDiskSize
    lun: 10
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk11'
    diskSizeGB: vmDiskSize
    lun: 11
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk12'
    diskSizeGB: vmDiskSize
    lun: 12
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk13'
    diskSizeGB: vmDiskSize
    lun: 13
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk14'
    diskSizeGB: vmDiskSize
    lun: 14
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk15'
    diskSizeGB: vmDiskSize
    lun: 15
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk16'
    diskSizeGB: vmDiskSize
    lun: 16
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk17'
    diskSizeGB: vmDiskSize
    lun: 17
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk18'
    diskSizeGB: vmDiskSize
    lun: 18
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk19'
    diskSizeGB: vmDiskSize
    lun: 19
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk20'
    diskSizeGB: vmDiskSize
    lun: 20
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk21'
    diskSizeGB: vmDiskSize
    lun: 21
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk22'
    diskSizeGB: vmDiskSize
    lun: 22
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk23'
    diskSizeGB: vmDiskSize
    lun: 23
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk24'
    diskSizeGB: vmDiskSize
    lun: 24
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk25'
    diskSizeGB: vmDiskSize
    lun: 25
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk26'
    diskSizeGB: vmDiskSize
    lun: 26
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk27'
    diskSizeGB: vmDiskSize
    lun: 27
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk28'
    diskSizeGB: vmDiskSize
    lun: 28
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk29'
    diskSizeGB: vmDiskSize
    lun: 29
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk30'
    diskSizeGB: vmDiskSize
    lun: 30
    caching: diskCaching
    createOption: 'Empty'
  }
  {
    name: '${diskNamingPrefix}disk31'
    diskSizeGB: vmDiskSize
    lun: 31
    caching: diskCaching
    createOption: 'Empty'
  }
]

output dataDiskArray array = take(diskArray, vmDiskCount)