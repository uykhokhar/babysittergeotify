# CloudKit Helper
#
#
# Based off the following
#  - CloudKitCatalog (c) 2016, Apple
#  - PyCloudKit. Created on 09.02.2016  (c) 2015 Andreas Schulz
#  - requests-cloudkit Copyright 2016 Lionheart Software LLC


from __future__ import print_function
import ecdsa
import base64
import hashlib
import datetime
import sys
import json

from urllib2 import HTTPPasswordMgrWithDefaultRealm, HTTPBasicAuthHandler, Request, build_opener
from urllib import urlencode


KEY_ID = '6373d7192a1081d3c70fb4194f81b5eaeab74a90c430e9f973aff06227ebacff'
CONTAINER = 'iCloud.com.khokharumar.babysitterhours1'

def cloudkit_request(cloudkit_resource_url, data):
    """Uses HTTP GET or POST to interact with CloudKit. If data is empty, Uses
    GET, else, POSTs the data.
    """

    # Get ISO 8601 date, cut milliseconds.
    date = datetime.datetime.utcnow().isoformat()[:-7] + 'Z'

    # Load JSON request from config.
    _hash = hashlib.sha256(data.encode('utf-8')).digest()
    body = base64.b64encode(_hash).decode('utf-8')

    # Construct URL to CloudKit container.
    web_service_url = '/database/1/' + CONTAINER  + cloudkit_resource_url

    # Load API key from config.
    key_id = KEY_ID

    # Read out certificate file corresponding to API key.
    with open('eckey.pem', 'r') as pem_file:
        signing_key = ecdsa.SigningKey.from_pem(pem_file.read())

    # Construct payload.
    unsigned_data = ':'.join([date, body, web_service_url]).encode('utf-8')

    # Sign payload via certificate.
    signed_data = signing_key.sign(unsigned_data,
                                   hashfunc=hashlib.sha256,
                                   sigencode=ecdsa.util.sigencode_der)

    signature = base64.b64encode(signed_data).decode('utf-8')

    headers = {
        'X-Apple-CloudKit-Request-KeyID': key_id,
        'X-Apple-CloudKit-Request-ISO8601Date': date,
        'X-Apple-CloudKit-Request-SignatureV1': signature
    }

    if data:
        req_type = 'POST'
    else:
        req_type = 'GET'

    result = curl('https://api.apple-cloudkit.com' + web_service_url,
                  req_type=req_type,
                  data=data,
                  headers=headers)

    return result


def curl(url, params=None, auth=None, req_type='GET', data=None, headers=None):
    """Provides HTTP interaction like curl."""
    print("URL: ", url)
    print("Data: ", data)
    print("Headers: ", headers)
    print("Params: ", params)

    post_req = ['POST', 'PUT']
    get_req = ['GET', 'DELETE']

    if params is not None:
        url += '?' + urlencode(params)

    if req_type not in post_req + get_req:
        raise IOError('Wrong request type "%s" passed' % req_type)

    _headers = {}
    handler_chain = []

    if auth is not None:
        manager = HTTPPasswordMgrWithDefaultRealm()
        manager.add_password(None, url, auth['user'], auth['pass'])
        handler_chain.append(HTTPBasicAuthHandler(manager))

    if req_type in post_req and data is not None:
        _headers['Content-Length'] = len(data)

    if headers is not None:
        _headers.update(headers)

    director = build_opener(*handler_chain)

    if req_type in post_req:
        if sys.version_info.major < 3:
            _data = bytes(data)
        else:
            _data = bytes(data, encoding='utf8')
        req = Request(url, headers=_headers, data=_data)

    else:
        req = Request(url, headers=_headers)

    req.get_method = lambda: req_type
    result = director.open(req)

    return {
        'httpcode': result.code,
        'headers': result.info(),
        'content': result.read().decode('utf-8')
    }



''' #how to filter queries by today
    json_query = {
        'query': {
            'recordType': record_type ,
            "filterBy": [
                {
                    "systemFieldName": "createdTimestamp",
                    "comparator": "EQUALS",
                    "fieldValue": {
                        "value": {
                            "recordName": "recordA",
                        },
                        "type": "REFERENCE"
                    }
                }
            ],
            "sortBy": [
                {
                    "systemFieldName": "createdTimestamp",
                    "ascending": false
                }
            ]
        }
    }

'''


def query_records(record_type):
    """Queries CloudKit for all records of type record_type."""
    json_query = {
        'query': {
            'recordType': record_type,
            'sortBy': [
                {
                    "systemFieldName": "createdTimestamp",
                    "ascending": True
                }
            ]

        }
    }

    records = []
    while True:
        result_query_authors = cloudkit_request(
            '/development/public/records/query',
            json.dumps(json_query))
        result_query_authors = json.loads(result_query_authors['content'])

        records += result_query_authors['records']

        if 'continuationMarker' in result_query_authors.keys():
            json_query['continuationMarker'] = \
                result_query_authors['continuationMarker']
        else:
            break

    return records

def write_json_to_file(json_data, file_name="results.json"):
    """Write JSON to file in pretty notation for debugging"""
    print(json_data)
    with open(file_name, 'w') as outfile:
        json.dump(json_data, outfile, sort_keys = True, indent = 4,ensure_ascii = False)

def dump_zones():
    """Print out the zones"""
    print('Requesting list of zones...')
    result_zones = cloudkit_request('/development/public/zones/list', '')
    print("Zones: ", result_zones['content'])
