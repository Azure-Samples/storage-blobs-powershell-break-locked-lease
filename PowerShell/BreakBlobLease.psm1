#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 

Function BreakBlobLease(){

[CmdletBinding(SupportsShouldProcess = $true)]

Param
(
    [Parameter(Mandatory=$true)]
    [Alias('SN')]
    [String]$StorageAccountName,
    [Parameter(Mandatory=$true)]
    [Alias('CN')]
    [String]$ContainerName,
    [Parameter(Mandatory=$true)]
    [Alias('BN')]
    [String]$BlobName
)
    Try
    {
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
    }
    Catch
    {
        Write-Error $_.Exception.Message
    }
}
