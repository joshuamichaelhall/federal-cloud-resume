import json
import boto3
import os
import hashlib

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def get_visitor_ip(event):
    """Extract visitor IP from API Gateway event."""
    # Try various headers where IP might be found
    headers = event.get('headers', {}) or {}

    # CloudFront/ALB forward the real IP in these headers
    ip = headers.get('X-Forwarded-For', '').split(',')[0].strip()
    if not ip:
        ip = headers.get('x-forwarded-for', '').split(',')[0].strip()
    if not ip:
        # Fall back to requestContext
        request_context = event.get('requestContext', {})
        identity = request_context.get('identity', {})
        ip = identity.get('sourceIp', 'unknown')

    return ip

def hash_ip(ip):
    """Hash IP for privacy."""
    return hashlib.sha256(ip.encode()).hexdigest()[:16]

def lambda_handler(event, context):
    """
    Track unique visitors and return count.
    Only increments counter for new unique visitors (by IP hash).
    """

    # CORS headers
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET, OPTIONS'
    }

    # Handle OPTIONS preflight
    if event.get('httpMethod') == 'OPTIONS':
        return {
            'statusCode': 200,
            'headers': headers,
            'body': ''
        }

    try:
        # Get and hash visitor IP
        visitor_ip = get_visitor_ip(event)
        ip_hash = hash_ip(visitor_ip)

        # Try to record this visitor (will fail if already exists)
        try:
            table.put_item(
                Item={
                    'id': f'visitor#{ip_hash}',
                    'type': 'visitor'
                },
                ConditionExpression='attribute_not_exists(id)'
            )
            # New visitor - increment counter
            response = table.update_item(
                Key={'id': 'main-counter'},
                UpdateExpression='ADD #count :inc',
                ExpressionAttributeNames={'#count': 'count'},
                ExpressionAttributeValues={':inc': 1},
                ReturnValues='UPDATED_NEW'
            )
            count = int(response['Attributes']['count'])
        except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
            # Existing visitor - just get current count
            response = table.get_item(Key={'id': 'main-counter'})
            count = int(response.get('Item', {}).get('count', 0))

        return {
            'statusCode': 200,
            'headers': headers,
            'body': json.dumps({'count': count})
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': headers,
            'body': json.dumps({'error': 'Internal server error'})
        }
