<#
.SYNOPSIS
    Automate setting up DDoS attack test environment in vagrant
.DESCRIPTION
    This is a script to automate setting up environemt in order to carry out 
    the DDoS attack. We are considering two type of DDoS here:
    - DNS amplification
    - SYN flood
    With this script by adding right parameter you can symulate each of them
    in vagrant environment
.PARAMETER attack_type
    type of attack to carry out. Choose one of:
    => dns_amplification
    => syn_flood
.EXAMPLE
    C:\PS> 
    ./setup_environment.ps1 -attack_type=dns_amplification
.EXAMPLE
    C:\PS> 
    ./setup_environment.ps1 -attack_type=syn_flood
.NOTES
    Author: Adrian Wisniewski, Joanna Litwin, Julia Okuniewska, 
            Michal Stachowski, Natalia Brochocka, Pawel Dorau
    Date:   October 10, 2021    
#>
param(
   [String]$attack_type
)
if($attack_type -eq $null){$attack_type="Not selected"}

$VIRTUALBOX_VER='6.1.26'
$VAGRANT_VER='2.2.18'
$REQUIRED_SOFTWARE = @("VIRTUALBOX", "VAGRANT")

function check_if_installed ([string]$software_to_check) {
    $params = @()
    $installed = (Get-WmiObject -Class Win32_Product | Where-Object Name -match $software_to_check)
    $if_installed = $installed -ne $null
    If(-Not $if_installed) {
        $params += $if_installed
        $params += $null
    }
    else {
        $params += $if_installed
        $params += $($installed | Select-Object -ExpandProperty version)
    }
    return ,$params
}
function install_choco{
    try{
        choco -v >> $null
        $choco_exit_code=$true
    } 
    catch{
        return $choco_exit_code=$false
    }
    $choco_exit_code=$?
    if($choco_exit_code){
        write-host("`n######### Chocolatey already installed #########`n")
    }else{
        write-host("`n######### Installing Chocolatey... #########`n")
        Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) 2>&1 >> logs.txt
        "------------------------------------------------------------------" | Out-File -FilePath logs.txt
    }
}
function install_software([string]$sw_name){
    $sw_params=check_if_installed($sw_name)
    $sw_req_ver=$(Get-Variable $($sw_name+'_VER') -ValueOnly)
    if($($sw_params[0]) -and ($($sw_params[1]) -eq $sw_req_ver)){
        write-host("`n######### $sw_name already installed #########`n")
    }else {
        write-host("`n######### Installing $sw_name in required version... #########`n")
        choco install vagrant -y --version=$sw_req_ver 2>&1 >> logs.txt
        write-host("`n######### $sw_name installed with exit_code=$? #########`n")
        "------------------------------------------------------------------" | Out-File -FilePath  logs.txt
    }
}
function init_environment{
    if (Test-Path -Path "Vagrant") {
        write-host("`n--------- Creating directories structure... ---------`n")
        if (Test-Path -Path ".\Vagrant\src") {write-host(".\Vagrant\src already exist")}
        else {New-Item -Path "." -Name ".\Vagrant\src" -ItemType "directory"}
        if (Test-Path -Path ".\Vagrant\DNS_config" ) {write-host(".\Vagrant\DNS_config already exist")}
        else {New-Item -Path "." -Name ".\Vagrant\DNS_config" -ItemType "directory"}
    } else {
        New-Item -Path "." -Name "Vagrant" -ItemType "directory"
        New-Item -Path "." -Name ".\Vagrant\src" -ItemType "directory"
        New-Item -Path "." -Name ".\Vagrant\DNS_config" -ItemType "directory"
    }

    Set-Location -Path .\Vagrant
    vagrant init DDoS\bionic64
    write-host("`n--------- Making copy of files to .\Vagrantfile... ---------`n")
    Copy-Item "..\Vagrantfile" -Destination ".\Vagrantfile"
    write-host("copy src\* .\Vagrant\src\")
    Copy-Item "..\src\*" -Destination ".\src"
    write-host("copy DNS_config\* .\Vagrant\DNS_config\")
    Copy-Item "..\DNS_config\*" -Destination ".\DNS_config"

    write-host("`n--------- Running Vagrant... ---------`n")
    vagrant up $attack_type
}
function main{
    write-host("declared envs:
    ATTACK_TYPE: $attack_type
    VIRTUALBOX_VER: $VIRTUALBOX_VER 
    VAGRANT_VER: $VAGRANT_VER")
    if (Test-Path -Path " logs.txt") {}
    else{New-Item -Path . -Name " logs.txt" -ItemType "file"}
    install_choco
    foreach ($sw_name in $REQUIRED_SOFTWARE){
        install_software($sw_name)
    }
    init_environment
}
main