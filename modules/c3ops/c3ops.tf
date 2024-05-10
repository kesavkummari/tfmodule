data "aws_vpc" "selected_vpc" {
  id = "${var.c3ops_vpc_id}"
}

data "aws_subnet" "selected_public_subnets" {
  id = "${element(var.c3ops_public_subnets,count.index)}"
  count = 2
}

data "aws_subnet" "selected_private_subnets" {
  id = "${element(var.c3ops_private_subnets,count.index)}"
  count = 2
}

# data "aws_subnet" "selected_data_subnets" {
#   id = "${element(var.c3ops_data_subnets,count.index)}"
#   count = 3
# }

resource "aws_iam_instance_profile" "c3ops_profile" {
  name = "${var.c3ops_resource_name_prepend}-${var.c3ops_environment}"
  role = "${aws_iam_role.c3ops_role.name}"
}

resource "aws_iam_role" "c3ops_role" {
  name = "${var.c3ops_resource_name_prepend}-${var.c3ops_environment}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com","ssm.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "c3ops_ec2_ssm_policy_attachment" {
    role       = "${aws_iam_role.c3ops_role.name}"
    policy_arn = "${var.ec2_policy_for_ssm}"
}


 
//INSTANCES

//mealvoucher APP

resource "aws_instance" "c3ops_app" {
  lifecycle {
    ignore_changes = [ebs_block_device, tags, vpc_security_group_ids]
  }

  ami           = "${var.c3ops_app_ami}"
  instance_type = "${var.c3ops_app_instance_size}"
  key_name      = "${var.c3ops_key_name}"
  subnet_id     = "${data.aws_subnet.selected_private_subnets.0.id}"

  vpc_security_group_ids = [
    "${aws_security_group.c3ops_app_sg.id}",
    "${var.c3ops_admin_linux_sg_id}"
  ]

  iam_instance_profile        = "${aws_iam_instance_profile.c3ops_profile.name}"
  associate_public_ip_address = false

  root_block_device {
    volume_size = "${var.c3ops_root_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  # tags = "${merge(var.c3ops_additional_tags,var.c3ops_module_tags,
  #           map("Name","${var.c3ops_resource_name_prepend}-${var.c3ops_environment}-app"),
  #           map("Backup","true"),
  #           map("Job","App")
  #         )}"
  tags = tomap(
  merge(
    var.c3ops_additional_tags,
    var.c3ops_module_tags,
    {
      Name = "${var.c3ops_resource_name_prepend}-${var.c3ops_environment}-app"
    }
  )
)

}

//Security Groups

 //SG Instance app

resource "aws_security_group" "c3ops_app_sg" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "${var.c3ops_resource_name_prepend}-${var.c3ops_environment}-app-"
  description = "${var.c3ops_resource_name_prepend} Security Group."
  vpc_id      = "${data.aws_vpc.selected_vpc.id}"

  # tags = "${merge(var.c3ops_additional_tags,var.c3ops_module_tags,map("Name","${var.c3ops_resource_name_prepend}-${var.c3ops_environment}-app"))}"
tags = tomap(
  merge(
    var.c3ops_additional_tags,
    var.c3ops_module_tags,
    {
      Name = "${var.c3ops_resource_name_prepend}-${var.c3ops_environment}-app"
    }
  )
)


}


resource "aws_security_group_rule" "c3ops_sg_rule_app_outgoing" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.c3ops_app_sg.id}"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

 
//Cloudwatch

resource "aws_cloudwatch_metric_alarm" "c3ops_app_cloudwatch_recovery" {
  alarm_name                = "${var.c3ops_environment}-mealvoucher-app-status-check-failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Maximum"
  threshold                 = "1"
  alarm_description         = "This metric monitors ec2 status check"
  insufficient_data_actions = []
  alarm_actions = [
    "arn:aws:automate:us-east-1:ec2:recover"
  ]
  dimensions = {
    InstanceId = "${aws_instance.c3ops_app.id}"
  }
}