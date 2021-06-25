Function Select-IHGAWSKey {
    <#
        .SYNOPSIS
            Selects encryption key for use with AWS Workspace.

        .DESCRIPTION
            Queries encryption keys configured for AWS Workspaces,
            and selects key with fewest created grants.

        .PARAMETER Filter
            String used for filtered search of encryption keys.

        .PARAMETER Region
            AWS region in which the AWS keys have been created.

        .PARAMETER AccessKey
            Access key of AWS IAM account to be used for querying keys.

        .PARAMETER SecretKey
            Secret key of AWS IAM account to be used for querying keys.

        .EXAMPLE
            Select-IHGAWSKey -Filter 'Workspace' -Region 'us-east-1' -AccessKey 'mykey' -SecretKey 'mysecret'
  #>

    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Filter,

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
            AccessKey = $AccessKey
            SecretKey = $SecretKey
            Region    = $Region
        }
    }
    Process {
        Try {
            $Keys = Get-KMSAliasList @AWSParams |
            Where-Object AliasName -Like "*$Filter*"
        }
        catch {
            throw $PSItem.Exception.Message
        }

        $KeyGrants = foreach ($Key in $Keys) {
            try {
                $Grants = Get-KMSGrantList @AWSParams -KeyId $Key.TargetKeyID
                [pscustomobject]@{
                    AliasName      = $Key.AliasName
                    NumberOfGrants = $Grants.Count
                }
            }
            catch {
                Write-Warning $PSItem.Exception.Message
            }
        }
        if ($KeyGrants) {
            $TargetKey = $KeyGrants |
            Where-Object -Property NumberOfGrants -EQ ($KeyGrants |
                Measure-Object -Property NumberOfGrants -Minimum -Maximum).Minimum

            Write-Output $TargetKey[0]
        }
    }
    End { }
}
