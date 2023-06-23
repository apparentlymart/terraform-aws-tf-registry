from curses import nonl
from typing import Union, Optional
import jwt
import os
from boto3 import client
from base64 import b64decode
import datetime

_secret, _dt = None, None


def lambda_handler(event: dict, context) -> dict:
    try:
        auth_token = event.get("authorizationToken")
        method_arn = event.get("methodArn")
        if auth_token and method_arn:
            # verify the JWT
            user_details = decode_auth_token(auth_token)
            if user_details:
                # if the JWT is valid and not expired return a valid policy.
                return generate_policy(user_details.get("id"), "Allow", method_arn)
        return generate_policy(None, "Deny", method_arn)
    except Exception as e:
        return {"error": f"{type(e).__name__}:{e}"}


def decode_auth_token(auth_token: str) -> Optional[dict]:
    """Decodes the auth token"""
    try:
        # remove "Bearer " from the token string.
        auth_token = auth_token.replace("Bearer ", "")
        return jwt.decode(auth_token.encode(), get_secret(), algorithms="HS256")
    except jwt.ExpiredSignatureError:
        # "Signature expired. Please log in again."
        return
    except jwt.InvalidTokenError:
        # "Invalid token. Please log in again."
        return


def generate_policy(
    principal_id: Union[int, str, None], effect: str, method_arn: str
) -> dict:
    """return a valid AWS policy response"""
    auth_response = {"principalId": principal_id}

    tmp = method_arn.split(':')
    region = tmp[3]
    aws_account_id = tmp[4]
    api_gateway_arn_tmp = tmp[5].split('/')
    rest_api_id = api_gateway_arn_tmp[0]
    stage = api_gateway_arn_tmp[1]
    
    if effect and method_arn:
        policy_document = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "FirstStatement",
                    "Action": "execute-api:Invoke",
                    "Effect": effect,
                    "Resource": f"arn:aws:execute-api:{region}:{aws_account_id}:{rest_api_id}/{stage}/*",
                }
            ],
        }
        auth_response["policyDocument"] = policy_document
    return auth_response


def get_secret():
    global _secret, _dt

    def _get_secret(secret_name: str):
        secret_value_response = client(
            "secretsmanager", region_name="eu-west-1"
        ).get_secret_value(SecretId=secret_name)
        return (
            secret_value_response["SecretString"]
            if "SecretString" in secret_value_response
            else str(b64decode(secret_value_response["SecretBinary"]))
        )

    def _init_secret():
        # using system environ $SECRET_KEY_NAME, will crash if not set.
        return _get_secret(
            secret_name=os.environ["SECRET_KEY_NAME"]
        ), datetime.datetime.now(tz=datetime.timezone.utc)

    if _secret is None:
        _secret, _dt = _init_secret()
        return _secret

    # if cache is too old, renew value
    if _dt + datetime.timedelta(hours=1) < datetime.datetime.now(
        tz=datetime.timezone.utc
    ):
        _secret, _dt = _init_secret()

    return _secret
