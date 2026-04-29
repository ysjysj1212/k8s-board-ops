# Windows PowerShell 배포 스크립트
# 사용: .\deploy.ps1 -Environment dev

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "prod")]
    [string]$Environment
)

$ErrorActionPreference = "Stop"
$Namespace = "team-board"
$ChartPath = "..\charts\team-board"

Write-Host "=== Kubernetes Board Deployment (Windows) ===" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Cyan

# Namespace 생성
Write-Host "`n[1/4] Creating namespace..." -ForegroundColor Yellow
kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f -

# RBAC 설정 적용
Write-Host "`n[2/4] Applying RBAC..." -ForegroundColor Yellow
kubectl apply -f ..\manifests\rbac\service-account.yaml
kubectl apply -f ..\manifests\rbac\role.yaml
kubectl apply -f ..\manifests\rbac\role-binding.yaml

# Helm 배포
Write-Host "`n[3/4] Deploying with Helm ($Environment)..." -ForegroundColor Yellow
$ValuesFile = "..\charts\team-board\values-$Environment.yaml"

helm upgrade --install team-board $ChartPath `
    -f $ChartPath\values.yaml `
    -f $ValuesFile `
    --namespace $Namespace `
    --create-namespace

# 배포 확인
Write-Host "`n[4/4] Checking deployment status..." -ForegroundColor Yellow
kubectl get deployment -n $Namespace
kubectl get pods -n $Namespace

Write-Host "`n=== Deployment Complete! ===" -ForegroundColor Green
Write-Host "View pods: kubectl get pods -n $Namespace" -ForegroundColor Cyan
Write-Host "View logs: kubectl logs -n $Namespace -l app=team-board-backend" -ForegroundColor Cyan
