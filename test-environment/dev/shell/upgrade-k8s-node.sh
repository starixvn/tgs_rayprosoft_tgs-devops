
apt-mark unhold kubeadm && apt-get update && apt-get install -y kubeadm=1.23.3-00 && apt-mark hold kubeadm
apt-get update && apt-get install -y --allow-change-held-packages kubeadm=1.23.3-00 




apt-get update && apt-get install -y --allow-change-held-packages kubelet=1.23.3-00 kubectl=1.23.3-00 kubeadm=1.23.3-00 

apt-get update && apt-get install -y --allow-change-held-packages kubelet=1.23.5-00 kubectl=1.23.5-00 kubeadm=1.23.5-00 


apt-mark unhold kubelet kubectl kubeadm && apt-get update && apt-get install -y kubelet=1.21.8-00 kubectl=1.21.8-00 kubeadm=1.21.8-00 && apt-mark hold kubelet kubectl kubeadm
apt-get update && apt-get install -y --allow-change-held-packages kubelet=1.21.8-00 kubectl=1.21.8-00 kubeadm=1.21.8-00


//master node
kubeadm upgrade plan
kubeadm upgrade apply 1.23.3  ---!!很重要!!

sudo systemctl daemon-reload
sudo systemctl restart kubelet


apt-mark unhold kubelet kubectl kubeadm && apt-get update && apt-get install -y kubelet=1.22.5-00 kubectl=1.22.5-00 kubeadm=1.22.5-00 && apt-mark hold kubelet kubectl kubeadm
apt-get update && apt-get install -y --allow-change-held-packages kubelet=1.22.5-00 kubectl=1.22.5-00 kubeadm=1.22.5-00


kubeadm upgrade plan
kubeadm upgrade apply 1.22.5

sudo systemctl daemon-reload
sudo systemctl restart kubelet


apt-mark unhold kubelet kubectl kubeadm && apt-get update && apt-get install -y kubelet=1.23.1-00 kubectl=1.23.1-00 kubeadm=1.23.1-00 && apt-mark hold kubelet kubectl kubeadm

apt-get update && apt-get install -y --allow-change-held-packages kubelet=1.23.1-00 kubectl=1.23.1-00 kubeadm=1.23.1-00

sudo systemctl daemon-reload && systemctl restart kubelet



//client 
apt-mark unhold kubeadm && apt-get update && apt-get install -y kubeadm=1.23.3-00 && apt-mark hold kubeadm
apt-get update && apt-get install -y --allow-change-held-packages kubelet=1.23.3-00 kubectl=1.23.3-00 kubeadm=1.23.3-00 
sudo systemctl daemon-reload
sudo systemctl restart kubelet