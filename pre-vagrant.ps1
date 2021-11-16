$DirectoryToCreate = './tmp_src'

$golang_source = "https://golang.org/dl/go1.17.linux-amd64.tar.gz"
$golang_destination = "$pwd/tmp_src/go1.17.linux-amd64.tar.gz"

$telegraf_source = "https://dl.influxdata.com/telegraf/releases/telegraf_1.20.0~rc0-1_amd64.deb"
$telegraf_destination = "$pwd/tmp_src/telegraf_1.20.0~rc0-1_amd64.deb"

if (-not (Test-Path -LiteralPath $DirectoryToCreate)) {
    
    try {
        New-Item -Path $DirectoryToCreate -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    }
    catch {
        Write-Error -Message "Unable to create directory '$DirectoryToCreate'. Error was: $_" -ErrorAction Stop
    }
    "Successfully created directory '$DirectoryToCreate'."

}
else {
    "Directory already existed"
}


if( -not (Test-Path -Path $golang_destination)){
    try {
        echo "Downloading go"
        (New-Object System.Net.WebClient).DownloadFile($golang_source, $golang_destination)
        echo "Go downloaded"
    }
    catch{
        echo "Failed to download Go"
    }
}
else {
    echo "Go for VM's is already downloaded"
}

if( -not (Test-Path -Path $telegraf_destination)){
    try {
        echo "Downloading Telegraf"
        (New-Object System.Net.WebClient).DownloadFile($telegraf_source, $telegraf_destination)
        echo "Telegraf downloaded"
    }
    catch {
        echo "Failed to download Telegraf"
    }
}
else {
    echo "Telegraf for VM's is already downloaded"
}
