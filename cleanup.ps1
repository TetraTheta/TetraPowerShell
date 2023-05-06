$ErrorActionPreference = "SilentlyContinue"
#$ErrorActionPreference = "Continue"

# Check Powershell version
# This script requires Powershell 7+ due to Remove-Service (6+) and EnumerationOptions (7+)
If ($PSVersionTable.PSVersion.Major -lt 7) {
  Write-Host "This script requires Powershell 7+!"  -ForegroundColor DarkRed
  Exit 1
}

# Check Administrator mode
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  # Restart script with Administrator mode
  Start-Process pwsh -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
  exit;
}

# Delete WinDivert service if exists
Write-Host "Delete WinDivert service if exists" -ForegroundColor DarkGreen
$windivert = "WinDivert1.4"
$service = Get-Service -Name $windivert
If ($service.Length -gt 0) {
  Write-Host "WinDivert service found" -ForegroundColor DarkCyan
  If ((Get-Service -Name $windivert).Status -eq 'Running') {
    Stop-Service -InputObject $windivert -Force
  }
  Remove-Service -Name $windivert
  Write-Host "WinDivert service removed" -ForegroundColor DarkCyan
}

# Cleanup TEMP directory without deleting TEMP directory
Write-Host "Cleanup TEMP directory" -ForegroundColor DarkGreen
If (-Not (Test-Path -Path $Env:Temp -PathType Container)) {
  New-Item -Path $Env:LocalAppdata -Name "Temp" -ItemType Directory
}
Remove-Item -Path "$Env:Temp\*" -Recurse -Force

# Cleanup Appdata
Write-Host "Cleanup Appdata directory" -ForegroundColor DarkGreen
$appdata_dirs = @(
  # Directories that are in %AppData%
  ".minecraft\webcache2"
  ".mono"
  "Adguard Software Ltd"
  "Authy Desktop\Code Cache"
  "Authy Desktop\GPUCache"
  "Capture2Text"
  "changzhi2"
  "Code\Cache"
  "Code\Code Cache"
  "Code\Crashpad"
  "Code\GPUCache"
  "Code\logs"
  "discord\Cache"
  "discord\Code Cache"
  "discord\Crashpad"
  "discord\GPUCache"
  "DMCache"
  "lddownloader"
  "Mozilla\Extensions"
  "Mozilla\SystemExtensionsDev"
  "mpv"
  "NVIDIA"
  "obs-studio\logs"
  "Process Hacker\cache"
  "Waterfox"
  "WeMod\Cache"
  "WeMod\Code Cache"
  "WeMod\GPUCache"
  "XuanZhi9\android_bug"
  "XuanZhi9\log"
  "ZeqMacaw"
)
ForEach ($item in $appdata_dirs) {
  Remove-Item -Path "$Env:Appdata\$item" -Recurse -Force 
}

# Cleanup LocalAppdata
Write-Host "Cleanup LocalAppdata directory" -ForegroundColor DarkGreen
$localappdata_dirs = @(
  # Directories that are in %LocalAppData%
  ".ftba"
  ".IdentityService"
  "Adaware"
  "Adobe"
  "apktool"
  "BSTweaker"
  "cache"
  "clink"
  "Comms"
  "ConnectedDevicesPlatform"
  "CrashDumps"
  "CrashReportClient"
  "CrashRpt"
  "D3DSCache"
  "DBG"
  "EBWebView"
  "ESET"
  "FLiNGTrainer"
  "Frija"
  "GameAnalytics"
  #"Google\CrashReports"
  #"Google\Software Reporter Tool"
  "hitomi_downloader_GUI"
  "HoYoverse\Genshin Impact\cache"
  "JetBrains\IdeaIC2022.1\log"
  "JetBrains\IdeaIC2022.1\vcs-log"
  "Jonas_John"
  "Live++"
  "main.kts.compiled.cache"
  "mcaselector"
  "Microsoft_Corporation"
  "miHoYo\Genshin Impact\cache"
  "NBTExplorer"
  "Nem's Tools"
  "npm-cache"
  "NuGet\Cache"
  "NVIDIA\DXCache"
  "NVIDIA\GLCache"
  "Overwolf\BrowserCache"
  "Package Cache"
  "PeerDistRepub"
  "pip"
  "PlaceholderTileLogoFolder"
  "pypa"
  "Skyrim Special Edition"
  "Sony\ErrorReport"
  "speech"
  "SquirrelTemp"
  "Steam"
  "Waterfox"
  "_"
)
ForEach ($item in $localappdata_dirs) {
  Remove-Item -Path "$Env:LocalAppdata\$item" -Recurse -Force 
}

# Cleanup UserProfile
Write-Host "Cleanup UserProfile directory" -ForegroundColor DarkGreen
$userprofile_dirs = @(
  # Directories that are in %UserProfile%
  ".Ld9VirtualBox"
  "ansel"
  "vmlogs"
)
ForEach ($item in $userprofile_dirs) {
  Remove-Item -Path "$Env:UserProfile\$item" -Recurse -Force
}

# Delete MS input
If (Test-Path "$Env:LocalAppdata\Microsoft\input\" -PathType Container) {
  Write-Host "Delete MS input" -ForegroundColor DarkGreen
  Remove-Item -Path "$Env:LocalAppdata\Microsoft\input\" -Recurse -Force
  $f = New-Object System.IO.FileStream "$Env:LocalAppdata\Microsoft\input", Create, ReadWrite
  $f.SetLength(0)
  $f.Close()
}

# Delete auto-generated directory
Write-Host "Delete unwanted directory" -ForegroundColor DarkGreen
$unwanted_dirs = @(
  # Directories that are in various locations
  "E:\PICTURE\Camera Roll"
  "E:\PICTURE\Saved Pictures"
  "E:\PICTURE\Screenshots"
  "E:\VIDEO\Captures"
)
ForEach ($item in $unwanted_dirs) {
  Remove-Item -Path "$item" -Recurse -Force
}

# Delete logs
Write-Host "Delete logs" -ForegroundColor DarkGreen
$logs_location = @(
  "$Env:LocalAppdata"
  "$Env:Appdata"
)
$enumOption = [IO.EnumerationOptions]@{
  RecurseSubdirectories = $true
  AttributesToSkip = 2, 4, 512, 1024  # Hidden, System, SparseFile, ReparsePoint
}
$logs_location | ForEach-Object {
  ForEach ($filter in '*.log', '*.log.txt', '*-journal') {
    [IO.Directory]::EnumerateFiles($_, $filter, $enumOption)
  }
} | Remove-Item -Force

# Cleanup App Players
# Get installed apps
$installed_softwares_HKLM_64 = Get-ChildITem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$installed_softwares_HKLM_32 = Get-ChildItem -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
$installed_softwares_HKCU_64 = Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
# $installed_softwares_HKCU_32 = Get-ChildItem -Path "HKCU:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" # Does not exist
$installed_softwares = $installed_softwares_HKLM_64 + $installed_softwares_HKLM_32 + $installed_softwares_HKCU_64

# Predefine App Player check value
$app_nox = $false
$app_ld = $false

# Check App Players install status
ForEach ($obj in $installed_softwares) {
  If ($obj.GetValue('DisplayName') -eq 'NoxPlayer') {
    Write-Host "NOX App Player detected" -ForegroundColor DarkCyan
    $app_nox = $true
  }
  If ($obj.GetValue('DisplayName') -eq 'LD Player') {
    $app_ld = $true
  }
}

# Cleanup NOX App Player
If ($app_nox) {
  Write-Host "Cleanup NOX App Player" -ForegroundColor DarkGreen
  $nox_file_userprofile = @(
    "d4ac4633ebd6440fa397b84f1bc94a3c.7z"
    "inst.ini"
    "nuuid.ini"
    "useruid.ini"
    "inittk.ini"
  )
  ForEach ($item in $nox_file_userprofile) {
    Remove-Item -Path "$Env:UserProfile\$item" -Force
  }

  $nox_dir = @(
    "$Env:LocalAppdata\MultiPlayerManager\app_images"
    "$Env:UserProfile\Nox_share"
  )
  ForEach ($item in $nox_dir) {
    Remove-Item -Path "$item" -Recurse -Force
  }

  Get-ChildItem -Path "$Env:UserProfile\.BigNox\*" -File -Include "NoxVMSVC.log*" | Remove-Item -Force
  Get-ChildItem -Path "$Env:LocalAppdata\Nox\*" -File -Include "Nox.log.*" | Remove-Item -Force

  # Prevent NOX App Player ads
  $nox_dummy_dir = @(
    "$Env:LocalAppdata\Nox\loading"
    "$Env:LocalAppdata\Nox\app_images"
  )
  Write-Host "Prevent NOX App Player ads" -ForegroundColor DarkGreen
  ForEach ($item in $nox_dummy_dir) {
    If (Test-Path -Path "$item" -PathType Container) {
      Remove-Item -Path "$item" -Recurse -Force
      $f = New-Object System.IO.FileStream "$item", Create, ReadWrite
      $f.SetLength(0)
      $f.Close()
      $acl = Get-Acl -Path "$item"
      $ar = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "Deny")
      $acl.Access | ForEach-Object{$acl.RemoveAccessRule($_)}
      $acl.SetAccessRule($ar)
      Set-Acl -Path "$item" -AclObject $acl
    }
  }
}

# Cleanup LD Player
If ($app_ld) {
  Write-Host "Cleanup LD Player" -ForegroundColor DarkGreen
  $ld_dir = @(
    "$Env:Appdata\changzhi2"
    "$Env:Appdata\lddownloader"
    "$Env:Appdata\XuanZhi64\log"
    "$Env:UserProfile\.Ld2VirtualBox"
  )
  ForEach ($item in $ld_dir) {
    Remove-Item -Path "$item" -Recurse -Force
  }
}

# Remove IDM extension
If (Test-Path -Path "$Env:Appdata\IDM\idmmzcc5" -PathType Container) {
  Write-Host "Remove IDM extension" -ForegroundColor DarkGreen
  Remove-Item -Path "$Env:Appdata\IDM\idmmzcc5" -Recurse -Force
  $f = New-Object System.IO.FileStream "$Env:Appdata\IDM\idmmzcc5", Create, ReadWrite
  $f.SetLength(0)
  $f.Close()
  $acl = Get-Acl -Path "$Env:Appdata\IDM\idmmzcc5"
  $ar = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", "FullControl", "Deny")
  $acl.Access | ForEach-Object{$acl.RemoveAccessRule($_)}
  $acl.SetAccessRule($ar)
  Set-Acl -Path "$Env:Appdata\IDM\idmmzcc5" -AclObject $acl
}

# Remove Empty Directories
Write-Host "Remove Empty Directories" -ForegroundColor DarkGreen
$red_list = @(
  "$Env:Appdata\Adobe"
  "$Env:Appdata\Code"
  #"$Env:Appdata\Google"
  "$Env:Appdata\JetBrains"
  #"$Env:LocalAppdata\Google\Chrome\User Data"
  "$Env:LocalAppdata\Nox"
  "$Env:LocalAppdata\Packages"
)
$tailRecursion = {
  param($Path)
  ForEach ($childDir in Get-ChildItem -LiteralPath $Path -Directory) {
    & $tailRecursion -Path $childDir.FullName
  }
  $currentChildren = Get-ChildItem -LiteralPath $Path -Force
  $isEmpty = $currentChildren -eq $null
  if ($isEmpty) {
    Remove-Item -LiteralPath $Path -Force
  }
}
ForEach ($item in $red_list) {
  & $tailRecursion -Path $item
}

# Cleanup My Documents
Write-Host "Cleanup My Documents" -ForegroundColor DarkGreen
$mydocument = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
$md_list = @(
  "$mydocument\My Games\Tom Clancy's The Division 2\imagecache"
  "$mydocument\My Games\Tom Clancy's The Division 2\profilepicturescache"
  "$mydocument\My Games\Tom Clancy's The Division 2\ShaderCache"
)
ForEach ($item in $md_list) {
  Remove-Item -Path "$item" -Recurse -Force
}

# Empty Recycle Bin
Write-Host "Clear Recycle Bin" -ForegroundColor DarkGreen
Clear-RecycleBin -Force
