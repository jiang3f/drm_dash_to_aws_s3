<#

#>

###############################################
# Send outMedia to EC2 server via AWS S3 SDK
###############################################


#
# Set Variables
#

param (
    #[Parameter(Mandatory=$false)][hashtable]$soa_hash = @{"soa_time_numerator" = 1; "soa_time_denominator" = 1; "soa_duration_denominator" = 1; "soa_duration_numerator" = 1; "outMedia" = "d:\vantage_store\9f6a097b-a131-4a87-8cb7-42c71f0d30ee\";},
    #[URI]$DASH = 'file://d:\vantage_store\ae154dc4-98e0-4a52-9544-1787bd624015\sourcempeg2_422_pro_ntsc\sourcempeg2_422_pro_ntsc.mpd',
    [URI]$DASH,
    [string]$testName = 'DRM_DASH_BuyDRM_Widevine_Encryption'

)

$DebugPreference = 'continue'

# Constants
$s3Bucket = "demo1backups"

# Constants – Amazon S3 Credentials
$accessKeyID="AKIAJLQD5WTNQ5CSAN6A"
$secretAccessKey="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"
$myProfileName="profile_s3_user"
$region = "us-west-2"

# ======= Main =========

# Add a new profile
#$profile = Get-AWSCredential -ProfileName  profile_s3_user 
#if($profile -eq "")
#{
#    Remove-AWSCredentialProfile -ProfileName $myProfileName -Force
#}

Set-AWSCredential -AccessKey $accessKeyID -SecretKey $secretAccessKey -StoreAs $myProfileName

$AWSCredentials = Get-AWSCredentials -ProfileName $myProfileName # use Get-AWSCredentials -ListProfiles

$s3Config = New-Object Amazon.S3.AmazonS3Config
$s3Config.RegionEndpoint = [Amazon.RegionEndpoint]::$region


$s3client = New-Object Amazon.S3.AmazonS3Client($AWSCredentials,$s3Config) 


$extName = [System.IO.Path]::GetExtension($DASH.LocalPath)
$shortName = [System.IO.Path]::GetFileName($DASH.LocalPath)

# copy manafiest
$s3key = $testName + "/" + $shortName
Write-S3Object -BucketName $s3Bucket -Key $s3key -File $DASH.LocalPath -PublicReadOnly -Force 

$path = Split-Path -Path $DASH.LocalPath

$fc = New-Object -com Scripting.FileSystemObject
$folder = $fc.GetFolder($path)

# Iterate through subfolders
foreach ($i in $folder.SubFolders) {
    $thisFolder = $i.Path

    # Transform the local directory path to notation compatible with S3 Buckets and Folders
    # 1. Trim off the drive letter and colon from the start of the Path
    $s3Path = $thisFolder.ToString()
    $s3Path = $s3Path.SubString(2)
    # 2. Replace back-slashes with forward-slashes
    # Escape the back-slash special character with a back-slash so that it reads it literally, like so: "\\"
    $s3Path = $s3Path -replace "\\", "/"

    # Upload directory to S3
    $s3key = $testName + "/" + $i.Name
    Write-S3Object -BucketName $s3Bucket -Folder $thisFolder -KeyPrefix $s3key -PublicReadOnly -Force 
}

$outMedia = "https://s3-us-west-2.amazonaws.com/"
$outMedia += $s3Bucket
$outMedia += "/" + $testName
$outMedia += "/" + $shortName

Write-Output $outMedia