resource "aws_iam_role" "codebuild" {
  name = "tf_codebuild_${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codebuild_packer" {
  name = "tf_codebuild_packer_${var.name}"
  path = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeypair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeypair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name = "tf_policy_attachment_codebuild_packer_${var.name}"
  policy_arn = "${aws_iam_policy.codebuild_packer.arn}"
  roles = ["${aws_iam_role.codebuild.id}"]
}


resource "aws_codebuild_project" "packer" {
  name = "${var.name}"
  description = "${var.description}"
  build_timeout  = "${var.timeout}"
  service_role = "${aws_iam_role.codebuild.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "${var.compute_type}"
    image = "${var.image}"
    type = "LINUX_CONTAINER"

    environment_variable {
      "name" = "PACKER_AMI_NAME"
      "value" = "${var.packer_ami_name}"
    }

    environment_variable {
      "name" = "PACKER_VPC"
      "value" = "${var.packer_vpc}"
    }

    environment_variable {
      "name" = "PACKER_VPC_SUBNET"
      "value" = "${var.packer_subnet}"
    }

    environment_variable {
      "name" = "PACKER_SOURCE_AMI_NAME"
      "value" = "${var.packer_source_ami}"
    }

    environment_variable {
      "name" = "PACKER_SOURCE_AMI_OWNER"
      "value" = "${var.packer_source_ami_owner}"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "${var.buildspec}"
  }
}
