"""
AWS Lambda function for visitor counter
Increments and returns the visitor count stored in DynamoDB
"""

import json
import boto3
import os
from decimal import Decimal
from botocore.exceptions import ClientError

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE', 'cloud-resume-visitors')
table = dynamodb.Table(table_name)

# Primary key for the visitor counter
COUNTER_ID = 'visitor_count'


class DecimalEncoder(json.JSONEncoder):
    """Helper class to convert DynamoDB Decimal types to int/float for JSON serialization"""
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj)
        return super(DecimalEncoder, self).default(obj)


def lambda_handler(event, context):
    """
    Main Lambda handler function
    Increments the visitor count in DynamoDB and returns the new count

    Args:
        event: API Gateway event
        context: Lambda context

    Returns:
        dict: Response with status code, headers, and body
    """

    try:
        # Increment the visitor count atomically
        response = table.update_item(
            Key={'id': COUNTER_ID},
            UpdateExpression='ADD visit_count :inc',
            ExpressionAttributeValues={':inc': 1},
            ReturnValues='UPDATED_NEW'
        )

        # Extract the new count
        new_count = int(response['Attributes']['visit_count'])

        # Return success response
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',  # CORS header - restrict in production
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({
                'count': new_count,
                'message': 'Visitor count updated successfully'
            }, cls=DecimalEncoder)
        }

    except ClientError as e:
        # Handle DynamoDB errors
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']

        print(f"DynamoDB Error: {error_code} - {error_message}")

        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({
                'error': 'Failed to update visitor count',
                'message': 'Internal server error'
            })
        }

    except Exception as e:
        # Handle unexpected errors
        print(f"Unexpected error: {str(e)}")

        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({
                'error': 'An unexpected error occurred',
                'message': str(e)
            })
        }


def options_handler(event, context):
    """
    Handle OPTIONS requests for CORS preflight

    Args:
        event: API Gateway event
        context: Lambda context

    Returns:
        dict: Response with CORS headers
    """
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type'
        },
        'body': ''
    }
