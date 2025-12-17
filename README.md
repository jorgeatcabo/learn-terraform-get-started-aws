# Task 1
For this task, you will install Terraform, create a Terraform minimal viable product (MVP), and execute Terraform commands.
Task:

1. Install Terraform to your control machine (your laptop).
2. Create a folder for your Terraform project and put the main.tf file in it.
3. Add information to the main.tf file about your cloud provider, Amazon AWS.
4. Generate an AWS_ACCESS_KEY and an AWS_SECRET_KEY in your Amazon AWS account.
5. Add Amazon AWS credentials to the main.tf file or environment variables.
6. Initialize and apply the current version of your Terraform project.

# Task 2
For this task, you will create your first resource in AWS—VPC.
Task:

1. Find an appropriate Terraform module in the Terraform Registry.
2. Add a block of code into the main.tf file that configures VPC based on the module from the Terraform Registry.
3. Check the execution plan.
4. Apply the changes.

# Task 3
For this task, you will create a virtual machine (EC2 instance) in AWS.
Task:

1. Add the necessary blocks of code into file main.tf file to create two EC2 instances. Use the built-in function "count."
2. Check the execution plan.
3. Apply the changes.

# Task 4
For this task, you will create a load balancer in AWS.
Task:

1. Add the necessary blocks of code to the main.tf file to create a classic load balancer in Amazon AWS. The load balancer should distribute traffic across your two EC2 instances.
2. Check the execution plan.
3. Apply the changes.
