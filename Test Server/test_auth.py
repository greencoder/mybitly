import base64
import urllib2

request = urllib2.Request('http://localhost:5000/oauth/access_token', data={})
base64string = base64.encodestring('%s:%s' % ('gooduser', 'goodpass')).replace('\n', '')
request.add_header("Authorization", "Basic %s" % base64string)

result = urllib2.urlopen(request)
print result.read()
