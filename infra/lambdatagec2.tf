module "exemplo_modulo" {
  # O segredo é adicionar ?ref=v3.0.0 ao final da URL
  source = "git::https://github.com/sua-empresa/seu-repo.git?ref=v3.0.0"

  # Variáveis do módulo (inputs)
  ambiente      = "producao"
  tipo_instancia = "t3.micro"
}

#########
# LAMBDA
#########

resource "aws_lambda_function" "lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "stopec2"
  role          = "arn:aws:iam::119739005737:role/startandstop"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  publish       = true
  timeout       = 30
  memory_size   = 128
}

###########
# scheduler
###########

resource "aws_cloudwatch_event_rule" "profile_generator_stop_ec2" {
  name = "profile-generator-stop-event-rule"
  description = "Stop"
  schedule_expression = "cron(15 07 ? * * *)"
}

resource "aws_cloudwatch_event_target" "profile_generator_stop_target" {
  arn = "arn:aws:lambda:us-east-1:119739005737:function:stopec2"
  rule = aws_cloudwatch_event_rule.profile_generator_stop_ec2.name
  input = <<JSON
{
  "env": "dev",
  "action": "Stop"
} 
  JSON
}

resource "aws_lambda_permission" "trigger_scheduller" {
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda.function_name
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.profile_generator_stop_ec2.arn}"
}
