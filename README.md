# iac-terraform-workshop

The following repo contains the source code for a brief workshop to learn how to provision and manage
your infrastructure with terraform. If you find it useful feel free to use it.

### Prerequisites

In order to be able to run these examples please be aware that you need a proper aws account and have terraform
installed (v. 0.11 or higher).

### Usage
Each commit in the repo is a different step towards having an overall basic knowledge of terraform features. The 
instructions here will detailed what you need at each commit or step. 

#### Adding a VPC
In this step we just set up a basic vpc in order to run a basic plan and apply it. In order to 
be able to apply to run this step either:
- Create `TF-VAR-access_key` and `TF-VAR-secret_key` environmental variables and populate them with your
aws credentials
- Add the variables in the terraform command, e.g.: 
```
$> terraform apply -var 'access_key = <aws access key>' -var 'secret_key = <aws secret key>'
```
- Or create a file called `terraform.tfvars` and populate with the following code: 
```
access_key = <aws access key>
secret_key = <aws secret key>
```

Also if you want to modify the default values just check out the file `test.tfvars` and modify it.

### Adding a public subnet
In this step we are going to simply add a public subnet. Besides that there are a couple of new variables that can be
modified. Have a look at the `test.tfvars` and `input.tf`.

### Adding the service
In this step we are going to deploy the service that's going to be accessible. To do so, we also 
are going to create an auto scaling group and run all traffic through an ELB. As in the previous
step we are adding a couple of variables to configure these new resources. Have a look at the 
`test.tfvars` and `input.tf`.

### Refactoring into modules
In this step we are going to refactor and introduce a modules. Have a look at the different modules inside
of the modules directory. 
Also you will be required to do a `terraform init` so that terraform can initialize the modules dependencies.


### Workspaces and backing up the terraform state

In this step a good a idea would be to destroy your previous provisioned infrastructure and start from scratch.

After that, change directories and initialize the workspace or directory under `bucket` by running 
`terraform init`, and as in the initial stage, add a `terraform.tfvars` with your aws secret and access keys, 
and provision this infrastructure by applying it.

This will create a s3 bucket that will be used to hold the terraform state of the infrastructure we built before.
Also pay attention to the definition of that s3 bucket. In a real situation you should set the `prevent_destroy` to `true`,
because you don't want this bucket to be destroyed. This bucket will be used for the next part to store 
the terraform state, allowing multiple users or even your pipeline to have access to the latest terraform state.

Afterwards, if you look at the repository there are two new `tfvars` files. One for a test environment and other one for
a prod environment. This is a simple way to manage different environment configurations. But remember
terraform by default creates a default workspace, and each workspace manages its own state. So if you want
to manage multiple environment without destroying or affecting them, you should create a workspace, and in each workspace
you will be able to manage the state for that environment. For doing so, before applying any infrastructure change,
please execute the following commands: 
```bash
$> terraform workspace create test
$> terraform workspace create prod
```
After this, you should be able to switch between workspace by executing the following commands:
```bash
$> terraform workspace select <name of the workspace>
```
Now if you want to provision the test environment you could do the following
```bash
$> terraform workspace select test 
$> terraform apply -var-file=test.tfvars
```
Remember to switch to prod environment before apply it and use the `prod.tfvars` as the input `var-file`



