# Web Server, lookup on ami.tf

data "template_file" "webserver-userdata" {
  template = "${file("webserver-user_data.tpl")}"
}

resource "aws_instance" "web-01" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.WEBSRV_INSTANCE_TYPE}"
  key_name = "${var.KEYPAIR}"
  subnet_id = "${aws_subnet.public-1.id}"
  vpc_security_group_ids = [
    "${aws_security_group.sg-ssh}",
    "${aws_security_group.sg-alb}",
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "10"
  }
  user_data = "${data.template_file.webserver-userdata.rendered}"
  monitoring = true
  tags {
    Name = "${local.project_name}-web-01"
  }
}

resource "aws_instance" "app-01" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.WEBSRV_INSTANCE_TYPE}"
  key_name = "${var.KEYPAIR}"
  subnet_id = "${aws_subnet.private-1.id}"
  vpc_security_group_ids = [
    "${aws_security_group.sg-ssh}",
    "${aws_security_group.sg-alb}",
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "10"
  }
  user_data = "${data.template_file.webserver-userdata.rendered}"
  monitoring = true
  tags {
    Name = "${local.project_name}-app-01"
  }
}



