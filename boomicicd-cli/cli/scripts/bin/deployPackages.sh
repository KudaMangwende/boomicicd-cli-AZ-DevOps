#!/bin/bash

source bin/common.sh

# Mandatory arguments
ARGUMENTS=(env packageVersion notes listenerStatus) 
OPT_ARGUMENTS=(componentIds processNames extractComponentXmlFolder tag componentType)
inputs "$@"
if [ "$?" -gt "0" ]; then
    return 255;
fi

# Prepare folders if needed
if [ ! -z "${extractComponentXmlFolder}" ]; then
    folder="${WORKSPACE}/${extractComponentXmlFolder}"
    rm -rf ${folder}
    unset extensionJson
    saveExtractComponentXmlFolder="${extractComponentXmlFolder}"
fi

# Save initial parameters
saveNotes="${notes}"
savePackageVersion="${packageVersion}"
saveListenerStatus="${listenerStatus}"
saveComponentType="${componentType}"
saveTag="${tag}"
unset tag

# Query environment details
source bin/queryEnvironment.sh env="$env" classification="*"
saveEnvId=${envId}

# Handle processes or components
if [ -z "${componentIds}" ]; then
    IFS=','; for processName in `echo "${processNames}"`; do
        notes="${saveNotes}"
        deployNotes="${saveNotes}"
        packageVersion="${savePackageVersion}"
        processName=`echo "${processName}" | xargs`
        saveProcessName="${processName}"
        listenerStatus="${saveListenerStatus}"
        componentType="${saveComponentType}"
        envId=${saveEnvId}

        # Create and deploy package
        source bin/createSinglePackage.sh processName="${processName}" componentType="${componentType}" packageVersion="${packageVersion}" notes="${notes}" extractComponentXmlFolder="${extractComponentXmlFolder}" componentVersion=""
        source bin/createDeployedPackage.sh envId=${envId} listenerStatus="${listenerStatus}" packageId=$packageId notes="${deployNotes}"

        # Change listener status for specific process
        ./changeListenerStatus ${envId} ${packageId} ${listenerStatus}
    done   
else    
    IFS=','; for componentId in `echo "${componentIds}"`; do
        notes="${saveNotes}"
        deployNotes="${saveNotes}"
        packageVersion="${savePackageVersion}"
        componentId=`echo "${componentId}" | xargs`
        saveComponentId="${componentId}"
        componentType="${saveComponentType}"
        listenerStatus="${saveListenerStatus}"
        envId=${saveEnvId}

        # Create and deploy package
        source bin/createSinglePackage.sh componentId=${componentId} componentType="${componentType}" packageVersion="${packageVersion}" notes="${notes}" extractComponentXmlFolder="${extractComponentXmlFolder}" componentVersion=""
        source bin/createDeployedPackage.sh envId=${envId} listenerStatus="${listenerStatus}" packageId=$packageId notes="${deployNotes}"

        # Change listener status for specific component
        ./changeListenerStatus ${envId} ${componentId} ${listenerStatus}
    done   
fi  

# Tag all the packages of the release together
handleXmlComponents "${saveExtractComponentXmlFolder}" "${saveTag}" "${saveNotes}"
export envId=${saveEnvId}

# Handle any errors
if [ "$ERROR" -gt 0 ]; then
   return 255;
fi

clean
