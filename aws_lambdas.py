import json
import os
import time
import boto3
import logging

logging_format = '%(asctime)s - %(levelname)s - %(funcName)s:%(lineno)d - %(message)s\n'
logger = logging.getLogger()
if logger.handlers:
    logger.handlers[0].setFormatter(logging.Formatter(logging_format))
    logger.setLevel(logging.INFO)


sfn = boto3.client('stepfunctions')


def start(event, context):
    sqs_message = event['Records'][0]['body']
    logger.info('sqs message: %s', sqs_message)

    response = sfn.start_execution(
        stateMachineArn=os.getenv("STATE_MACHINE_ARN"),
        input=sqs_message,
    )
    logger.info("start response %s", response)


def calculate(event, context):
    logger.info("received message: %s", event)

    if event['id'] == 104:
        raise Exception('calculation failed')

    logger.info("sleep %s seconds", event['sleep'])
    time.sleep(event['sleep'])
    logger.info("done")
    return {f"result{event['id']}": f"processed task: {event['id']}"}


def aggregate(event, context):
    logger.info("received aggregated result: %s", event)

    if 'Error' in event:
        return "one of calculation failed"
    else:
        return "processed result " + json.dumps(event, default=str)

