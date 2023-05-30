import boto3
import fnmatch

region = 'us-east-1'

def lambda_handler(event, context):
    # Obtém o nome da instância EC2 do evento
    instance_names = ['ss*','neg*','nod*']
    
    # Define as tags a serem inseridas nas instâncias
    tags = [
        {'Key': 'env', 'Value': 'dev'},
        {'Key': 'Project', 'Value': 'Test'}
    ]
    
    # Cria uma instância do cliente EC2
    ec2 = boto3.client('ec2')
    
    # Obtém todas as instâncias EC2
    response = ec2.describe_instances()
    instances = response['Reservations']
    
    # Percorre as instâncias EC2 e insere as tags nas correspondentes aos nomes fornecidos
    for reservation in instances:
        for instance in reservation['Instances']:
            if 'Tags' in instance:
                for tag in instance['Tags']:
                    if tag['Key'] == 'Name':
                        for pattern in instance_names:
                            if fnmatch.fnmatch(tag['Value'], pattern):
                                instance_id = instance['InstanceId']
                                ec2.create_tags(Resources=[instance_id], Tags=tags)
    
    # Retorna uma resposta de sucesso
    return {
        'statusCode': 200,
        'body': 'Tags inseridas com sucesso nas instâncias EC2.'
    }
