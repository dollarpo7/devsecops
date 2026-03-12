#!/bin/bash

#k8s-deployment.sh

# Reset the image placeholder before substituting (in case it was changed in a previous run)
git checkout -- k8s_deployment_service.yaml 2>/dev/null || true
sed -i "s#replace#${imageName}#g" k8s_deployment_service.yaml
# kubectl -n default get deployment ${deploymentName} > /dev/null

# if [[ $? -ne 0 ]]; then
#     echo "deployment ${deploymentName} doesnt exist"
#     kubectl -n default apply -f k8s_deployment_service.yaml
# else
#     echo "deployment ${deploymentName} exist"
#     echo "image name - ${imageName}"
#     kubectl -n default set image deploy ${deploymentName} ${containerName}=${imageName} --record=true
# fi


kubectl -n default apply -f k8s_deployment_service.yaml