@isTest
global class TestHttpMock implements HttpCalloutMock {
    HttpResponse res = new HttpResponse();
	// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        if (req.getEndpoint() == 'http://api.geonames.org/geoCodeAddressJSON') {
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"address":{"lat":"29.7604", "lon": "95.3698 "}}');
            res.setStatusCode(200);
        } else {
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
			res.setBody('{"timezoneId": "America/Chicago"}');
            res.setStatusCode(200);
        }
        return res;
    }

}