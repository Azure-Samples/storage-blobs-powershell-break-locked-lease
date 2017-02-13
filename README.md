---
services: storage
platforms: powershell
author: msonecode
---

# How to break the locked lease of blob storage by ARM in Microsoft Azure (PowerShell)

## Introduction
This PowerShell script sample shows [how to break the locked lease of blob storage by ARM resources in Microsoft Azure](https://gallery.technet.microsoft.com/How-to-break-the-locked-d01ba283).

**For the script of ASM version:**  
[How to break the locked lease of blob storage by ASM in Microsoft Azure (PowerShell)][1]


## Prerequisites
- Windows PowerShell 3.0
- Windows Azure PowerShell

## Scenarios

Microsoft Azure provides functionality of acquiring lock-on blobs to avoid concurrent writing to blobs. Yet in some cases, if the backup fails due to the prolonged or sustained network connectivity failure, the backup process may not be able to gain access to the blob and the blob may remain orphaned. This means that the blob cannot be written to or to be deleted until the lease has been released. Under this condition, you might need to break the lease on a blob， and this script can help you with that.


## Import and how to use

- Run the script in the Windows PowerShell Console, type the command: **Import-Module** `<Script Path>` at the prompt. For example, type **Import-Module C:\Scripts\BreakBlobLease.psm1**  
- If you want to get a list of all cmdlet help topics, type the command **Get-Help BreakBlobLease -Full** to display the entire help file for this function, such as the syntax, parameters, or examples. This is shown in the following image.  
![][2]

## Examples
**Example 1:** Type **BreakBlobLease -StorageAccountName "franktanblobstorage" -ContainerName "bootdiagnostics-vmfrtawin-ea191696-c935-4fa2-8b49-0802a2851187" -BlobName "vm-frta-win10.ea191696-c935-4fa2-8b49-0802a2851187.screenshot.bmp"** command in the Windows PowerShell Console.  
![][3]

## Script
``` ps1
Login-AzureRmAccount -ErrorAction Stop 
         $storageAccounts = Get-AzureRmStorageAccount -ErrorAction Stop 
 
         $selectedStorageAccount = $storageAccounts | where-object{$_.StorageAccountName -eq $StorageAccountName} 
         If($selectedStorageAccount) 
         { 
            $key = (Get-AzureRmStorageAccountKey -ResourceGroupName $selectedStorageAccount.ResourceGroupName -name $selectedStorageAccount.StorageAccountName -ErrorAction Stop)[0].value 
            $storageContext = New-AzureStorageContext -StorageAccountName $selectedStorageAccount.StorageAccountName -StorageAccountKey $key -ErrorAction Stop 
            $storageContainer = Get-AzureStorageContainer -Context $storageContext -Name $ContainerName -ErrorAction Stop 
            $blob = Get-AzureStorageBlob -Context $storageContext -Container  $ContainerName -Blob $BlobName -ErrorAction Stop          
            $leaseStatus = $blob.ICloudBlob.Properties.LeaseStatus; 
            If($leaseStatus -eq "Locked") 
            { 
                 $blob.ICloudBlob.BreakLease() 
                 Write-Host "Successfully broken lease on '$BlobName' blob." 
            } 
            Else 
            { 
                #$blob.ICloudBlob.AcquireLease($null, $null, $null, $null, $null) 
                Write-Host "The '$BlobName' blob's lease status is unlocked." 
            } 
         } 
         Else  
         { 
             Write-Warning  Write-Warning "Cannot find storage account '$StorageAccountName' because it does not exist. Please make sure thar the name of storage is correct." 
         }
```

[1]: https://gallery.technet.microsoft.com/How-to-break-the-locked-c2cd6492
[2]: images/1.png
[3]: images/2.png
