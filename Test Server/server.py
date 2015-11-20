import optparse
import random
import sys
import OpenSSL

# Import from the ./libraries folder
sys.path.insert(0, 'libraries')

from flask import Flask
from flask import json
from flask import jsonify
from flask import request
from flask import Response

app = Flask(__name__)

# Create an SSL context (so we can test with SSL)
ssl_context = OpenSSL.SSL.Context(OpenSSL.SSL.SSLv23_METHOD)
ssl_context = ('ssl/localhost.crt', 'ssl/localhost.key')

ACCESS_TOKEN = '9999999999999999999999999999999999999999'
USERNAME = 'gooduser'
PASSWORD = 'goodpass'

# These are bad responses that we can randomly return in "crazy mode"
BAD_RESPONSES = (
    { "status_code": 400, "status_txt": "MISSING_ARG_LOGIN", "data" : None },
    { "status_code": 403, "status_txt": "RATE_LIMIT_EXCEEDED", "data" : None },
    { "status_code": 500, "status_txt": "UNKNOWN ERROR", "data" : None },
    { "status_code": 503, "status_txt": "TEMPORARILY_UNAVAILABLE", "data" : None },
)

# Mimics https://api-ssl.bitly.com/oauth/access_token
@app.route('/oauth/access_token', methods=['POST'])
def access_token():
    
    # Make sure we got a username and password
    if not request.authorization:
        return jsonify(status_code=500, data=None, status_txt='INVALID_CLIENT_ID')
    else:
        # Username and password are gooduser/goodpass
        auth = request.authorization
        if auth['username'] != USERNAME or auth['password'] != PASSWORD:
            return jsonify(status_code=401, data=None, status_txt='INVALID_LOGIN')
        else:
            return Response(ACCESS_TOKEN, status=200, mimetype='text/plain')


# Mimics https://api-ssl.bitly.com/v3/user/link_history
@app.route('/v3/user/link_history', methods=['GET'])
def link_history():

    # Make sure we got an access token
    access_token = request.args.get('access_token', None)
    if not access_token or access_token != ACCESS_TOKEN:
        return jsonify(status_code=403, data=None, status_txt='INVALID_ACCESS_TOKEN')

    if app.config['mode'] == '400':
        response = json.dumps(BAD_RESPONSES[0])
        return Response(response, status=200, mimetype='application/json')
    elif app.config['mode'] == '403':
        response = json.dumps(BAD_RESPONSES[1])
        return Response(response, status=200, mimetype='application/json')
    elif app.config['mode'] == '500':
        response = json.dumps(BAD_RESPONSES[2])
        return Response(response, status=200, mimetype='application/json')
    elif app.config['mode'] == '503':
        response = json.dumps(BAD_RESPONSES[3])
        return Response(response, status=200, mimetype='application/json')

    # Return a JSON response
    response_dict = {
        "status_code": 200,
        "status_txt": "OK",
        "data": {
            "link_history": [
                {
                    "aggregate_link": "http://bit.ly/1NG4gKL",
                    "archived": False,
                    "campaign_ids": [],
                    "client_id": "a5e8cebb233c5d07e5c553e917dffb92fec5264d",
                    "created_at": 1447982274,
                    "link": "http://bit.ly/1NG4gKK",
                    "long_url": "http://www.google.com/sports/",
                    "modified_at": 1447982274,
                    "private": False,
                    "tags": [],
                    "title": "",
                    "user_ts": 1447982274
                }
            ],
            "result_count": 1
        }
    }
    json_response = json.dumps(response_dict)
    return Response(json_response, status=200, mimetype='application/json')


# Mimics https://api-ssl.bitly.com/v3/link/clicks
@app.route('/v3/link/clicks', methods=['GET'])
def clicks_count():
    
    # Make sure we got an access token
    access_token = request.args.get('access_token', None)
    if not access_token or access_token != ACCESS_TOKEN:
        return jsonify(status_code=403, data=None, status_txt='INVALID_ACCESS_TOKEN')

    # Make sure we got a link argument
    link = request.args.get('link', None)
    if not link:
        return jsonify(status_code=400, data=None, status_txt='MISSING_ARG_LINK')

    # Make sure the link is http://foo.com
    if link != 'http://foo.com':
        return jsonify(status_code=404, data=None, status_txt='NOT_FOUND')

    if app.config['mode'] == '400':
        response = json.dumps(BAD_RESPONSES[0])
        return Response(response, status=200, mimetype='application/json')
    elif app.config['mode'] == '403':
        response = json.dumps(BAD_RESPONSES[1])
        return Response(response, status=200, mimetype='application/json')
    elif app.config['mode'] == '500':
        response = json.dumps(BAD_RESPONSES[2])
        return Response(response, status=200, mimetype='application/json')
    elif app.config['mode'] == '503':
        response = json.dumps(BAD_RESPONSES[3])
        return Response(response, status=200, mimetype='application/json')

    # Return a JSON response
    response_dict = {
        "status_code": 200, 
        "data": {
            "units": 30, 
            "unit_reference_ts": 1447994477, 
            "tz_offset": -5, 
            "unit": "day", 
            "link_clicks": 1
        }, 
        "status_txt": "OK"
    }
    json_response = json.dumps(response_dict)
    return Response(json_response, status=200, mimetype='application/json')


# Mimics https://api-ssl.bitly.com/v3/user/link_save
@app.route('/v3/user/link_save', methods=['GET'])
def link_save():
    
    # Make sure we got an access token
    access_token = request.args.get('access_token', None)
    if not access_token or access_token != ACCESS_TOKEN:
        return jsonify(status_code=403, data=None, status_txt='INVALID_ACCESS_TOKEN')

    # Make sure we got a longUrl argument
    link = request.args.get('longUrl', None)
    if not link:
        return jsonify(status_code=400, data=None, status_txt='MISSING_ARG_LONGURL')
    
    if app.config['mode'] == '400':
        response = json.dumps(BAD_RESPONSES[0])
        return Response(response, status=200, mimetype='application/json')
    elif app.config['mode'] == '403':
        response = json.dumps(BAD_RESPONSES[1])
        return Response(response, status=200, mimetype='application/json')
    elif app.config['mode'] == '500':
        response = json.dumps(BAD_RESPONSES[2])
        return Response(response, status=200, mimetype='application/json')
    elif app.config['mode'] == '503':
        response = json.dumps(BAD_RESPONSES[3])
        return Response(response, status=200, mimetype='application/json')
    
    # A good save is http://foo.com/1
    if link == 'http://foo.com/1':
        response_dict = {
            "status_code": 200, 
            "data": {
                "link_save": {
                    "link": "http://foo.it/abc123", 
                    "aggregate_link": "http://bit.ly/abc123", 
                    "long_url": "http://foo.com/1", 
                    "new_link": 1
                }
            }, 
            "status_txt": "OK"
        }
        json_response = json.dumps(response_dict)
        return Response(json_response, status=200, mimetype='application/json')
    
    # A duplicate save is http://foo.com/2
    if link == 'http://foo.com/2':
        response_dict = {
            "status_code": 304, 
            "data": {
                "link_save": {
                    "link": "http://foo.it/abc234", 
                    "aggregate_link": "http://bit.ly/abc234", 
                    "long_url": "http://foo.com/2", 
                    "new_link": 0
                }
            }, 
            "status_txt": "LINK_ALREADY_EXISTS"
        }
        json_response = json.dumps(response_dict)
        return Response(json_response, status=200, mimetype='application/json')

    # A malformed URI is http://foo/3
    if link == 'http://foo/3':
        return jsonify(status_code=500, data=None, status_txt='INVALID_URI')

    return 'You must test with urls http://foo.com/1, http://foo.com/2, or http://foo/3'



if __name__ == "__main__":

    # Set up the command-line options
    parser = optparse.OptionParser()
    parser.add_option('--mode', dest='mode')
    options, _ = parser.parse_args()

    app.debug = True
    app.config.update(mode=options.mode)
    #app.run(ssl_context=ssl_context)
    app.run()
