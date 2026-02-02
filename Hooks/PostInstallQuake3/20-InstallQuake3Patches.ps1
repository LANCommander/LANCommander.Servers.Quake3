$patchUrl = "https://files.ioquake3.org/quake3-latest-pk3s.zip"

Invoke-Hook "PreInstallPatches"

if (-not (Test-Path -Path "${Env:SERVER_DIR}/baseq3/pak1.pk3")) {
    Write-Log "Downloading id patches..."

    curl --output /tmp/patches.zip $patchUrl

    unzip /tmp/patches.zip -d /tmp

    Move-Item -Force -Path "/tmp/quake3-latest-pk3s/*" -Destination $Env:SERVER_DIR

    Write-Log -Message "Installed latest patches"
}

Invoke-Hook "PostInstallPatches"