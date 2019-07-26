# Download ASIO from steinberg website
$asiodir = "asiosdk"
Invoke-WebRequest -OutFile $pwd\$asiodir.zip https://www.steinberg.net/asiosdk

# unzip
Add-Type -AssemblyName System.IO.Compression.FileSystem
New-Item -ItemType Directory $pwd\$asiodir
[System.IO.Compression.ZipFile]::ExtractToDirectory("$pwd\$asiodir.zip", "$pwd\$asiodir")
Remove-Item $pwd\$asiodir.zip

# remove intermediate directory
$innerdir = Get-ChildItem $pwd\$asiodir
Get-ChildItem $pwd\$asiodir\$innerdir | Move-Item -Destination $pwd\$asiodir
Remove-Item $pwd\$asiodir\$innerdir