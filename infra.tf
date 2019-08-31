provider "aws" {
    region = "us-east-1"
}

resource "aws_lambda_function" "my-function" {
    function_name = "my-function"
    filename = "function/build/build.zip"
    source_code_hash = "${filebase64sha256("function/build/build.zip")}"
    role = "${aws_iam_role.r-netsec.arn}"
    handler = "main.handler"
    runtime = "python3.7"
    timeout = "15"
    environment {
        variables = {
            EXAMPLE_VAR = "example"
        }
    }
}

resource "aws_cloudwatch_event_rule" "example-schedule" {
    name = "example-schedule"
    description = "Fire periodically to trigger my function."
    schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "cw-target" {
    rule = "${aws_cloudwatch_event_rule.example-schedule.name}"
    target_id = "my_function"
    arn = "${aws_lambda_function.my-function.arn}"
}

resource "aws_iam_role" "my-function" {
    name = "my-function"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "CloudWatchPublish" {
    policy =<<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "publish-attach" {
    name = "CloudWatchPublish"
    roles = ["${aws_iam_role.my-function.name}"]
    policy_arn = "${aws_iam_policy.CloudWatchPublish.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.my-function.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.example-schedule.arn}"
}