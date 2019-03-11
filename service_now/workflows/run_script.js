var list = current.variables.environments.getDisplayValue().toString();
var environments = list.split(',');
for (var i = 0; i < environments.length; i++) {
	environments[i] = environments[i].trim();
}

var body = {
	email: current.variables.root_user.email.getDisplayValue().toString(),
	project_name: current.variables.project_name.getDisplayValue().toString(),
	environments: environments
};

workflow.info("Message Body: " + JSON.stringify(body));
var sqs = new SQSClient();
var result = sqs.sendMessage({
    QueueUrl: gs.getProperty('grace.sqs_url'),
    MessageBody: JSON.stringify(body)
});

workflow.info("HTTP Status: " + result.getStatusCode());
workflow.info("Body: " + result.getBody());
