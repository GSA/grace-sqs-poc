var SQSClient = Class.create();
SQSClient.prototype = {
	initialize: function(options) {
		options = options || {};

		this.accessKeyId     = gs.getProperty('grace.access_key');
		this.secretAccessKey = gs.getProperty('grace.secret_key');
		this.host = options.host || 'sqs.us-east-1.amazonaws.com';
	},

	sendMessage: function(options) {
		// Build out the options we want to apply to the RESTMessageV2 call
		var reqOpts = {
			awsCredentials: {
				accessKeyId:     this.accessKeyId,
				secretAccessKey: this.secretAccessKey
			},
			method: 'POST',
			host: this.host,
			headers: { 'Accept': 'application/json' },
			query: options
		};

		reqOpts.query.Action = 'SendMessage';

		var rm = this.prepareRestMessage(reqOpts);
		var response = rm.execute();

		gs.debug(response.getBody());
    return response;
	},

	prepareRestMessage: function(options) {
		var rm = new sn_ws.RESTMessageV2();
		rm.setHttpMethod(options.method || 'GET');
		rm.setEndpoint('https://' + options.host);

		// Loop through the headers and add them
		for (var h in options.headers) {
			rm.setRequestHeader(h, options.headers[h]);
		}

		// Loop through the query params and add them to the message
		// We'll also build an array of key/value pairs for later use
		var params = [];
		for (var q in options.query) {
			rm.setQueryParameter(q, options.query[q]);
			params.push([q, options.query[q]].join('='));
		}

		// Get a signature
		var opts = {
			method: options.method,
			host: options.host,
			path: '?' + params.join('&') // We collected these in the last step
		};

		// The only place we actually use the aws4 package
		aws4.sign(opts, options.awsCredentials);

		// Set the headers using the signature we just obtained
		rm.setRequestHeader('Authorization', opts.headers.Authorization);
		rm.setRequestHeader('X-Amz-Date', opts.headers['X-Amz-Date']);

		return rm;
	},

	type: 'SQSClient'
};
