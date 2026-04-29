# Windows PowerShell 권한 확인 스크립트

$Namespace = "team-board"
$ServiceAccount = "board-sa"

Write-Host "=== Checking RBAC Permissions ===" -ForegroundColor Green
Write-Host "ServiceAccount: $ServiceAccount@$Namespace`n" -ForegroundColor Cyan

$Resources = @("pods", "configmaps", "secrets")
$Verbs = @("get", "list", "watch")

foreach ($Resource in $Resources) {
    foreach ($Verb in $Verbs) {
        $Result = kubectl auth can-i $Verb $Resource `
            --as=system:serviceaccount:$Namespace`:$ServiceAccount `
            -n $Namespace 2>&1
        
        $Status = if ($LASTEXITCODE -eq 0) { "✓ YES" } else { "✗ NO" }
        Write-Host "$Verb $Resource`: $Status" -ForegroundColor $(if ($LASTEXITCODE -eq 0) { "Green" } else { "Red" })
    }
}
