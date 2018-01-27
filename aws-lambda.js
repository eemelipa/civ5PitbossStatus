'use strict';

console.log('Loading function');

const aws = require('aws-sdk');
var ses = new aws.SES({
	region: 'us-east-1'
});

const s3 = new aws.S3({ apiVersion: '2006-03-01' });


exports.handler = (event, context, callback) => {
	//console.log('Received event:', JSON.stringify(event, null, 2));

	// Get the object from the event and show its content type
	const bucket = event.Records[0].s3.bucket.name;
	const fileName = event.Records[0].s3.object.key;
	console.log("Got filename " + fileName)

	const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
	const params = {
		Bucket: bucket,
		Key: key,
	};

	// Send turn changed email
	var eParams = {
		Destination: {
			BccAddresses: ["my.name@email.com"]
		},
		Message: {
			Body: {
				Text: {
					Data: "Civ turn changed! Go and play! Find the server address from http://mywebsite.com/"
				}
			},
			Subject: {
				Data: "Civilization 5 Turn Notification: Game 'My Game'"
			}
		},
		Source: "civ5@mywebsite.com"
	};

	if (fileName === "turn_changed.txt") {
		console.log('===SENDING EMAIL===');
		ses.sendEmail(eParams, function (err, data) {
			if (err) console.log(err);
			else {
				console.log("===EMAIL SENT===");
				//console.log(data);

				console.log("EMAIL CODE END");
				context.succeed(event);
			}
		});
	}

	// Get file from s3
	if (false) {
		s3.getObject(params, (err, data) => {
			if (err) {
				console.log(err);
				const message = `Error getting object ${key} from bucket ${bucket}. Make sure they exist and your bucket is in the same region as this function.`;
				console.log(message);
				callback(message);
			}
			else {
				//console.log('Data obj:' + JSON.stringify(data, null, 2))
				console.log('CONTENT TYPE:', data.ContentType);
				callback(null, data.ContentType);
			}
		});
	}
};
