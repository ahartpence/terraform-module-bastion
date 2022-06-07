# terraform-module-bastion
Create a bastion after bootstrapping vpc


Inputs - Required:

 - `aws_region` - AWS Region
 - `aws_key_name` - Name of EC2 Keypair
 - `aws_key_file` - Location of the private EC2 Keypair file
 - `vpc_security_group_ids` -  Array of DMZ Security Groups to use
 - `subnet_id` - DMZ Subnet ID


Inputs - Optional: 

 - None

Outputs:

 - `box-bastion-public` - IP address of the bastion
