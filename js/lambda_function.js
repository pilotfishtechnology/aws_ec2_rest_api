// Lambda function code
// Load the AWS SDK for Node.js
var AWS = require('aws-sdk');
// Set the region 
AWS.config.update({ region: 'us-east-1' });
// Create EC2 service object
var ec2 = new AWS.EC2({ apiVersion: '2016-11-15' });
// A list of EC2 ID’s that can be accessed via the script
var ec2Instances = ["i-123"];
// A "secret" token
var token = "123"

module.exports.handler = async (event) => {

  let requestFailure = false;
  let responseMessage = 'Request Successful';
  try {
    console.log('Event: ', event);

    if (event.queryStringParameters['token'] != token) {
      requestFailure = true;
      responseMessage = 'Missing/Invalid token variable';
    }

    if (!(ec2Instances.indexOf(event.queryStringParameters['id']) > -1)) {
      requestFailure = true;
      responseMessage = 'Missing/Invalid id variable';
    }

    if (event.queryStringParameters['action'] != 'stop' && event.queryStringParameters['action'] != 'start') {
      requestFailure = true;
      responseMessage = 'Missing/Invalid action variable';
    }

    if (!requestFailure) {
      // setup instance params
      const params = {
        InstanceIds: [
          event.queryStringParameters['id']
        ]
      };
      console.log('params: ', params);
      if (event.queryStringParameters['action'] == 'start') {
        await ec2.startInstances(params).promise().then((response) => {
          console.log("Instance Start Success with ", response);
        })
      }
      if (event.queryStringParameters['action'] == 'stop') {
        await ec2.stopInstances(params).promise().then((response) => {
          console.log("Instance Stop Success with ", response);
        })
      }
    }
  } catch (error) {
    console.log("SystemError", error);
    requestFailure = true;
    responseMessage = 'System Failure - Please check logs';
  }

  return {
    statusCode: requestFailure ? 500 : 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      code: requestFailure ? 500 : 200,
      message: responseMessage,
    }),
  }
}
