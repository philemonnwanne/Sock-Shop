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

The `complete-demo.yml` deployment creates a `sock-shop` namespace

Commands to list all available namespaces
```bash
kubectl get ns

kubens
```

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

