# Docusign Developer Labs

Before you begin, create a free [Docusign developer account](https://www.docusign.com/developers/sandbox).

**Optional**: ✨Install the [Docusign Developer AI Assistant for VS Code (Beta)](https://developers.docusign.com/tools/ai-assistant-vs-code/) to get AI-powered answers to your questions along the way. You can use the assistant to ask Docusign-related questions, create integration keys, and generate code.

## Lab 1: Build a Maestro Workflow

For your first task, you'll need to build a <a href="https://support.docusign.com/s/document-item?bundleId=yff1696971835267&topicId=pps1696973636517.html">Maestro Workflow</a> in the Docusign UI.

Follow the steps below to build your workflow:
1. In your developer account, select the **Agreements** tab. Then navigate to **Maestro Workflows** in the left menu.
2. Select **Create Workflow**.
3. Use the **New Canvas** option to create a workflow from scratch, or try one of the other options to create a workflow from a template.
4. Select a [start method](https://support.docusign.com/s/document-item?bundleId=yff1696971835267&topicId=ztb1727892686033.html) for your workflow. Choose **From an API call** if you plan to complete [Lab 2](#lab-2-trigger-your-workflow-through-the-api).
5. Build out your workflow with the [agreement process steps](https://support.docusign.com/s/document-item?bundleId=yff1696971835267&topicId=afu1730332596907.html) that fit your desired use case. Your workflow can be as simple or complex as you like. Feel free to get creative!
Bonus: incorporate the [Slack](https://apps-d.docusign.com/app-center/app/4a5ee6f6-2213-40e0-8ea6-b04714e2a129) or [Salesforce](https://apps-d.docusign.com/app-center/app/2d576583-520a-41e2-886b-089fefe733a1) extension app into your workflow.
6. [Review and publish](https://support.docusign.com/s/document-item?bundleId=yff1696971835267&topicId=iqm1698272226447.html) your workflow.

### 💡Hint
Try using a [workflow template](https://support.docusign.com/s/document-item?bundleId=yff1696971835267&topicId=irb1736981148403.html) to get some inspiration and speed up the workflow configuration process.

### ✅ Validate your work
Once your workflow has been published, you’re ready to test it out. Navigate to **Maestro Workflows** under the **Agreements** tab where you began the lab. Select the three-dot menu for your published workflow and choose **Run Workflow**. Complete the workflow steps and show your work to the lab staff to claim your swag!

## Lab 2: Trigger your workflow through the API

After publishing your workflow, use the [Maestro API](https://developers.docusign.com/docs/maestro-api/maestro101/) to trigger it. 

The skeleton code in this repo gives you a place to start using a Bash shell script and curl to make the API calls. To run this code, you will need to be able to run a bash script, and use either PHP or Python for authentication.

Prefer to work in another environment or programming language? Feel free to write your own code, or use [Postman](https://developers.docusign.com/tools/postman/), to call the Maestro API and trigger a workflow.

### 💡Hint
Check out this [how-to guide](https://developers.docusign.com/docs/maestro-api/how-to/trigger-workflow/) to understand the API calls needed to trigger a workflow.

To run the example program, follow the steps below:
1. Clone this GitHub repository.
2. Log into your developer account and create a new [integration key](https://developers.docusign.com/platform/build-integration/) (IK) on the [Apps and Keys](https://admindemo.docusign.com/authenticate?goTo=appsAndKeys) page.
3. Configure your IK and config file by following the steps below:
    - Copy the settings.example.txt file into a new file named `settings.txt`.
    - Update the value of `INTEGRATION_KEY` with the value of your new integration key, with double quotes around the key.
    - Update the value of `SECRET_KEY` with the value of the secret key in your IK.
    - Copy your **API Account ID** from the apps and keys page and paste it into the value of `TARGET_ACCOUNT_ID`.
    - Add the following redirect URI to your IK: `http://localhost:8080/authorization-code/callback`.
4. Copy the ID of your workflow into the variable in the `TriggerWorkflow.sh` file on line 26.
5. Look for the `TODO` comments in the `TriggerWorkflow.sh` file indicating which API calls need to be filled in. Check the [Maestro API reference](https://developers.docusign.com/docs/maestro-api/reference/) to determine which API calls you need. Getting stuck? Ask the Docusign Developer AI Assistant or check the hint above.
6. Navigate to the cloned repo and run the program with the following command: `bash launcher.sh`.

### ✅ Check your work
If you used our skeleton code:
If your program is running correctly, a browser window should open with your workflow embedded in it. The API responses should print in the terminal, including a response with an instance_url property. Go to that URL to see the workflow instance in a new browser tab.

Show this browser to the lab staff to claim your swag!

If you chose another method:
If you chose not to use the example code and made the API calls through another method, you should have received a response including the instance_url property. Go to that URL to see the workflow instance in a new browser tab.

Show your API response to the lab staff to claim your swag!

### 🛠️ Dreamforce 25 | Share Your Build

Built something cool in the **Docusign Developer Lab** during Dreamforce? Show us what you made.

Post in the [Developer Forum](https://community.docusign.com/developer-59) with a quick summary or screenshot of your workflow, or a code snippet highlighting how you triggered it—and **tag it “DevLab25”** so we can find it.

🎁 The developers of the 10 most impactful builds will each receive a **$150 Loop & Tie** gift of their choice.

Terms & conditions apply—[see this post for details](https://community.docusign.com/general-74/docusign-developer-lab-at-dreamforce25-share-your-build-25685).
Let’s see what you built! 💥

