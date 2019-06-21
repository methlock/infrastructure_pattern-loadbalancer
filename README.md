# Infrastructure design pattern with loadbalancer, service and database.

Scheme of microservice is following:
```
+--------+                                  +------------------+
| User 1 | <--+                        +--> | Service server 1 | <--+
+--------+    |    +--------------+    |    +------------------+    |    +----+
              +--> | LoadBalancer | <--+                            +--> | DB |
+--------+    |    +--------------+    |    +------------------+    |    +----+
| User 2 | <--+                        +--> | Service server 2 | <--+
+--------+                                  +------------------+

                                                    ...
```


What is going on
-

The service contains API and MySQL model. There are three endpoints:

- **/** - contain information about container id
- **/newTask** - create new task and return its id, task is processed in background
- **/tasks** - list of all tasks, you can check status here

The whole service is duplicated behind LoadBalancer.


Prequisities
-
- Terraform
- DigitalOcean account


Setup
-
Just go to `/terraform` folder and fill `terraform.tfvars`, then do these commands:
```bash
terraform init     # setup terraform plugins
terraform plan     # preview the changes to infrastructure
terraform apply    # build infrastructure
terraform destroy  # when you've seen enough
```
