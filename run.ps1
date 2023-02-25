# this was a semi-tutorial hell project, copilot wrote half of it and i haven't scripted in a while so this is really barebones
function calculate-file-hash($filepath) {
    $filehash = get-filehash -path $filepath -algorithm SHA512
    return $filehash
}
Function erase-baseline-existing() {
    $baselineExists = test-path -path .\baseline.txt

    if ($baselineExists) {
        remove-item -path .\baseline.txt
    }
}

write-host ""
write-host "What would you like to do?"
write-host ""
write-host "    A) Collect new baseline?"
write-host "    B) Monitor files with saved baseline?"
write-host ""
$response = read-host -prompt "Enter 'A' or 'B'"
write-host ""


if ($response -eq "A".ToUpper()) {
    erase-baseline-existing
    $files = Get-ChildItem -Path .\Files

    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    }
}

if ($response -eq "B".ToUpper()) {
    $baselineExists = test-path -path .\baseline.txt

    if ($baselineExists) {
        $baseline = get-content .\baseline.txt
        $files = Get-ChildItem -Path .\Files

        foreach ($f in $files) {
            $hash = Calculate-File-Hash $f.FullName
            $baselineHash = $baseline | where { $_.split("|")[0] -eq $f.FullName } | select -first 1 | % { $_.split("|")[1] }
            if ($hash.Hash -ne $baselineHash) {
                write-host "File $($f.FullName) has been modified!"
            }
        }
    } else {
        write-host "No baseline found. Please run option A first."
    }
}
