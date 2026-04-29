# Windows PowerShell ArgoCD 설치 및 설정 스크립트

$ErrorActionPreference = "Stop"
$Namespace = "argocd"

Write-Host "=== ArgoCD Setup (Windows) ===" -ForegroundColor Green

# 1. Namespace 생성
Write-Host "`n[1/5] Creating argocd namespace..." -ForegroundColor Yellow
kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f -

# 2. ArgoCD 설치
Write-Host "`n[2/5] Installing ArgoCD..." -ForegroundColor Yellow
kubectl apply -n $Namespace `
    -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. 준비 대기
Write-Host "`n[3/5] Waiting for ArgoCD to be ready (timeout: 300s)..." -ForegroundColor Yellow
kubectl wait --for=condition=available deployment --all `
    -n $Namespace --timeout=300s

# 4. 초기 관리자 암호 확인
Write-Host "`n[4/5] ArgoCD Admin Password:" -ForegroundColor Yellow
$Password = kubectl get secret argocd-initial-admin-secret `
    -n $Namespace `
    -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
Write-Host "Password: $Password" -ForegroundColor Cyan

# 5. Port Forward 안내
Write-Host "`n[5/5] Port Forwarding Setup:" -ForegroundColor Yellow
Write-Host "To access ArgoCD UI, run:" -ForegroundColor Cyan
Write-Host "  kubectl port-forward svc/argocd-server -n argocd 8080:443" -ForegroundColor Green
Write-Host "`nThen open: https://localhost:8080" -ForegroundColor Green
Write-Host "Username: admin" -ForegroundColor Green
Write-Host "Password: $Password" -ForegroundColor Green

Write-Host "`n=== ArgoCD Setup Complete! ===" -ForegroundColor Green
