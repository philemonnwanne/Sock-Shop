### After setting up the `EKS` cluster
Run the following command to retrieve the access credentials for your cluster and configure `kubectl`.

Use the kubectl command to connect to the EKS Cluster and control it
```bash
kubectl get nodes
```

## NoneType Error
If you come across the following error
`'NoneType' object is not iterable`

`Note:` If you already have a `~/.kube/config`, there could be a conflict between the file to be generated, and the file that already exists that prevents them from being merged.

If you have a `~/.kube/config` file, and you aren't actively using it, run the following to remove it

```bash
rm ~/.kube/config
```

Then run to fix the issue
```bash
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)
```

If successful you will get the following output.
```bash
Added new context arn:aws:eks:<aws-region>:<aws-accunt-id>:cluster/<cluster-name> to /Users/<your-user>/.kube/config
```

You can now use `kubectl` to manage your cluster and deploy Kubernetes configurations to it.

## Verify the Cluster

Use `kubectl` commands to verify your cluster configuration.

First, get information about the cluster.
```bash
kubectl cluster-info
```

You should get an output like below
```js
Kubernetes control plane is running at https://82F69692ACBBEE3DF2DC94BD9B64D6B0.gr7.us-east-1.eks.amazonaws.com
CoreDNS is running at https://82F69692ACBBEE3DF2DC94BD9B64D6B0.gr7.us-east-1.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use `kubectl cluster-info dump`.
```

`Note:` It takes approximately `3mins 5secs` for the whole stack to deploy and be `ready`

The `complete-demo.yml` deployment creates a `sock-shop` namespace

Commands to list all available namespaces
```bash
kubectl get ns

kubens
```
I prefer to use `kubens` as it shows the current active namespace

Switch to the `sock-shop` namespace
```bash
kubectl config set-context --current --namespace=sock-shop
```

Then you can show all your pods with
```bash
kubectl get pods
```

Notice that the Kubernetes control plane location matches the `cluster_endpoint` value from the `terraform apply` output above.

Now verify that all three worker nodes are part of the cluster.
```bash
kubectl get nodes
```

## Ingress
### Installing Ingress via Helm [Manually]

The actual ALB Ingress Controller (the Kubernetes resources such as Pod, ConfigMaps, etc.) can be installed with Helm — the Kubernetes package manager.

You should download and install the Helm binary. The instructions can be found on the official website.

You can verify that Helm was installed correctly with:

```bash
helm version
```
The output should contain the version number.

`Helm` is a tool that templates and deploys `YAML` in your `cluster`.

You can write the `YAML` yourself, or you can download a `package` written by someone else.

In this case, you want to install the collection of `YAML files` necessary to run the `ALB Ingress Controller`.

First, add the following repository to Helm:

```bash
helm repo add eks https://aws.github.io/eks-charts
```
Now you can download and install the ALB Ingress Controller in your cluster with:

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set autoDiscoverAwsRegion=true \
  --set autoDiscoverAwsVpcID=true \
  --set clusterName=<cluster-name>
```

Verify that the Ingress controller is running with:

```bash
kubectl get pods -l "app.kubernetes.io/name=aws-load-balancer-controller"
```
Excellent, you completed step 2 of the installation.

Now you're ready to use the Ingress manifest to route traffic to your app.

You can use the following Ingress manifest definition:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-kubernetes
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    kubernetes.io/ingress.class: alb
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: hello-kubernetes
            port:
              number: 80
```

Pay attention to the following fields:

 - `metadata.annotations.kubernetes.io/ingress.class` is used to select the right Ingress controller in the cluster.
- `metadata.annotations.kubernetes.io/alb.ingress.kubernetes.io/scheme` can be configured to use `internal` or `public-facing` load balancers.

You can explore the full list of annotations here.

You can submit the Ingress manifest to your cluster with:

```bash
kubectl apply -f ingress.yml
```

`Note:` Use command to delete all deployments/pods/services

```bash
kubectl delete --all deployments --namespace=sock-shop \
kubectl -n <namespace> delete pod,svc --all  
```