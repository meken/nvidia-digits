#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

usage() { echo "Usage: $0 [-i <subscriptionId> -g <resourceGroupName> -l <resourceGroupLocation>] <templateFile>" 1>&2; exit 1; }

declare subscriptionId=""
declare resourceGroupName=""
declare resourceGroupLocation=""

# Initialize parameters specified from command line
while getopts ":i:g:n:l:" arg; do
	case "${arg}" in
		i)
			subscriptionId=${OPTARG}
			;;
		g)
			resourceGroupName=${OPTARG}
			;;
		l)
			resourceGroupLocation=${OPTARG}
			;;
		esac
done
shift $((OPTIND-1))


if [[ -z "$resourceGroupName" ]]; then
	echo "ResourceGroupName:"
	read resourceGroupName
fi


# Template file to be used
templateFilePath=$1

if [[ ! -f "$templateFilePath" ]]; then
	echo "$templateFilePath not found"
	exit 1
fi

# If not running from the portal, login to azure using your credentials
az account show 1> /dev/null

if [[ $? != 0 ]]; then
	az login
fi

if [[ ! -z "$subscriptionId" ]]; then
	az account set --name $subscriptionId
fi

set +e

# Check whether the resource group already exists
az group show -n $resourceGroupName 1> /dev/null

if [[ $? != 0 ]]; then
	echo "Resource group with name" $resourceGroupName "could not be found. Creating new resource group.."

        if [[ -z "$resourceGroupLocation" ]]; then
	     echo "ResourceGroupLocation:"
	     read resourceGroupLocation
        fi

	set -e
	(
		set -x
		az group create --name $resourceGroupName --location $resourceGroupLocation 1> /dev/null
	)
else
	echo "Using existing resource group..."
fi

# Start deployment
echo "Starting deployment..."
(
	set -x
	az group deployment create --name "CLI Deploy $resourceGroupName" --resource-group $resourceGroupName --template-file $templateFilePath 
)

if [[ $?  == 0 ]];
 then
	echo "Template has been successfully deployed"
fi

