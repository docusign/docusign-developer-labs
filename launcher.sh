#!/bin/bash
set -e

source ./utils/utils.sh

api_version=""

if [ ! -f "config/settings.txt" ]; then
    echo "Error: "
    echo "First copy the file 'config/settings.example.txt' to 'config/settings.txt'."
    echo "Next, fill in your API credentials, Signer name and email to continue."
    echo ""
    exit 1
fi

if [ -f "config/settings.txt" ]; then
    . config/settings.txt
fi

export LANGUAGE_CHOICE=""

function authenticate() {
    echo ""
    echo "Choose an OAuth Strategy."
    PS3="Please make a selection: "
    select LANGUAGE in \
        "PHP" \
        "Python" \
        "Exit"; do
        case "$LANGUAGE" in 

        \
            PHP)
                if isCommandAvailable "php"; then
                    LANGUAGE_CHOICE="PHP"
                    php ./OAuth/code_grant.php
                    return
                else
                    echo "PHP is not available. Please install it or use different OAuth Strategy"
                    authenticate
                fi
                return
                ;;

            Python)
                # Ensure the requirements for Python Strategy are satisfied
                ensurePackage "Flask"
                ensurePackage "requests"

                if isCommandAvailable "python3"; then
                    LANGUAGE_CHOICE="python3"
                    python3 -m OAuth.code_grant
                    return
                elif isCommandAvailable "python"; then
                    LANGUAGE_CHOICE="python"
                    python -m OAuth.code_grant
                    return
                else
                    echo "Python is not available. Please install it or use different OAuth Strategy"
                    authenticate
                fi
                return
                ;;

        Exit)
            exit 0
            ;;
        esac
    done
}

echo ""
echo "Welcome to the Docusign Trigger Workflow Scenario"
authenticate

bash TriggerWorkflow.sh
