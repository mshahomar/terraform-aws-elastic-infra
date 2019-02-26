# Terraform - Provider: AWS

## Elastic Infrastructure for AP-SouthEast-1

### Usage
Before running this terraform file, ensure that you have upload *public key* to AWS EC2 by using the following command:

<pre>
keyname="name_of_keypair"

publickeyfile="$HOME/.ssh/name_of_the_public_key_file_in_this_dir.pub"

aws ec2 import-key-pair --region ap-southeast-1 --key-name "$keyname" --public-key-material "file://$publickeyfile"
</pre>

Then, run terraform command:

<pre>
terraform validate
terraform plan
terraform apply
</pre>