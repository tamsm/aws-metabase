# Metabase on AWS

Example [Metabase](https://www.metabase.com/) deployment on aws ecs Fargate. The idea is to provision 
a standard aws VPC, have Metabase monitored &logged via CloudWatch, provide an autoscaling group should there 
be an increase in users. In order to access the reporting databases and other data-warehousing
technologies a [VPC peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html) connection
between the newly created and existing VPC's is a good solution or alternately launch the stack in an already existing
VPC and Subnets (terraform import < resources>).   

TODO's:
 - Add postgresql RDS 
 - Add ACM SSL certificate and route all traffic via 443
 - Autoscaling Group


