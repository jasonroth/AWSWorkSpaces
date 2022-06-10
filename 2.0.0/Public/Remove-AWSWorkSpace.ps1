Function Remove-AWSWorkSpace {
    <#
        .SYNOPSIS
            Removes AWS Workspace.

        .DESCRIPTION
            Removes (destroys) virtual desktop instance AWS Workspaces environment
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
            Remove-AWSWorkSpace -User 'user1' -DirectoryId 'directory1' -Region 'us-east-1' -AccessKey 'mykey' -SecretKey 'mysecret'
  #>

    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $User,
        
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DirectoryId,

        [Parameter(
            Mandatory = $true,
            Position = 2,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Region,

        [Parameter(
            Mandatory = $true,
            Position = 3,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AccessKey,

        [Parameter(
            Mandatory = $true,
            Position = 4,
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
        }
    }
    Process {
        foreach ($SamAccountName in $User) {
            if ($Workspace = Get-WKSWorkspace @AWSParams -DirectoryId $DirectoryId -UserName $SamAccountName) {
                $Results = Remove-WKSWorkspace -Select * @AWSParams -WorkspaceId $Workspace.WorkspaceId -Force
                [pscustomobject]@{
                    User           = $SamAccountName
                    HttpStatusCode = $Results.HttpStatusCode
                    TimeStamp      = $Results.LoggedAt.DateTime
                    Region         = $AWSParams.Region
                    ErrorCode      = $Results.FailedRequests.ErrorCode
                    ErrorMessage   = $Results.FailedRequests.ErrorMessage
                }
            }
            else {
                Write-Warning "No Workspace found for $SamAccountName in Directory: $DirectoryId, Region: $Region"
            }
        }
    }
    End { }
}
