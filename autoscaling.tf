# Launch Configuration
resource "aws_launch_configuration" "launch-config" {
  name_prefix = "${local.project_name}-lc-"
  image_id = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.WEBSRV_INSTANCE_TYPE}"
  lifecycle {
    create_before_destroy = true
  }
  key_name = "${var.KEYPAIR}"
  security_groups = [
    "${aws_security_group.sg-alb.id}", "${aws_security_group.sg-ssh.id}"
  ]

}

resource "aws_autoscaling_group" "autoscale" {
  name                      = "${local.project_name}-ASG"
  max_size                  = 6
  min_size                  = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = ["${aws_subnet.public-1.id}", "${aws_subnet.public-2.id}", "${aws_subnet.public-3.id}"]
  launch_configuration      = "${aws_launch_configuration.launch-config.name}"
  force_delete              = true

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${local.project_name}-autoscaled"
  }
}

# Auto-Scaling Policy: 'scaleup' for high CPU, 'scaledown' for low CPU
resource "aws_autoscaling_policy" "asg-pol-cpu-scaleup" {
  autoscaling_group_name = "${aws_autoscaling_group.autoscale.name}"
  name                   = "${local.project_name}-asg-pol-cpu-scaleup"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "asg-pol-cpu-scaledown" {
  autoscaling_group_name = "${aws_autoscaling_group.autoscale.name}"
  name                   = "${local.project_name}-asg-pol-cpu-scaledown"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "cw-alarm-cpu-high" {
  alarm_name          = "${local.project_name}-cw-cpu-high"
  alarm_description   = "Alarm for high CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.autoscale.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.asg-pol-cpu-scaleup.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "cw-alarm-cpu-low" {
  alarm_name          = "${local.project_name}-cw-cpu-low"
  alarm_description   = "Alarm for low CPU"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.autoscale.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.asg-pol-cpu-scaledown.arn}"]
}

# SNS: Send notification when alarm triggered
resource "aws_sns_topic" "cpu-high-sns" {
  name         = "${local.project_name}-cpu-sns"
  display_name = "${local.project_name}-cpu-sns"
}

resource "aws_autoscaling_notification" "asg-notification" {
  group_names = ["${aws_autoscaling_group.autoscale.name}"]
  topic_arn   = "${aws_sns_topic.cpu-high-sns.arn}"

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
  ]
}

