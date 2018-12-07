require 'httparty'
require 'json'

def convert_geoip_boolean(value)
  value == 'yes' ? true : false
end

def lambda_handler(event:, context:)
  # Sample pure Lambda function

  # Parameters
  # ----------
  # event: Hash, required
  #     API Gateway Lambda Proxy Input Format

  #     {
  #         "resource": "Resource path",
  #         "path": "Path parameter",
  #         "httpMethod": "Incoming request's method name"
  #         "headers": {Incoming request headers}
  #         "queryStringParameters": {query string parameters }
  #         "pathParameters":  {path parameters}
  #         "stageVariables": {Applicable stage variables}
  #         "requestContext": {Request context, including authorizer-returned key-value pairs}
  #         "body": "A JSON string of the request payload."
  #         "isBase64Encoded": "A boolean flag to indicate if the applicable request payload is Base64-encode"
  #     }

  #     https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

  # context: object, required
  #     Lambda Context runtime methods and attributes

  # Attributes
  # ----------

  # context.aws_request_id: str
  #      Lambda request ID
  # context.client_context: object
  #      Additional context when invoked through AWS Mobile SDK
  # context.function_name: str
  #      Lambda function name
  # context.function_version: str
  #      Function version identifier
  # context.get_remaining_time_in_millis: function
  #      Time in milliseconds before function times out
  # context.identity:
  #      Cognito identity provider context when invoked through AWS Mobile SDK
  # context.invoked_function_arn: str
  #      Function ARN
  # context.log_group_name: str
  #      Cloudwatch Log group name
  # context.log_stream_name: str
  #      Cloudwatch Log stream name
  # context.memory_limit_in_mb: int
  #     Function memory

  # Returns
  # ------
  # API Gateway Lambda Proxy Output Format: dict
  #     'statusCode' and 'body' are required

  #     {
  #         "isBase64Encoded": true | false,
  #         "statusCode": httpStatusCode,
  #         "headers": {"headerName": "headerValue", ...},
  #         "body": "..."
  #     }

  #     # api-gateway-simple-proxy-for-lambda-output-format
  #     https: // docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html

  sourceIp = event['requestContext']['identity']['sourceIp']
  certPath = './cosmos/client.pem'

  options = {
    pem: File.read(certPath),
    verify: false
  }

  begin
    response = HTTParty.head("https://geoip.test.tools.bbc.co.uk/#{sourceIp}", options)

    uk_combined = convert_geoip_boolean(response.headers['x-ip_is_uk_combined']);
    advertise_combined = convert_geoip_boolean(response.headers['x-ip_is_advertise_combined']);
    country_code = response.headers['x-country'];
  rescue HTTParty::Error => error
    puts error.inspect
    raise error
  end

  return {
    :statusCode => response.code,
    :body => {
      :message => "Hello World!",
      :location => response.headers
    }.to_json
  }
end
