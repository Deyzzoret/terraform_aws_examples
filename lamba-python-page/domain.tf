
# Here,  we are using the data source provided by AWS
# to retrieve the ROUTE53_ZONE_ID related to my Route 53
# hosted zoned.
# Allows to retrieve information related to an existing Route 53 zone
# (hosted zone)
data "aws_route53_zone" "existing_zone" {
  name = "jcdzzy.com"  # Replace with your domain name
}

# I would recommend to create the file
# certificate by hand and the ARN using data resource block
resource "aws_acm_certificate" "custom_domain_certificate_tf" {
  domain_name       = "lambdatst.jcdzzy.com"  # Replace with your custom domain name
  validation_method = "DNS"

  tags = {
    Name = "Custom Domain Certificate Lambda"
  }
}

# Create the CNAME record in the specified hosted zone.
resource "aws_route53_record" "custom_domain_record" {
  # Replace with your Route 53 Hosted Zone ID
  zone_id = data.aws_route53_zone.existing_zone.zone_id
  # Replace with your custom domain name
  name    = "lambdatst.jcdzzy.com"     
  type    = "CNAME"
  # Time-to-live for the DNS record in seconds
  ttl     = 300                     

  records = [
    aws_api_gateway_domain_name.custom_domain_lambda_tf.cloudfront_domain_name
  ]

  depends_on = [
        aws_api_gateway_deployment.rest_apigtw_deployment_tf,
        aws_api_gateway_domain_name.custom_domain_lambda_tf
  ]
}

resource "aws_api_gateway_domain_name" "custom_domain_lambda_tf" {
  # Replace with your domain name
  domain_name              = "lambdatst.jcdzzy.com"  
  # Replace with your ACM certificate ARN
  certificate_arn          = var.certificate_lambda_func_arn 


endpoint_configuration {
    types = ["EDGE"]
  }
  # Use the same value for the regional ACM certificate ARN
#   regional_certificate_arn = var.certificate_lambda_func_arn
#   depends_on = [
#     aws_acm_certificate.custom_domain_certificate_tf
#   ]
}


resource "aws_api_gateway_base_path_mapping" "api_base_path_mapping" {
  domain_name = aws_api_gateway_domain_name.custom_domain_lambda_tf.domain_name
  stage_name  = var.stage_name  # Replace with your desired stage name (e.g., "prod", "test", etc.)
  api_id = aws_api_gateway_rest_api.rest_apigtw_tf.id

  depends_on = [
    aws_api_gateway_deployment.rest_apigtw_deployment_tf,
    aws_api_gateway_domain_name.custom_domain_lambda_tf
  ]
}


