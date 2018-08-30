<#

#>

###############################################
# Send outMedia to EC2 server via FTP protocol
###############################################


#
# Set Variables
#

param (
    #[Parameter(Mandatory=$false)][hashtable]$soa_hash = @{"soa_time_numerator" = 1; "soa_time_denominator" = 1; "soa_duration_denominator" = 1; "soa_duration_numerator" = 1; "outMedia" = "d:\vantage_store\9f6a097b-a131-4a87-8cb7-42c71f0d30ee\";},
    [URI]$DASH = 'file://d:\vantage_store\ae154dc4-98e0-4a52-9544-1787bd624015\sourcempeg2_422_pro_ntsc\sourcempeg2_422_pro_ntsc.mpd'
    #[URI]$DASH
)

$DebugPreference = 'continue'

# Config
$Username = "patrick"
$Password = "uHdt3laeng"
$RemoteFile = "ftp://ec2-34-219-154-58.us-west-2.compute.amazonaws.com/"

 
# copy media files
#
$extName = [System.IO.Path]::GetExtension($DASH.LocalPath)
$shortName = [System.IO.Path]::GetFileName($DASH.LocalPath)

$RemoteFile = $RemoteFile + $shortName 


# Create a FTPWebRequest object to handle the connection to the ftp server
$ftprequest = [System.Net.FtpWebRequest]::create($RemoteFile)

$credentials = New-Object System.Net.NetworkCredential($Username,$Password)
# set the request's network credentials for an authenticated connection
$ftprequest.Credentials = $credentials

$ftprequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
$ftprequest.UseBinary = 1
$ftprequest.KeepAlive = 0
$ftprequest.Timeout = 10000000
$ftprequest.ReadWriteTimeout = 10000000

# read in the file to upload as a byte array
$content = gc -en byte $DASH.LocalPath
$ftprequest.ContentLength = $content.Length

# get the request stream, and write the bytes into it
$rs = $ftprequest.GetRequestStream()
$rs.Write($content, 0, $content.Length)
# be sure to clean up after ourselves
$rs.Close()
$rs.Dispose()