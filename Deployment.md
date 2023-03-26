![CircleCI](https://img.shields.io/circleci/build/github/philemonnwanne/capstone)

# Infra Deployment Procedure
- Deploying with terraform :shipit:
- Deploying with circleci [click-here](#deploying-with-cicd-circleci-checkout-the-following-articles)

## Pre-requisites

- Install AWS CLI
- Install Terraform
- Install Vault

### Setup AWS credentials
Using any credential manager of your choice, you can setup your AWS credentials, for my use case I will be using Hashicorp's `Vault`.
You can also export them as environment variables.

### Clone the project repo from github
```
git clone https://github.com/philemonnwanne/capstone
```

Move into the terraform directory
```bash
cd capstone/terraform
```

Initialize Terraform
```bash
terraform init
```

Validate and Plan terraform
```bash
terraform validate \
terraform plan
```

`Note` If you used `vault`, you will be prompted to enter the vault url, in this case it is `http://127.0.0.1:8200/`

Deploy infrastructure
```bash
terraform apply -auto-approve
```

It takes about 14mins(+/-) to deploy the entire infrastructure on `AWS`

Once your terraform apply command runs successfully, run the following command to retrieve the access credentials for your cluster and configure `kubectl`.

Update `kubeconfig`
```ruby
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)
```

<!-- 
Use the kubectl command to connect to the EKS Cluster and control it
```bash
kubectl get nodes
```

```ruby
aws eks describe-cluster --region $(terraform output -raw region) --name $(terraform output -raw cluster_name) --query "cluster.status"
```
 -->

`Note` The above command will only work if you defined outputs variables for the various outputs. In my case I did not define the `region` output variable, so it won't work.

If successful you will get the following output.
```bash
Added new context arn:aws:eks:<aws-region>:<aws-accunt-id>:cluster/<cluster-name> to /Users/<your-user>/.kube/config
```

You can now use `kubectl` to manage your cluster and deploy Kubernetes configurations to it.

### Verify the Cluster Status

Use `kubectl` commands to verify your cluster configuration.

First, get information about the cluster.
```bash
kubectl cluster-info
```

You should get an output like below
```js
Kubernetes control plane is running at https://82F69692ACBBEE3DF2DC94BD9B64D6B0.gr7.us-east-1.eks.amazonaws.com
CoreDNS is running at https://82F69692ACBBEE3DF2DC94BD9B64D6B0.gr7.us-east-1.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use `kubectl cluster-info dump`
```

Notice that the Kubernetes control plane location matches the `cluster_endpoint` value from the `terraform apply` output earlier.


### Deploy the Sock-Shop microservice

```bash
kubectl apply -f complete-demo.yml
```

`Note:` It takes approximately `3mins(+/-)` for the whole stack to deploy and be `ready`

The `complete-demo.yml` deployment creates a `sock-shop` namespace automatically

Show all available namespaces
```bash
kubectl get ns

kubens
```

`Note`: I prefer to use `kubens` as it highlights the active `namespace`

Switch to the `sock-shop` namespace
```bash
kubectl config set-context --current --namespace=sock-shop
```

Then you can show all your pods with
```bash
kubectl get pods
```

Now verify that all three worker nodes are part of the cluster
```bash
kubectl get nodes
```

### Install Ingress

```bash
kubectl apply -f ingress.yml
```

Verify that the Ingress controller is running

```bash
kubectl get pods -l "app.kubernetes.io/name=aws-load-balancer-controller"
```

Now your deployments should be exposed by an application load balancer


If you are happy with the deployment , you can tear down the deployed resources

```bash
terraform apply -auto-approve -destroy
```

🥳 Congratulations you have successfully deployed IAC with `Terraform/Vault`

### Useful Commands

Delete all deployments/pods/services
```bash
kubectl delete --all deployments --namespace=sock-shop \
kubectl -n <namespace> delete pod,svc --all  
```

### Possible Errors

##### NoneType [Error]

If you come across the following error
```ruby
`'NoneType' object is not iterable`
```

`Note:` This could be becuse you already have an existing kubeconfig file in `~/.kube/config`, there could be a conflict between the file to be generated.

If you have a `~/.kube/config` file, and you aren't actively using it, run the following to remove it which should fix the error.

```bash
rm ~/.kube/config
```


## Deploying with ci/cd (circleci) checkout the following articles
[Terraform-docs](https://developer.hashicorp.com/terraform/tutorials/automation/circle-ci)

[Terraform-blog](https://circleci.com/blog/an-intro-to-infrastructure-as-code/)
 

`Note`

The default terraform `path varible` won't work in `circleci` 
```ruby
Valid : policy = file("${path.cwd}/iam-policy.json")
Invalid : policy = file("./iam-policy.json")
```
