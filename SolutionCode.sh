#!/bin/bash

source ./utils/utils.sh

# Trigger a new instance of a workflow
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Obtain your OAuth token. This is handled for you by the shell program.
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
account_id=$(cat config/API_ACCOUNT_ID)
base_path="https://api-d.docusign.com/v1"

# Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")

# Copy your workflow ID into the variable below
# Hint: Get your workflow ID from the Maestro UI or through an API call
workflow_id='YOUR_WORKFLOW_ID'

# Get the trigger URL of your workflow
response=$(mktemp /tmp/response-wftmp.XXXXXX)
Status=$(curl -s -w "%{http_code}\n" -i --request GET "${base_path}/accounts/${account_id}/workflows/${workflow_id}/trigger-requirements" \
    "${Headers[@]}" \
    --output ${response})

# If the status code returned is greater than 201 (OK / Accepted), display an error message with the API response.
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to get the trigger requirements of the specified workflow ${workflow_id}"
    echo ""
    cat $response
    exit 0
fi

cat $response
echo ""

# Decoding the trigger URL so it can be used in the the next API call
trigger_url=$(grep '"url":' $response | sed -n 's/.*"url": "\([^"]*\)".*/\1/p')
decoded_trigger_url=$(echo $trigger_url | sed 's/\\u0026/\&/g')


# Construct your request body with the required trigger inputs for your workflow
# Hint: Find the structure of the trigger inputs in the response of your API call to get the trigger requirements
request_data=$(mktemp /tmp/request-wf-001.XXXXXX)
instance_name='New Instance'
printf \
'{
  "instance_name": "'"$instance_name"'",
  "trigger_inputs": {
  }
}' >$request_data


response=$(mktemp /tmp/response-wftmp.XXXXXX)
# The ${decoded_trigger_url} variable is extracted from the response from a previous API call  
# to the Workflows: getWorkflowTriggerRequirements endpoint.
Status=$(curl -s -w "%{http_code}\n" -i --request POST ${decoded_trigger_url} \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})


instance_id=$(grep '"instance_id":' $response | sed -n 's/.*"instance_id": "\([^"]*\)".*/\1/p')
# Store the instance_id into the config file
echo "${instance_id}" > config/INSTANCE_ID

echo ""
echo "Response:"
cat $response
echo ""

instance_url=$(grep '"instance_url":' $response | sed -n 's/.*"instance_url": "\([^"]*\)".*/\1/p')
decoded_instance_url=$(echo $instance_url | sed 's/\\u0026/\&/g')
echo "$decoded_instance_url" > config/INSTANCE_URL

echo ""
echo "Use this URL to complete the workflow steps:"
echo $decoded_instance_url

sleep 3

echo ""
echo "Opening a browser with the embedded workflow..."

sleep 5

# [Optional] Launch local server and embed workflow instance using the instance URL
embedWorkflow "$decoded_instance_url"

# Remove the temporary files
rm "$request_data"
rm "$response"