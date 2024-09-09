# changeListenerStatus - can be used to pause, resume, or restart the listeners (AtomQueue/JMS/Webservice Listener)
# Usage: 
# changeListenerStatus atomId listenerId action (pause|resume|restart|<Other>)

#!/bin/bash

source bin/common.sh

# Required arguments: atomName, atomType, action
ARGUMENTS=(atomName atomType action)
# Optional arguments: processName, componentId
OPT_ARGUMENTS=(processName componentId)

# Input validation
inputs "$@"
if [ "$?" -gt "0" ]; then
    echo "Error: Missing required arguments or invalid input"
    return 255
fi

# Query atom to get atomId and ensure it is online
source bin/queryAtom.sh atomName="$atomName" atomStatus=online atomType="$atomType"

# If componentId is not provided, query process to retrieve it using processName
if [ -z "${componentId}" ]; then
    source bin/queryProcess.sh processName="$processName"
fi

listenerId=$componentId

# Set up the arguments for the API call
ARGUMENTS=(atomId listenerId action)
JSON_FILE=json/changeListenerStatus.json
URL=$baseURL/changeListenerStatus

# Create JSON for the API request
createJSON

# Handle action cases: pause, resume, restart, and custom actions
case "$action" in
    "pause")
        echo "Pausing the listener with ID: $listenerId on Atom: $atomName"
        ;;
    "resume")
        echo "Resuming the listener with ID: $listenerId on Atom: $atomName"
        ;;
    "restart")
        echo "Restarting the listener with ID: $listenerId on Atom: $atomName"
        ;;
    *)
        echo "Handling custom action: $action for listener ID: $listenerId on Atom: $atomName"
        # Optional: Add any custom logic for other actions here
        ;;
esac

# Make the API call
callAPI

# Check if the API call was successful
if [ "$ERROR" -gt "0" ]; then
    echo "Error: API call failed with status code $ERROR"
    return 255
else
    echo "Action '$action' successfully executed for listener ID: $listenerId on Atom: $atomName"
fi
