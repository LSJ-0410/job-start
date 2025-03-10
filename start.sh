#!/bin/bash

# 변수 설정
AWS_REGION="ap-northeast-2"
EKS_CLUSTER_NAME="my-eks"
AWS_PROFILE="admin_user"
KUBECTL_VERSION="1.24.13"
KUBECTL_RELEASE_DATE="2023-05-11"
BIN_DIR="/usr/local/bin"

echo "==========================================="
echo "🚀 AWS CLI & Kubernetes 환경 자동 설치"
echo "==========================================="

# ✅ 1️⃣ AWS CLI 최신 버전 설치
echo "[1/5] 🛠 AWS CLI 설치 중..."
sudo yum remove -y awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
export PATH=/usr/local/bin:$PATH
source ~/.bash_profile

# ✅ 2️⃣ kubectl 설치
echo "[2/5] 🛠 kubectl 설치 중..."
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/${KUBECTL_VERSION}/${KUBECTL_RELEASE_DATE}/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
export PATH=$PATH:/usr/local/bin
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc

# ✅ 3️⃣ K9s 설치 (설치 실패 방지)
echo "[3/5] 🛠 K9s 설치 중..."
export HOME=/home/ec2-user
export PATH=$HOME/.local/bin:$PATH
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.profile
source ~/.bashrc
source ~/.profile

# `k9s` 설치 & 실행 경로 확인
curl -sS https://webinstall.dev/k9s | bash
which k9s
ls -l ~/.local/bin/k9s

# ✅ 4️⃣ EKS kubeconfig 업데이트
echo "[4/5] 🛠 EKS 클러스터 설정 중..."
aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME} --alias ${EKS_CLUSTER_NAME}

# ✅ 5️⃣ Kubernetes 컨텍스트 설정
echo "[5/5] 🛠 Kubernetes 컨텍스트 설정 중..."
kubectl config use-context ${EKS_CLUSTER_NAME}

# ✅ 설치 검증
echo "✅ AWS CLI 버전: $(aws --version 2>&1)"
echo "✅ kubectl 버전: $(kubectl version --short --client 2>&1)"
echo "✅ AWS 프로파일 정보:"
aws configure list --profile ${AWS_PROFILE}
echo "✅ 현재 Kubernetes 네임스페이스:"
kubectl get ns
echo "✅ 현재 Kubernetes 서비스:"
kubectl get svc
echo "✅ kube-system 네임스페이스의 ConfigMap:"
kubectl get configmap -n kube-system
echo "✅ 모든 설치 및 설정이 완료되었습니다! 🎉"

# ✅ ~/start 파일 생성 및 실행 권한 부여
echo "bash ~/start.sh" > ~/start
chmod +x ~/start
