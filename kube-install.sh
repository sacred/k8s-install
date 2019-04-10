cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
        http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

#yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
yum install -y kubelet-1.14.1-0.x86_64 kubectl-1.14.1-0.x86_64 kubeadm-1.14.1-0.x86_64  --disableexcludes=kubernetes

systemctl enable --now kubelet

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system


#1. pull docker from sacred02's repos(ALL NODES)
docker pull sacred02/kube-apiserver:v1.14.0;
docker pull sacred02/kube-controller-manager:v1.14.0;
docker pull sacred02/kube-scheduler:v1.14.0;
docker pull sacred02/kube-proxy:v1.14.0;
docker pull sacred02/etcd:3.3.10;
docker pull sacred02/coredns:1.3.1;
docker pull sacred02/pause:3.1;
docker pull sacred02/flannel:v0.11.0-amd64;
docker pull sacred02/kubernetes-dashboard-amd64:v1.10.1;

#2. tar to k8s default repos(ALL NODES)
docker tag sacred02/kube-apiserver:v1.14.0 k8s.gcr.io/kube-apiserver:v1.14.0;
docker tag sacred02/kube-controller-manager:v1.14.0 k8s.gcr.io/kube-controller-manager:v1.14.0;
docker tag sacred02/kube-scheduler:v1.14.0 k8s.gcr.io/kube-scheduler:v1.14.0;
docker tag sacred02/kube-proxy:v1.14.0 k8s.gcr.io/kube-proxy:v1.14.0;
docker tag sacred02/etcd:3.3.10 k8s.gcr.io/etcd:3.3.10;
docker tag sacred02/coredns:1.3.1 k8s.gcr.io/coredns:1.3.1;
docker tag sacred02/pause:3.1 k8s.gcr.io/pause:3.1;
docker tag sacred02/flannel:v0.11.0-amd64 quay.io/coreos/flannel:v0.11.0-amd64
docker tag sacred02/kubernetes-dashboard-amd64:v1.10.1 k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1;


#3. remove sacred02's images(ALL NODES)
docker rmi $(docker images -a | grep sacred02 | awk '{print $1":"$2}')kube-install.sh 
