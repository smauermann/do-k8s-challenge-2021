[![Terraform](https://github.com/neurotronix/do-k8s-challenge-2021/actions/workflows/terraform.yaml/badge.svg)](https://github.com/neurotronix/do-k8s-challenge-2021/actions/workflows/terraform.yaml)
[![App](https://github.com/neurotronix/do-k8s-challenge-2021/actions/workflows/app.yaml/badge.svg)](https://github.com/neurotronix/do-k8s-challenge-2021/actions/workflows/app.yaml)
# DigitalOcean Kubernetes Challenge 2021
## The Task
> **Deploy a scalable message queue**
> A critical component of all the scalable architectures are message queues used to store and
> distribute messages to multiple parties and introduce buffering. Kafka is widely used in
> this space and there are multiple operators like Strimzi or to deploy it. For this project,
> use a sample app to demonstrate how your message queue works.

## Infrastructure
The Kubernetes Cluster, Kafka Cluster ([Strimzi](https://strimzi.io)) and Container Registry are provisioned via [Terraform Cloud](https://app.terraform.io).

A simple Terraform validation CI is implemented in GitHub actions.

## Sample App
A producer and a consumer sample Golang app publish and receive messages to and from the message queue deployed above. The clients are based on the Confluent Kafka [library](https://github.com/confluentinc/confluent-kafka-go) and are more or less the verbatim copies of the provided examples.

Again, we use GitHub Actions as CI system. Basic validation (e.g. `go build`) is run on Pull Requests as well as integration tests using Docker Compose. Releases are being created upon merging to `main`. Which in turn triggers deployment workflows for the consumer and producer apps. Those build Docker images, publish those to a Container Registry as well as update and apply the respective Kubernetes manifests.

## Bootstrap
0. Clone the repo.
1. Setup a Terraform (TF) Cloud account. TF Cloud is free for individuals and highly recommended to set up. It offers remote state storage and a TF execution environment. You can chose to use the remote state storage alone without running TF commands in the cloud.
2. Install [`doctl`](https://docs.digitalocean.com/reference/doctl/how-to/install/), the DigitalOcean CLI tool. With this we can easily obtain the kubeconfig for our Kubernetes cluster.

### Infrastructure
1. Modify the Terraform (TF) Cloud organisation in `infra/providers.tf`. Your org will likely have a different name than mine.
2. Define deployment parameters either via an `terraform.auto.tfvars` file or on the TF Cloud web UI. 
<details>
<summary>Here is an example.</summary>
<p>

```hcl
#### k8s-cluster
project   = "do-k8s-challenge-2021"
vpc_range = "10.0.0.0/24"
region    = "fra1"
node_pool = {
  size       = "s-2vcpu-2gb-amd"
  auto_scale = false
  node_count = 3
}

### strimzi-kafka
strimzi_version = "0.26.0"
namespace       = "kafka"
cluster = {
  kafka = {
    name         = "kafka-cluster"
    replicas     = 2
    storage      = 10
    delete_claim = true
  }
  zookeeper = {
    replicas     = 2
    storage      = 10
    delete_claim = true
  }
}
topic = {
  name       = "kafka-topic"
  partitions = 3
  replicas   = 1
}
```

</p>
</details>  

3. Depending on your TF Cloud configuration, `terraform plan` and `terraform apply` runs can either be triggered from GitHub webhooks or locally.
4. Apply the TF specs to create Kubernetes Cluster, Kafka Cluster and Container Registry. Unfortunately, we need to target resources when creating our infra. This is due to `kubernetes_manifest` requiring a valid kubeconfig, which of course cannot exist before the Kubernetes cluster has been created. So apply as follows:
```shell
cd infra && \
terraform apply -target=module.k8s && \
terraform apply -target=module.kafka.module.operator && \
terraform apply
```
5. Destroying the infrastructure works in one go:
```shell
cd infra && terraform destroy
```
  - If there is no default VPC in the region, the created VPC will become the default VPC
  - In which case the `destroy` operation will fail as default VPCs cannot be deleted, create a new VPC and make it the default VPC to be able to manage the VPC via Terraform
  - For some reason the VPC deletion will fail right after the Kubernetes Cluster deletion with the error `Can not delete VPC with members`
  - A targeted destroy a few seconds will delete the VPC however: `terraform destroy -target=module.k8s.digitalocean_vpc.this`

### Sample App
1. The app deployment is fully automated and triggered by successful release workflows. Shout out to Othmane's [post](https://dev.to/othpwn/how-to-deploy-an-api-to-a-kubernetes-cluster-with-a-github-actions-ci-cd-workflow-km).
2. In order to deploy the apps using CI/CD, open a pull request and merge it to main. This will trigger the deployment workflows. You can now sit back and relax and watch GitHub do the rest.
  - You could simply change the message the producer is going to send to the Kafka queue.
3. To manually deploy the apps:
  - Build and push the Docker images to the Container Registry
  - Modify the app manifests to use the image tags used in the previous step
  - Apply the manifests via `kubectl apply`
4. Verify the deployment by inspecting the consumer app's logs:
```shell
$ kubectl logs -n <namespace> kafka-consumer-<id>
Message on kafka-topic[0]@4744: Challenge
Message on kafka-topic[0]@4745: 2021
Message on kafka-topic[2]@4073: DigitalOcean
Message on kafka-topic[2]@4074: Kubernetes
```

## Open Issues
- Apps are deployed on every release, even if only infrastructure parts have changed
- The release workflow does neither update the version in `package.json` nor creates/updates a `CHANGELOG.md` file
- Change detection does not work for integration job (it always runs)
- The `kubernetes_manifest` resources of the TF Kubernetes provider require an existing kubeconfig, this makes it impossible to create the Kubernetes cluster and CRDs in one go
  - In other words, Kubernetes cluster and Kubernetes Manifest resources cannot be created in the same Terraform run
