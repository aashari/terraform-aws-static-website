/**
 * 
 * This is an example of a CloudFront Function to redirect www. access to non-www access.
 */
function handler(event) {

    var requestPayload = event.request;
    var requestHost = requestPayload.headers['host'].value;
    var requestURI = requestPayload.uri;
    var requestQueryString = requestPayload.querystring;

    // if requestHost starts with www.
    if (requestHost.startsWith('www.')) {

        // generate new host without www.
        var newHost = requestHost.replace('www.', '');

        // if requestURI does not start with /
        if (!requestURI.startsWith('/')) {
            // add / to requestURI
            requestURI = '/' + requestURI;
        }
        var redirectURL = newHost + requestURI;

        // convert querystring object to string
        var queryString = '';
        for (var key in requestQueryString) {
            queryString += key + '=' + requestQueryString[key].value + '&';
        }

        // if queryString is not empty
        if (queryString.length > 0) {
            // remove last &
            queryString = queryString.substring(0, queryString.length - 1);
            // add queryString to redirectURL
            redirectURL += '?' + queryString;
        }

        // return redirect
        return {
            statusCode: 301,
            statusDescription: 'Found',
            headers: {
                location: {
                    value: 'http://' + redirectURL
                }
            }
        };
    }

    return requestPayload;
}
