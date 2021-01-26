# Blog Post
Run each of the commands in order

cp teamplate.localvars localvars

000-prereq.sh - prereq check and local.env check

010-container-registry.sh - optionally create an ibm cloud container registry namespace to hold
Container images can come from public registries (hub.docker.com) or from the ibm container registry.  A VPC public gateway is required to connect to a public registry.  The ibm container registry in this example is in the same region as the the kubernetes cluster and accessed over a regional ip address.


020-create-resources.sh to install the following
- kubernetes cluster - see commments in terraform/cluster.tf to reuse an existing cluster
- COS storage classes - see terraform/cos_storage_class.tf to use existing storage classes supporting authorized IPs
- COS instance
- kubernetes secrets to access the COS instance
- pvc - COS bucket to be automatically created on first use and initialized with authorized IP access for the vpc of cluster
- deployment for nginx with pod spec for the bucket
- service for the deployment
- ingress for the service
- jekyllblog - optional, pvc to hold the contents of a jekyll blog static website generator
- jekyllnginx - optionalk, uses the jekyllblog pvc to host the static web site with nginx

030-test.sh
- checks the results expected from nginx deployment
- displays the url for the jekyll blog and jekyll nginx deployments

040-clean-up.sh - clean up stuff from previous steps
- all stuff in 020-create-resource
- container registry namespace

