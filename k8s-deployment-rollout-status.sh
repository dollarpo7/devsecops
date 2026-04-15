#!/bin/bash

#k8s-deployment-rollout-status.sh

if [[ $(kubectl -n default rollout status deploy ${deploymentName} --timeout 180s) != *"successfully rolled out"* ]]; 
then     
	echo "Deployment ${deploymentName} Rollout has Failed"
	kubectl -n default get pods -o wide
	kubectl -n default describe deploy ${deploymentName}
    kubectl -n default rollout undo deploy ${deploymentName}
    exit 1;
else
	echo "Deployment ${deploymentName} Rollout is Success"
fi