# Decrypt .subdiv files, calculate size and MD5 of decrypted files, and update .fileset files

$basePath = "."
$key = "576162746563205261696C7761792045"
$iv = "2B7E151628AED2A6ABF7158809CF4F3C"

# Find OpenSSL
$opensslPath = $null
$possiblePaths = @(
    "openssl",
    "C:\Program Files\Git\usr\bin\openssl.exe",
    "C:\OpenSSL-Win64\bin\openssl.exe",
    "C:\OpenSSL-Win32\bin\openssl.exe",
    "$env:ProgramFiles\OpenSSL-Win64\bin\openssl.exe",
    "$env:ProgramFiles\OpenSSL-Win32\bin\openssl.exe"
)

foreach ($path in $possiblePaths) {
    if (Get-Command $path -ErrorAction SilentlyContinue) {
        $opensslPath = $path
        Write-Host "Found OpenSSL at: $opensslPath"
        break
    }
}

if (-not $opensslPath) {
    Write-Host "ERROR: OpenSSL not found. Please install OpenSSL or add it to your PATH."
    Write-Host "You can download it from: https://slproweb.com/products/Win32OpenSSL.html"
    exit 1
}

# Get all GEO folders
$geoFolders = Get-ChildItem -Path $basePath -Directory | Where-Object { $_.Name -like "GEO*" }

foreach ($folder in $geoFolders) {
    Write-Host "`nProcessing: $($folder.Name)"
    
    # Find the .subdiv file
    $subdivFile = Get-ChildItem -Path $folder.FullName -Filter "*.subdiv" | Select-Object -First 1
    if (-not $subdivFile) {
        Write-Host "  No .subdiv file found, skipping..."
        continue
    }
    
    Write-Host "  Found file: $($subdivFile.Name)"
    
    # Create temporary decrypted file name
    $decryptedFile = Join-Path $folder.FullName "temp_decrypted.tmp"
    
    # Decrypt the file
    Write-Host "  Decrypting..."
    $decryptArgs = @(
        "enc",
        "-d",
        "-aes-128-cbc",
        "-in", "`"$($subdivFile.FullName)`"",
        "-out", "`"$decryptedFile`"",
        "-K", $key,
        "-iv", $iv
    )
    
    $process = Start-Process -FilePath $opensslPath -ArgumentList $decryptArgs -Wait -NoNewWindow -PassThru -RedirectStandardError "error.tmp"
    
    if ($process.ExitCode -ne 0) {
        $errorMsg = Get-Content "error.tmp" -ErrorAction SilentlyContinue
        Write-Host "  ERROR: Decryption failed for $($subdivFile.Name)"
        if ($errorMsg) {
            Write-Host "  Error details: $errorMsg"
        }
        Remove-Item "error.tmp" -ErrorAction SilentlyContinue
        continue
    }
    
    Remove-Item "error.tmp" -ErrorAction SilentlyContinue
    
    if (-not (Test-Path $decryptedFile)) {
        Write-Host "  ERROR: Decrypted file was not created"
        continue
    }
    
    # Calculate size and MD5 of decrypted file
    $decryptedInfo = Get-Item $decryptedFile
    $size = $decryptedInfo.Length
    $md5 = (Get-FileHash $decryptedFile -Algorithm MD5).Hash.ToLower()
    
    Write-Host "  Decrypted size: $size bytes"
    Write-Host "  Decrypted MD5: $md5"
    
    # Update .fileset file
    $filesetFile = Get-ChildItem -Path $folder.FullName -Filter "*.fileset" | Select-Object -First 1
    if ($filesetFile) {
        $content = Get-Content $filesetFile.FullName -Raw
        
        # Update size and MD5 in the file line
        $content = $content -replace 'file "([^"]+)" size=\d+ md5=[a-f0-9]+', "file `"`$1`" size=$size md5=$md5"
        
        Set-Content -Path $filesetFile.FullName -Value $content -NoNewline
        
        # Calculate new MD5 of updated .fileset
        $newFilesetMD5 = (Get-FileHash $filesetFile.FullName -Algorithm MD5).Hash.ToLower()
        Write-Host "  Updated .fileset MD5: $newFilesetMD5"
        
        # Clean up temporary decrypted file
        Remove-Item $decryptedFile -Force
    } else {
        Write-Host "  ERROR: No .fileset file found"
        Remove-Item $decryptedFile -Force
        continue
    }
}

Write-Host "`nDecryption and update complete!"
