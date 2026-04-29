# Kubernetes Board Operations

Mac에서 작성 후 Windows로 포팅된 Kubernetes/Helm/ArgoCD 자동화 레포입니다.

## 구조

```
k8s-board-ops/
├── charts/
│   └── team-board/              # Helm Chart
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-dev.yaml
│       ├── values-prod.yaml
│       └── templates/
│           └── deployment.yaml
├── manifests/
│   ├── rbac/                    # RBAC 설정
│   │   ├── service-account.yaml
│   │   ├── role.yaml
│   │   └── role-binding.yaml
│   ├── deployment.yaml
│   └── argocd/
│       └── argocd-app.yaml
└── scripts/
    ├── deploy.ps1              # 배포 스크립트
    └── setup-argocd.ps1        # ArgoCD 설치
```

## 사용법

### 1. RBAC 설정 및 배포
```powershell
kubectl apply -f manifests/rbac/service-account.yaml
kubectl apply -f manifests/rbac/role.yaml
kubectl apply -f manifests/rbac/role-binding.yaml
kubectl apply -f manifests/deployment.yaml
```

### 2. Helm으로 배포 (개발환경)
```powershell
helm install team-board charts/team-board `
  -f charts/team-board/values-dev.yaml `
  --namespace team-board `
  --create-namespace
```

### 3. ArgoCD 설치 및 배포 (자동 동기화)
```powershell
.\scripts\setup-argocd.ps1
kubectl apply -f manifests/argocd/argocd-app.yaml
```

## 환경 변수 설정

`.env` 파일 생성:
```
GITHUB_REPO=https://github.com/your-org/ops-repo
NAMESPACE=team-board
IMAGE_TAG=1.25
```

## Windows PowerShell 주의사항

- `--` 옵션 사용 (em-dash `—`는 Unix 호환성 문제)
- 경로 백슬래시 사용 (`\`)
- PowerShell 실행 정책: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`
