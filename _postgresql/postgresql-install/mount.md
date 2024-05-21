
## 正常情況
![](https://hackmd.io/_uploads/SyXRPpxn3.png)

## 錯誤情況 
執行ps auxw | grep postgresql 只出現
![](https://hackmd.io/_uploads/BycDOax23.png)



## 確認 lsblk 


https://docs.aws.amazon.com/zh_tw/AWSEC2/latest/UserGuide/ebs-using-volumes.html

![](https://hackmd.io/_uploads/BkR-K6x32.png)

## 確認 dh -H
![](https://hackmd.io/_uploads/Sye5mYpe23.png)

沒有掛載 nvme1n1

## 執行 mount /dev/nvme1n1 /var/lib/postgresql 

## 執行 service postgresql restart

## fstab 加上下面這一段
/dev/nvme1n1      /var/lib/postgresql     xfs     errors=remount-ro       0 1
