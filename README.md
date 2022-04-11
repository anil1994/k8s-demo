
 ## Bootstrap Kubernetes with k3s over SSH < 1 min 🚀

k3s is a highly available and certified Kubernetes distribution designed with simplicity at its core. It is packaged as a single < 40MB binary that reduces the dependencies and time to set up a production-ready cluster. With a simple command, you can have a cluster ready in under approximately 30 seconds. 

You can see my k3s bootstraping and CI/CD architecture draft  as following.


There are some components of k3s.

* SQLite replaces etcd as the database.
* Traefik is the default Ingress Controller.
* ServiceLB is default LoadBalancer
* Local-Path provisioner is default also as shown below.

$  kubectl get storageclass  --kubeconfig=kubeconfig

```
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  3h9m

```

![This is an image](https://github.com/anil1994/k8s-demo/blob/main/IAC-GCP%20Diagram.drawio.png)

## Requirements for Bootstraping k3s on GCP

1- k3sup is a lightweight utility to get from zero to production-ready cluster with k3s on any local or remote VM. All you need is ssh access and the k3sup binary. 
 ```
 $ curl -sLS https://get.k3sup.dev | sh
 ```
2- Download gcloud cli to authenticate GCP

k3sup requires an SSH key to access to a VM instance to do its job, we need to generate an SSH key and save the configuration into an SSH config file (~/.ssh/config).
```
$ gcloud compute config-ssh

```
By default, the SSH key is generated in ~/.ssh/google_compute_engine.

3- After this operation, we need to install terragrunt and terraform like as following

Terragrunt Installation:
  ```           
  $ wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.35.16/terragrunt_linux_amd64  
  $ mv terragrunt_linux_amd64 terragrunt 
  $ chmod u+x terragrunt
  $ sudo mv terragrunt /usr/local/bin/terragrunt 
  ```
 Terraform Installation:
  ```
  $ sudo wget https://releases.hashicorp.com/terraform/0.12.2/terraform_0.12.2_linux_amd64.zip 
  $ sudo unzip terraform_0.12.2_linux_amd64.zip && sudo mv terraform /usr/local/bin/terraform
  ```      
  Helm Cli Installation:
   ```
   $  sudo curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash 
   ```      
  Kubectl Cli Installation:
  ```
     $ sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
     $ sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl 
  ```
## Terragrunt
  
   Terragrunt is a thin wrapper that provides extra tools for keeping your configurations DRY, working with multiple Terraform modules, and managing remote state.  Our backend and provider configuration is on the root section defined terragrunt.hcl which is so clean and dry by means of terragrunt.
   
   Also, remote state is protected  on the google cloud bucket defined terragrunt.hcl on the root section.
   
   Terragrunt is also so significant to manage many environment such as prod,dev,qa,stg together so easily.

You can see our terragrunt codes and structure on my terragrunt-iac folder. I seperated master node configuration from worker and infra section.

Bootstrap K3S Cluster:
 ```
 $  cd terragrunt-iac/dev &&  terragrunt run-all apply  --terragrunt-non-interactive
```
## Install Jenkins

```
 $ helm upgrade  -i  jenkins  jenkins/jenkins -n jenkins  --set serviceType=NodePort
``` 
  We can reach from internet to jenkins UI  by using http://104.199.57.196:32114/job/mvn-demo/ URL.
```  
  $ helm list -n jenkins
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
jenkins jenkins         3               2022-04-09 21:05:38.276617889 +0000 UTC deployed        jenkins-3.11.10 2.332.2  
```

In order to handle persistent volume issue, I used Local-Path provisioner that come from k3s as default.
``` 
$ kubectl get pv -n jenkins
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                       STORAGECLASS   REASON   AGE
pvc-e15ac343-c871-4d79-87ec-82bb77c3813b   8Gi        RWO            Delete           Bound    jenkins/jenkins                             local-path              27h
``` 
## Jenkins Slave

I used jumpbox vm server on Google Cloud for Jenkins Slave. 
I installed docker,java,maven on it for managing maven build. 

## Install Nexus

I utilized https://artifacthub.io/packages/helm/sonatype/nexus-repository-manager this url for installing nexus.
```
$ helm upgrade -i  nexus  sonatype/nexus-repository-manager --version 38.1.0 --set ingress.enabled=false  --set service.type=NodePort -n nexus
```
```
$ helm list -n nexus
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
nexus   nexus           1               2022-04-10 12:27:27.331443909 +0000 UTC deployed        nexus-repository-manager-38.1.0 3.38.1     
```

http://104.199.57.196:31582 //nexus UI reachable from internet for demo purpose


In order to handle persistent volume issue, I used Local-Path provisioner that come from k3s as default.
```
$ kubectl get pv -n nexus
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                       STORAGECLASS   REASON   AGE
pvc-6d29c9e8-f7e5-4df2-83b1-8b284651e6d9   4G         RWO            Delete           Bound    nexus/nexus-nexus-repository-manager-data   local-path              9h
```

## Junit 

Junit is used for unit testing. I added test stage to jenkinsfile. You can easily see test result graph on jenkins job UI. There is junit plugin on my jenkins server. 

## Helm deploy
I added helm manifests as well to this github repository.
```
$ helm upgrade -i mvn-app helm-manifests/ --set image.tag=$BUILD_NUMBER'
```
```

$ helm list
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
mvn-app default         2               2022-04-10 21:19:41.621831468 +0000 UTC deployed        mvn-app-0.0.1   1.15.1 
```
```
$ kubectl logs mvn-chart-5967dd6d49-hr4ds
Hello World!
```



## CICD
I used jenkins for CI/CD pipeline in order to build our mvn  docker application and deploy helm chart deployment to k3s . it is so easy to integrate with CI/CD by using jenkins. There are many jenkins plugins that can integrate with so many places. 
