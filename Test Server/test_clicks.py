import ssl
import urllib2

# Allow for self-signed certs
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

TOKEN = '9999999999999999999999999999999999999999'

# request = urllib2.Request('https://localhost:5000/v3/link/clicks?access_token=%s&link=http://foo.coms' % TOKEN)
# result = urllib2.urlopen(request, context=ctx)

request = urllib2.Request('http://localhost:5000/v3/link/clicks?access_token=%s&link=http://foo.com' % TOKEN)
result = urllib2.urlopen(request)


print result.read()
