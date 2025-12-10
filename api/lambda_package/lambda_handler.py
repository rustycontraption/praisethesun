"""
AWS Lambda handler without Mangum - Direct API Gateway integration
"""
import json
from calculate_sun_location import find_sun


def handler(event, context):
    """
    Lambda handler for API Gateway proxy integration
    Handles the /search endpoint directly
    """
    
    # Parse query string parameters
    query_params = event.get('queryStringParameters') or {}
    
    try:
        # Extract and validate parameters
        start_point_lat = float(query_params.get('start_point_lat'))
        start_point_lng = float(query_params.get('start_point_lng'))
        radiusKilometers = int(query_params.get('radiusKilometers'))
        
        # Validate latitude
        if not (-90 <= start_point_lat <= 90):
            return {
                'statusCode': 422,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({
                    'error': 'Validation error',
                    'detail': 'start_point_lat must be between -90 and 90'
                })
            }
        
        # Validate longitude
        if not (-180 <= start_point_lng <= 180):
            return {
                'statusCode': 422,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({
                    'error': 'Validation error',
                    'detail': 'start_point_lng must be between -180 and 180'
                })
            }
        
        # Validate radius
        if not (0 <= radiusKilometers <= 1000):
            return {
                'statusCode': 422,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({
                    'error': 'Validation error',
                    'detail': 'radiusKilometers must be between 0 and 1000'
                })
            }
        
        # Call the find_sun function (same as lines 7-13 in main.py)
        result = find_sun(
            start_lat=start_point_lat,
            start_lng=start_point_lng,
            radiusKilometers=radiusKilometers
        )
        
        # Convert Pydantic models to dicts for JSON serialization
        result_dicts = [coord.model_dump() for coord in result]
        
        # Return successful response
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(result_dicts)
        }
        
    except (KeyError, TypeError, ValueError) as e:
        return {
            'statusCode': 422,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'error': 'Validation error',
                'detail': f'Invalid or missing parameters: {str(e)}'
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'error': 'Internal server error',
                'detail': str(e)
            })
        }
