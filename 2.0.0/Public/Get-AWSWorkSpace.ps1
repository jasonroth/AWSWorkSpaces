Function Get-AWSWorkSpace {
    <#
        .SYNOPSIS
            Retrieves information about AWS Workspace.

        .DESCRIPTION
            Retrieves information about virtual desktop instance in AWS Workspaces environment
            for specified AD users.

        .PARAMETER User
            Active Directory SamAccountName(s) for whom instances should be launched. 

        .PARAMETER DirectoryId
            ID of AWS Active Directory Connector to be used for new Workspace(s).
            https://docs.aws.amazon.com/workspaces/latest/adminguide/manage-workspaces-directory.html

        .PARAMETER Region
            AWS region to be used for new Workspace(s).

        .PARAMETER AccessKey
            Access key of AWS IAM account to be used for launching AWS Workspace(s).

        .PARAMETER SecretKey
            Secret key of AWS IAM account to be used for launching AWS Workspace(s) 

        .EXAMPLE
            Get-AWSWorkSpace -User 'user1' -DirectoryId 'directory1' -Region 'us-east-1' -AccessKey 'mykey' -SecretKey 'mysecret'
  #>

    [CmdletBinding()]
    Param (
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $User = '*',

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DirectoryId,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Region,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AccessKey,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SecretKey
    )

    Begin {
        $AWSParams = @{
            AccessKey   = $AccessKey
            SecretKey   = $SecretKey
            Region      = $Region
            DirectoryId = $DirectoryId
        }
    }
    Process {
        foreach ($SamAccountName in $User) {
            try {
                if ($SamAccountName -eq '*') {
                    $SamAccountName = $null
                }
                if ($Results = Get-WKSWorkspace @AWSParams -UserName $SamAccountName) {
                    Write-Output $Results
                }
                else {
                    Write-Warning "No Workspace found for $SamAccountName in Directory: $DirectoryId, Region: $Region"
                }
            }
            catch {
                Write-Error $PSItem.Exception.Message
            }
        }
    }
    End { }
}
