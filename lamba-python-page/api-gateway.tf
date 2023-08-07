# Create API Gateway with Rest API type
resource "aws_api_gateway_rest_api" "rest_apigtw_tf" {
  name        = "Serverless"
  description = "Serverless Application using Terraform"
}

# Noramally this section defines a resource within your API
# We would  need this to define the different parts of our API's URL structure.
resource "aws_api_gateway_resource" "proxy" {
    # TODO: Check this
   rest_api_id = aws_api_gateway_rest_api.rest_apigtw_tf.id
   parent_id   = aws_api_gateway_rest_api.rest_apigtw_tf.root_resource_id
   # TODO: Modify this
   path_part   = "{proxy+}"     # with proxy, this resource will match any request path
}

# In this case, we are specifying the methods (HTTPs methods) that are allowed
# to reach a given resource
# Represents an HTTP method (e.g., GET, POST, PUT, DELETE) that is allowed on a specific resource.
# You need this to specify what actions (HTTP methods) are permitted on your API's resources.

# Maybe, here we could defined a list of all the resources for our API
# and dynamically assign which resources wopuld be accessed by a given method
resource "aws_api_gateway_method" "proxy" {
   rest_api_id   = aws_api_gateway_rest_api.rest_apigtw_tf.id
    # Previous defined resource
   resource_id   = aws_api_gateway_resource.proxy.id
    # with ANY, it allows any request method to be used, all incoming requests will match this resource
   http_method   = "ANY"      
   authorization = "NONE"
}

# API Gateway - Lambda Connection
# Defines how the API Gateway should forward requests to your backend service (AWS Lambda in this case).
# You need this to connect your API Gateway with your backend service, in this case, AWS Lambda.
resource "aws_api_gateway_integration" "connection_rest_apigtw_lambda_tf" {
   rest_api_id = aws_api_gateway_rest_api.rest_apigtw_tf.id
   resource_id = aws_api_gateway_method.proxy.resource_id
   http_method = aws_api_gateway_method.proxy.http_method
#    From API Gateway to Lambda function, communication will have place 
#    by POST request type
   integration_http_method = "POST"
# With AWS_PROXY, it causes API gateway to call into the API of another AWS service
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.lambda_function_tf.invoke_arn
}

# The proxy resource cannot match an empty path at the root of the API. 
# To handle that, a similar configuration must be applied to the root resource that is built in to the REST API object
resource "aws_api_gateway_method" "proxy_root" {
   rest_api_id   = aws_api_gateway_rest_api.rest_apigtw_tf.id
   resource_id   = aws_api_gateway_rest_api.rest_apigtw_tf.root_resource_id
   http_method   = "ANY"
   authorization = "NONE"
}


# The reason for using a POST request to invoke the Lambda function is that when you call a Lambda function via API Gateway
# with the "AWS_PROXY" integration type, API Gateway forwards the entire request (including headers, body, and other metadata)
# as the payload of the POST request to the Lambda function. This allows you to handle complex data and payloads within the Lambda
# function.

# On the other hand, if you use a GET request, the data is typically passed as query parameters in the URL,
# and there might be limitations on the data size that can be passed. Moreover, the data might be limited in
# structure (mostly key-value pairs).

# The type of integration is set to "AWS_PROXY," which means that API Gateway will call the Lambda function directly with a POST request.
# This integration allows any request method (GET, POST, PUT, DELETE, etc.) to be used for the specified resource.
resource "aws_api_gateway_integration" "connection_rest_apigtw_lambda_root_tf" {
   rest_api_id = aws_api_gateway_rest_api.rest_apigtw_tf.id
   resource_id = aws_api_gateway_method.proxy_root.resource_id
   http_method = aws_api_gateway_method.proxy_root.http_method
   integration_http_method = "POST"
   type                    = "AWS_PROXY"  # With AWS_PROXY, it causes API gateway to call into the API of another AWS service
   uri                     = aws_lambda_function.lambda_function_tf.invoke_arn
}

# # Deploy API Gateway
# Represents a deployment of your API to a specific stage (e.g., test, prod).
# You need this to make your API accessible with a specific URL
resource "aws_api_gateway_deployment" "rest_apigtw_deployment_tf" {
   depends_on = [
     aws_api_gateway_integration.connection_rest_apigtw_lambda_tf,
     aws_api_gateway_integration.connection_rest_apigtw_lambda_root_tf,
   ]
   rest_api_id = aws_api_gateway_rest_api.rest_apigtw_tf.id

#    By specifying a stage name in the aws_api_gateway_deployment resource, you are telling Terraform which
#    stage to associate with the specific version of your API defined in the aws_api_gateway_rest_api resource.
#    It allows you to create, manage, and deploy different versions of your API, each with its own configuration
#    and URL, ensuring proper isolation and version control.
   stage_name  = var.stage_name
}

# Output to the URL 
output "base_url" {
  value = aws_api_gateway_deployment.rest_apigtw_deployment_tf.invoke_url
}