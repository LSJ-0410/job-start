#!/bin/bash

echo "==========================================="
echo "🚀 AWS CLI & Kubernetes 환경 자동 설치"
echo "==========================================="

# ✅ 1️⃣ 시스템 패키지 업데이트
echo "[✔] 시스템 패키지 업데이트 중..."
sudo yum update -y

# ✅ 2️⃣ 네트워크 연결 확인
echo "[✔] 인터넷 연결 확인 중..."
while ! curl -s --head --fail https://www.google.com; do
    sleep 5
done
echo "[✔] 인터넷 연결 성공!"

# ✅ 3️⃣ AWS CLI 최신 버전 설치
echo "[✔] AWS CLI 설치 중..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/
export PATH=/usr/local/bin:$PATH
source ~/.bash_profile
echo "[✔] AWS CLI 설치 완료: $(aws --version)"

# ✅ 4️⃣ kubectl 설치 (EKS와 연결하지 않음)
echo "[✔] kubectl 설치 중..."
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
export PATH=$PATH:/usr/local/bin
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc
echo "[✔] kubectl 설치 완료: $(kubectl version --short --client 2>&1)"

# ✅ 5️⃣ k9s 설치 (GitHub 최신 버전 자동 다운로드)
echo "[✔] K9s 설치 중..."
mkdir -p $HOME/.local/bin
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name"' | cut -d '"' -f 4)
curl -LO "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
tar -xzf k9s_Linux_amd64.tar.gz
chmod +x k9s
mv k9s $HOME/.local/bin/
rm -f k9s_Linux_amd64.tar.gz
export PATH=$HOME/.local/bin:$PATH
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
echo "[✔] K9s 설치 완료: $(k9s version)"

# ✅ 6️⃣ 설치 검증
echo "[✔] AWS CLI 버전: $(aws --version 2>&1)"
echo "[✔] kubectl 버전: $(kubectl version --short --client 2>&1)"

echo "✅ 모든 설치 및 설정이 완료되었습니다! 🎉"

# ✅ ~/start 파일 생성 및 실행 권한 부여
echo "bash ~/start.sh" > ~/start
chmod 700 ~/start
chown ec2-user:ec2-user ~/start
