#!/bin/bash

# 🚀 AWS CLI & Kubernetes 환경 자동 설치 (보안 정책 준수)
echo "==========================================="
echo "🚀 AWS CLI & Kubernetes 환경 자동 설치 (보안 강화 버전)"
echo "==========================================="

# ✅ 1️⃣ 시스템 패키지 업데이트 (보안 패치 적용)
sudo yum update -y

# ✅ 2️⃣ 네트워크 연결 확인 (보안 강화)
echo "[✔] 인터넷 연결 확인 중..."
while ! curl -s --head --fail https://www.google.com; do
    sleep 5
done
echo "[✔] 인터넷 연결 성공!"

# ✅ 3️⃣ AWS CLI 최신 버전 설치
echo "[✔] AWS CLI 설치 중..."
sudo yum remove -y awscli
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
export PATH=/usr/local/bin:$PATH
source ~/.bash_profile
echo "[✔] AWS CLI 설치 완료: $(aws --version)"

# ✅ 4️⃣ kubectl 설치
echo "[✔] kubectl 설치 중..."
KUBECTL_VERSION="1.24.13"
KUBECTL_RELEASE_DATE="2023-05-11"
curl -s -O https://s3.us-west-2.amazonaws.com/amazon-eks/${KUBECTL_VERSION}/${KUBECTL_RELEASE_DATE}/bin/linux/amd64/kubectl
chmod 755 kubectl
sudo mv kubectl /usr/local/bin/kubectl
export PATH=$PATH:/usr/local/bin
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc
echo "[✔] kubectl 설치 완료: $(kubectl version --short --client 2>&1)"

# ✅ 5️⃣ K9s 설치 (보안 강화)
echo "[✔] K9s 설치 중..."
export HOME=/home/ec2-user
export PATH=$HOME/.local/bin:$PATH
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.profile
mkdir -p $HOME/.config/k9s
mkdir -p $HOME/.local/state
mkdir -p $HOME/.local/bin
chmod 700 $HOME/.config/k9s
chmod 700 $HOME/.local/state
chmod 755 $HOME/.local/bin
chown -R ec2-user:ec2-user $HOME/.config/k9s
chown -R ec2-user:ec2-user $HOME/.local/state
chown -R ec2-user:ec2-user $HOME/.local/bin

# `k9s` 설치 & 실행 경로 확인
su - ec2-user -c "curl -sS https://webinstall.dev/k9s | bash"
echo "[✔] K9s 설치 완료"

# ✅ 6️⃣ AWS IAM 역할 확인 (IAM 사용자 Key 설정 없이 사용)
echo "[✔] AWS IAM 역할 확인 중..."
aws sts get-caller-identity --query Arn

# ✅ 7️⃣ EKS kubeconfig 업데이트 (IAM 역할 기반 인증 사용)
AWS_REGION="ap-northeast-2"
EKS_CLUSTER_NAME="my-eks"
echo "[✔] EKS 클러스터 설정 중..."
aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME} --alias ${EKS_CLUSTER_NAME}
echo "[✔] EKS kubeconfig 업데이트 완료"

# ✅ 8️⃣ Kubernetes 컨텍스트 설정
echo "[✔] Kubernetes 컨텍스트 설정 중..."
kubectl config use-context ${EKS_CLUSTER_NAME}
echo "[✔] Kubernetes 설정 완료"

# ✅ 9️⃣ 설치 검증 (보안 확인)
echo "[✔] AWS CLI 버전: $(aws --version 2>&1)"
echo "[✔] kubectl 버전: $(kubectl version --short --client 2>&1)"
echo "[✔] AWS IAM 역할 확인: $(aws sts get-caller-identity --query Arn)"
echo "[✔] 현재 Kubernetes 네임스페이스:"
kubectl get ns
echo "[✔] 현재 Kubernetes 서비스:"
kubectl get svc
echo "[✔] kube-system 네임스페이스의 ConfigMap:"
kubectl get configmap -n kube-system
echo "✅ 모든 설치 및 설정이 완료되었습니다! 🎉"

# ✅ ~/start 파일 생성 및 실행 권한 부여
echo "bash ~/start.sh" > ~/start
chmod 700 ~/start
chown ec2-user:ec2-user ~/start
