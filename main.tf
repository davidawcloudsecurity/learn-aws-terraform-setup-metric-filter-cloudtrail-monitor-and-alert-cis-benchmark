# Define the CloudWatch Log Group for CloudTrail logs
resource "aws_cloudwatch_log_group" "cloudtrail_logs_ablr" {
  name = "cloudtrail-logs-ablr"
}

# Define the CloudWatch Log Group for S3 data event logs
resource "aws_cloudwatch_log_group" "s3_data_events" {
  name = "s3-data-events"
}

# Define the SNS Topic for notifications
resource "aws_sns_topic" "cis_alerts" {
  name = "cis-alerts"
}

# CloudWatch Metric Filters for Management Events
resource "aws_cloudwatch_log_metric_filter" "management_event_filters" {
  for_each = {
    "UnauthorizedAPICalls" = "{($.errorCode=\"*UnauthorizedOperation\") || ($.errorCode=\"AccessDenied*\")}"
    "RootAccountUsage"     = "{$.userIdentity.type=\"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType !=\"AwsServiceEvent\"}"
    "IamPolicyChange"      = "{($.eventSource=iam.amazonaws.com) && (($.eventName=DeleteGroupPolicy) || ($.eventName=DeleteRolePolicy) || ($.eventName=DeleteUserPolicy) || ($.eventName=PutGroupPolicy) || ($.eventName=PutRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreatePolicy) || ($.eventName=DeletePolicy) || ($.eventName=CreatePolicyVersion) || ($.eventName=DeletePolicyVersion) || ($.eventName=AttachRolePolicy) || ($.eventName=DetachRolePolicy) || ($.eventName=AttachUserPolicy) || ($.eventName=DetachUserPolicy) || ($.eventName=AttachGroupPolicy) || ($.eventName=DetachGroupPolicy))}"
    "CloudTrailConfigChange" = "{($.eventName=CreateTrail) || ($.eventName=UpdateTrail) || ($.eventName=DeleteTrail) || ($.eventName=StartLogging) || ($.eventName=StopLogging)}"
    "SignInFailures"       = "{($.eventName=ConsoleLogin) && ($.errorMessage=\"Failed authentication\")}"
    "DisabledCMKs"         = "{($.eventSource=kms.amazonaws.com) && (($.eventName=DisableKey) || ($.eventName=ScheduleKeyDeletion))}"
    "S3PolicyChanges"      = "{($.eventSource=s3.amazonaws.com) && (($.eventName=PutBucketAcl) || ($.eventName=PutBucketPolicy) || ($.eventName=PutBucketCors) || ($.eventName=PutBucketLifecycle) || ($.eventName=PutBucketReplication) || ($.eventName=DeleteBucketPolicy) || ($.eventName=DeleteBucketCors) || ($.eventName=DeleteBucketLifecycle) || ($.eventName=DeleteBucketReplication))}"
    "ConfigServiceChanges" = "{($.eventSource=config.amazonaws.com) && (($.eventName=StopConfigurationRecorder) || ($.eventName=DeleteDeliveryChannel) || ($.eventName=PutDeliveryChannel) || ($.eventName=PutConfigurationRecorder))}"
    "SecurityGroupChanges" = "{($.eventName=AuthorizeSecurityGroupIngress) || ($.eventName=AuthorizeSecurityGroupEgress) || ($.eventName=RevokeSecurityGroupIngress) || ($.eventName=RevokeSecurityGroupEgress) || ($.eventName=CreateSecurityGroup) || ($.eventName=DeleteSecurityGroup)}"
    "NACLChanges"          = "{($.eventName=CreateNetworkAcl) || ($.eventName=CreateNetworkAclEntry) || ($.eventName=DeleteNetworkAcl) || ($.eventName=DeleteNetworkAclEntry) || ($.eventName=ReplaceNetworkAclEntry) || ($.eventName=ReplaceNetworkAclAssociation)}"
    "NetworkGatewayChanges" = "{($.eventName=CreateCustomerGateway) || ($.eventName=DeleteCustomerGateway) || ($.eventName=AttachInternetGateway) || ($.eventName=CreateInternetGateway) || ($.eventName=DeleteInternetGateway) || ($.eventName=DetachInternetGateway)}"
    "RouteTableChanges"    = "{($.eventSource=ec2.amazonaws.com) && (($.eventName=CreateRoute) || ($.eventName=CreateRouteTable) || ($.eventName=ReplaceRoute) || ($.eventName=ReplaceRouteTableAssociation) || ($.eventName=DeleteRouteTable) || ($.eventName=DeleteRoute) || ($.eventName=DisassociateRouteTable))}"
    "VpcChanges"           = "{($.eventName=CreateVpc) || ($.eventName=DeleteVpc) || ($.eventName=ModifyVpcAttribute) || ($.eventName=AcceptVpcPeeringConnection) || ($.eventName=CreateVpcPeeringConnection) || ($.eventName=DeleteVpcPeeringConnection) || ($.eventName=RejectVpcPeeringConnection) || ($.eventName=AttachClassicLinkVpc) || ($.eventName=DetachClassicLinkVpc) || ($.eventName=DisableVpcClassicLink) || ($.eventName=EnableVpcClassicLink)}"
  }

  name           = each.key
  pattern        = each.value
  log_group_name = aws_cloudwatch_log_group.cloudtrail_logs_ablr.name

  metric_transformation {
    name      = each.key
    namespace = "CISBenchmark"
    value     = "1"
  }
}

# CloudWatch Metric Filters for S3 Data Events
resource "aws_cloudwatch_log_metric_filter" "s3_data_event_filters" {
  for_each = {
    "S3ObjectRead"  = "{($.eventSource=s3.amazonaws.com) && ($.eventName=GetObject)}"
    "S3ObjectWrite" = "{($.eventSource=s3.amazonaws.com) && ($.eventName=PutObject)}"
  }

  name           = each.key
  pattern        = each.value
  log_group_name = aws_cloudwatch_log_group.s3_data_events.name

  metric_transformation {
    name      = each.key
    namespace = "CISBenchmark"
    value     = "1"
  }
}

# CloudWatch Alarms for Management Events
resource "aws_cloudwatch_metric_alarm" "management_event_alarms" {
  for_each = aws_cloudwatch_log_metric_filter.management_event_filters

  alarm_name          = "CIS-${each.key}-Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = each.key
  namespace           = "CISBenchmark"
  period              = 300
  statistic           = "Sum"
  threshold           = 1

  alarm_actions = [aws_sns_topic.cis_alerts.arn]
}

# CloudWatch Alarms for S3 Data Events
resource "aws_cloudwatch_metric_alarm" "s3_data_event_alarms" {
  for_each =
::contentReference[oaicite:0]{index=0}
 
