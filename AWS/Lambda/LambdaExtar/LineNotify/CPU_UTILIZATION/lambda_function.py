import json
import os
import urllib3
import re

# Set the LINE Notify API endpoint and the token
LINE_NOTIFY_API_URL = os.getenv('LINE_NOTIFY_API_URL')  # Store api-url in environment variable
LINE_NOTIFY_TOKEN = os.getenv('LINE_NOTIFY_TOKEN')  # Store token in environment variable

http = urllib3.PoolManager()

def send_line_notify(message):
    """Send a notification to Line via Line Notify API."""
    headers = {
        'Authorization': f'Bearer {LINE_NOTIFY_TOKEN}',
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    payload = {
        'message': message
    }
    encoded_payload = urllib3.request.urlencode(payload)
    
    response = http.request(
        'POST',
        LINE_NOTIFY_API_URL,
        body=encoded_payload,
        headers=headers
    )
    return response.status

def format_message(sns_message_data, sns_topic_arn):
    """Format message based on CloudWatch Alarm type."""
    alarm_name = sns_message_data.get('AlarmName', 'No Alarm Name')
    new_state = sns_message_data.get('NewStateValue', 'Unknown State')
    reason = sns_message_data.get('NewStateReason', 'No reason provided')
    
    app_name = get_app_name_from_sns_arn(sns_topic_arn)
    # Check the namespace or alarm name to categorize the alert
    # namespace = sns_message_data.get('Trigger', {}).get('Namespace', '')

    # Customize the message based on different types of alarms
    if new_state == "OK":
        message = (
            f"✅ Alarm Resolved \nApp Name: {app_name} ✅\nAlarm: {alarm_name}\nState: {new_state}\nReason: {reason}\n"
        )
    else:
        message = (
            f"🚨 General Alarm \nApp Name: {app_name} 🚨\nAlarm: {alarm_name}\nState: {new_state}\nReason: {reason}\n"
        )
    return message

def get_app_name_from_sns_arn(topic_arn):
    try:
        match = re.search(r'PRD_(\w+?)_', topic_arn)
        if match:
            extracted_text = match.group(1)  
        else:
            print("Pattern not found")
            extracted_text = "UNKNOWN_APP_NAME"
    except Exception as e:
        print(f"An error occurred: {e}")
        extracted_text = "UNKNOWN_APP_NAME"
    
    return extracted_text

def lambda_handler(event, context):
    """Lambda handler triggered by SNS topic."""
    sns_message = event['Records'][0]['Sns']['Message']
    sns_topic_arn = event['Records'][0]['Sns']['TopicArn']
    
    # Log the full SNS message for troubleshooting
    print(f"SNS Message: {sns_message}")
    
    # Parse the SNS message from the CloudWatch Alarm (if applicable)
    sns_message_data = json.loads(sns_message)
    
    # Format the message for Line Notify based on the type of alarm
    message = format_message(sns_message_data, sns_topic_arn)
    
    # Send the message to Line
    status = send_line_notify(message)
    
    # Log the result
    return {
        'statusCode': status,
        'body': json.dumps(f'Line Notify response: {status}')
    }