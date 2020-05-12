## Metabase on AWS

---

Example [Metabase](https://www.metabase.com/) deployment on aws ecs Fargate. The idea is to provision 
a standard aws VPC, have Metabase monitored &logged via CloudWatch, provide an autoscaling group should there 
be an increase in users. In order to access the reporting databases and other data-warehousing
technologies a [VPC peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html) connection
between the newly created and existing VPC's is a good solution or alternately launch the stack in an already existing
VPC and Subnets (terraform import < resources>).   

### Description of resources:
- We provision an application [load balancer](alb.tf), which listen to http requests on ports 80 and 443,
port 80 requests will be redirected to 443, and will assign it an [acm](acm.tf) (ssl) certificate so that all
all connections are HTTPS.
- From the load balancer our requests will be redirected (via target group) to our application service (metabase)
container. 
- The ECS cluster is [defined](main.tf) from top to bottom as following: 
ECS Cluster -> ECS service -> ECS task definition. The service depends on a task defintion, a task definition
can be compared to `docker run` command, whereas the service resource resembles `docker-compose` command which
takes care of networking ([security groups](security.tf)), number of instances (the service level), in our case also the association
with our load balancer target group.

- The ECS task describes a single container instance, such as which image should be used, the aws Fargate cpu and memory
size, port mappings, commands/entrypoints, log groups, health checks, etc.   

- [network.tf](network.tf) -> VPC, private and public subnets, internet gateway,
nat gateway, elastic ip, route tables and routes 
- [aws cloud watch log group](logs.tf) defines the log group where the application logs will be stored
- 

#### Prerequsites:
- aws route53 zone, which will be pulled by data.aws_route53_zone and used by the acm resource 
for certificate creation

#### To deploy first run:
- ` terraform apply -target=aws_ecr_repository.metabase`
then run `./cli.sh` in order to build and push the current Metabase docker image to the ECR repository
and finally run `terraform apply` to provision the rest of resources.
- a finally go to your Metabase public address (terraform output alb_public_dns) 


TODO's:
 - Move task definiton to [template file](templates/metabase.json) 
 - Move the ECR image build/push to local-exec provisioner 
 - Add postgresql RDS as database backend for Metabase
 - Autoscaling Group based on container CPU utilisation so more worload/users 
 is reflected by the number of instances 


