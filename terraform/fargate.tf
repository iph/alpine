
resource "aws_ecs_cluster" "main" {
  name = "${var.tag}-frontend"
}


# allow role to be assumed by ecs and local saml users (for development)
data "aws_iam_policy_document" "app_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# creates an application role that the container/task runs as
resource "aws_iam_role" "app_role" {
  name               = "${var.tag}-fargate-app-role"
  assume_role_policy = "${data.aws_iam_policy_document.app_role_assume_role_policy.json}"
}

# assigns the app policy
resource "aws_iam_role_policy" "app_policy" {
  name   = "${var.tag}-app-role-policy"
  role   = "${aws_iam_role.app_role.id}"
  policy = "${data.aws_iam_policy_document.app_policy.json}"
}

data "aws_iam_policy_document" "app_policy" {
  statement {
    actions = [
      "ecs:DescribeClusters",
      "logs:*"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.fargate_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role" "fargate_role" {
  name               = "${var.tag}-fargate-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "fargate-permissions" {
  role = "${aws_iam_role.fargate_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_ecs_task_definition" "app" {
  family                   = "app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  task_role_arn            = "${aws_iam_role.app_role.arn}"
  execution_role_arn       = "${aws_iam_role.fargate_role.arn}"
  container_definitions    = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image}",
    "memory": ${var.fargate_memory},
    "name": "app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${var.tag}-app",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "main" {
  name = "${var.tag}-service"
  cluster = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count = "${var.app_count}"
  launch_type = "FARGATE"
  network_configuration {
    security_groups = ["${module.vpc.sg-alb-to-fe}"]
    subnets = "${module.vpc.private-subnets}"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.id}"
    container_name = "app"
    container_port = "${var.app_port}"
  }

  depends_on = [
    "aws_alb_listener.front_end",
  ]
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "/fargate/service/${var.tag}-app"
}