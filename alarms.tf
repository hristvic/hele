# Create CloudWatch Alarms; SNS Topics and Subscription
data "aws_iam_policy_document" "notify_policy" {
  statement {
    actions = [
      "SNS:Publish",
    ]
    resources = [
      "${aws_sns_topic.sns_topic.arn}",
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }
}

# Create Alarm
resource "aws_cloudwatch_metric_alarm" "requests" {
  alarm_name          = "NumberOfRequestsCount"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "2"
  alarm_description   = "Requests_Alarm_For_ALB"
  treat_missing_data  = "notBreaching"
  alarm_actions       = ["${aws_sns_topic.sns_topic.arn}"]
  ok_actions          = ["${aws_sns_topic.sns_topic.arn}"]
  dimensions = {
    LoadBalancer = aws_lb.ext-alb.arn_suffix
  }
}

# Cretea SNS Topic with policy
resource "aws_sns_topic" "sns_topic" {
  name = "hele-topic"
}

resource "aws_sns_topic_policy" "notify_policy" {
  arn    = aws_sns_topic.sns_topic.arn
  policy = data.aws_iam_policy_document.notify_policy.json
}

# send mail via subscription
resource "aws_sns_topic_subscription" "sns_to_email" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "viktor.hristov9@gmail.com"
}