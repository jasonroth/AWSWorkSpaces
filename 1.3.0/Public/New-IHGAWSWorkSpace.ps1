Function New-IHGAWSWorkSpace {
    <#
        .SYNOPSIS
            Launches new AWS Workspace.

        .DESCRIPTION
            Launches new virtual desktop instance in IHG's AWS Workspaces environment
            for specified AD users.

        .PARAMETER User
            Active Directory SamAccountName(s) for whom instances should be launched.

        .PARAMETER BundleId
            ID of AWS Bundle to be used for new Workspace(s)
            https://docs.aws.amazon.com/workspaces/latest/adminguide/amazon-workspaces-bundles.html

        .PARAMETER DirectoryId
            ID of AWS Active Directory Connector to be used for new Workspace(s).
            https://docs.aws.amazon.com/workspaces/latest/adminguide/manage-workspaces-directory.html

        .PARAMETER Region
            AWS region to be used for new Workspace(s).

        .PARAMETER Tags
            Tags to be applied to new Workspace(s).

        .PARAMETER Encrypted
            Indicate whether new Workspace(s) should use encrypted volumes.

        .PARAMETER VolumeEncryptionKey
            Certificate key used to encrypt the Root and User volumes of new AWS Workspace(s)

        .PARAMETER AccessKey
            Access key of AWS IAM account to be used for launching AWS Workspace(s).

        .PARAMETER SecretKey
            Secret key of AWS IAM account to be used for launching AWS Workspace(s)

        .EXAMPLE
            New-IHGAWSWorkSpace -User 'user1' -BundleId ihgbundle1'' -DirectoryId 'ihgdirectory1' -Region 'us-east-1' -AccessKey 'mykey' -SecretKey 'mysecret'

  #>

    [CmdletBinding(DefaultParametersetName = 'None')]
    Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $User,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $BundleId,

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
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Amazon.WorkSpaces.Model.Tag[]]
        $Tags = @([Amazon.WorkSpaces.Model.Tag]@{
                Key   = 'workgroup'
                Value = 'wrk'
            };
            [Amazon.WorkSpaces.Model.Tag]@{
                Key   = 'function'
                Value = 'ap'
            };
            [Amazon.WorkSpaces.Model.Tag]@{
                Key   = 'chef_environment'
                Value = 'Production'
            }
        ),

        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = ’EnableEncryption’)]
        [ValidateNotNullOrEmpty()]
        [switch]
        $Encrypted,

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
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = ’EnableEncryption’)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VolumeEncryptionKey,

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
            AccessKey = $AccessKey
            SecretKey = $SecretKey
            Region    = $Region
        }
    }
    Process {
        foreach ($SamAccountName in $User) {
            $WorkSpace = @{
                BundleID    = $BundleId
                DirectoryId = $DirectoryId
                Tags        = $Tags
                UserName    = $SamAccountName
            }
            if ($Encrypted) {
                $WorkSpace.Add('RootVolumeEncryptionEnabled', $true)
                $WorkSpace.Add('UserVolumeEncryptionEnabled', $true)
                $WorkSpace.Add('VolumeEncryptionKey', $VolumeEncryptionKey)
            }
            try {
                $Results = New-WKSWorkspace @AWSParams $WorkSpace
                [pscustomobject]@{
                    User           = $SamAccountName
                    HttpStatusCode = $Results.HttpStatusCode
                    TimeStamp      = $Results.LoggedAt.DateTime
                    Region         = $AWSParams.Region
                    Tags           = $Tags.Value
                    Encrypted      = $Encrypted
                    ErrorCode      = $Results.FailedRequests.ErrorCode
                    ErrorMessage   = $Results.FailedRequests.ErrorMessage
                }
            }
            catch {
                Write-Error $PSItem.Exception.Message
            }
        }
    }
    End { }
}
