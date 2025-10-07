import os
import sys
import base64
import json
import requests
import secrets
import threading
import webbrowser
import time

from utils.utils import ERROR_PAGE_SOURCE, app, run_server, HOST, PORT, SUCCESS_PAGE_SOURCE


def main():
    output_file = "config/ds_access_token.txt"
    api_account_id_file = "config/API_ACCOUNT_ID"

    # Check relative paths if files don't exist
    if not os.path.exists(output_file):
        output_file = "../config/ds_access_token.txt"
        api_account_id_file = "../config/API_ACCOUNT_ID"

    state = secrets.token_hex(5)
    client_id = os.getenv("INTEGRATION_KEY")
    client_secret = os.getenv("SECRET_KEY")
    target_account_id = os.getenv("TARGET_ACCOUNT_ID")

    authorization_endpoint = "https://account-d.docusign.com/oauth/"
    redirect_uri = f"http://{HOST}:{PORT}/authorization-code/callback"
    scope = "signature aow_manage"

    # Auth URL
    authorization_url = (
        f"{authorization_endpoint}auth?"
        f"response_type=code&scope={scope}"
        f"&client_id={client_id}"
        f"&state={state}"
        f"&redirect_uri={redirect_uri}"
    )

    print("\nOpen the following URL in a browser to continue:\n" + authorization_url + "\n")

    # Open browser
    webbrowser.open(authorization_url)

    # Start Flask server in a separate thread
    server_thread = threading.Thread(target=run_server, daemon=True)
    server_thread.start()

    # Wait for callback
    print("Waiting for authorization code...")

    from flask import render_template_string, request

    auth_data = {}

    @app.route("/authorization-code/callback", methods=["GET"])
    def handle_callback():
        nonlocal auth_data
        code = request.args.get("code")
        received_state = request.args.get("state")

        if code and received_state == state:
            auth_data = {"code": code, "state": received_state}

            return render_template_string(SUCCESS_PAGE_SOURCE, host=HOST, port=PORT)
        else:
            return render_template_string(ERROR_PAGE_SOURCE)

    # Wait until code is received
    while not auth_data:
        time.sleep(1)

    code = auth_data["code"]
    print("\nGetting an access token...\n")

    # Request access token
    token_url = authorization_endpoint + "token"
    auth_header = base64.b64encode(f"{client_id}:{client_secret}".encode()).decode()

    response = requests.post(
        token_url,
        data={
            "grant_type": "authorization_code",
            "redirect_uri": redirect_uri,
            "code": code,
        },
        headers={"Authorization": f"Basic {auth_header}"},
    )

    token_data = response.json()
    access_token = token_data.get("access_token")
    if not access_token:
        print("Error: failed to retrieve access token")
        sys.exit(1)

    # Save token
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, "w") as f:
        f.write(access_token)
    print(f"\nAccess token has been written to {output_file}\n")

    # Get user info
    userinfo_url = authorization_endpoint + "userinfo"
    userinfo = requests.get(
        userinfo_url, headers={"Authorization": f"Bearer {access_token}"}
    ).json()

    if target_account_id and target_account_id != "{TARGET_ACCOUNT_ID}":
        target_account = next(
            (a for a in userinfo["accounts"] if a["account_id"] == target_account_id),
            None,
        )
        if not target_account:
            raise Exception(f"Targeted Account with Id {target_account_id} not found.")
        api_account_id = target_account["account_id"]
    else:
        default_account = next(
            (a for a in userinfo["accounts"] if a.get("is_default")), None
        )
        api_account_id = default_account["account_id"]

    # Save account ID
    with open(api_account_id_file, "w") as f:
        f.write(api_account_id)

    print(f"Account id: {api_account_id}")
    print(f"Account id has been written to {api_account_id_file}\n")


if __name__ == "__main__":
    main()
