import ssl
import urllib2

# Allow for self-signed certs
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

TOKEN = '9999999999999999999999999999999999999999'

request = urllib2.Request('https://localhost:5000/v3/user/link_history?access_token=%s' % TOKEN)
result = urllib2.urlopen(request, context=ctx)

print result.read()
