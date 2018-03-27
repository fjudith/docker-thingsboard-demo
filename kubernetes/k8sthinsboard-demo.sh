#!/bin/bash

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

# Create
if [ -z create ] ; then
  kubectl create namespace thingsboard-demo

  kubectl apply -n thingsboard-demo -f ./thingsboard-demo-deployment.yaml

  kubectl get svc thingsboard-demo -n thingsboard-demo
elif [ -v create ] && [ "$create" == "conduit" ]; then
  kubectl create namespace thingsboard-demo

  cat ./thingsboard-demo-deployment.yaml | conduit inject - | kubectl apply -n thingsboard-demo -f -

  kubectl get svc thingsboard-demo -n thingsboard-demo -o jsonpath="{.status.loadBalancer.ingress[0].*}"

  kubectl get svc thingsboard-demo -n thingsboard-demo
elif [ -v create ] && [ "$create" == "istio" ]; then
  kubectl create namespace thingsboard-demo

  kubectl apply -n thingsboard-demo -f ./thingsboard-demo-deployment.yaml

  export GATEWAY_URL=$(kubectl get po -l istio=ingress -n istio-system -o 'jsonpath={.items[0].status.hostIP}'):$(kubectl get svc istio-ingress -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')

  printf "Istio Gateway: $GATEWAY_URL"
fi


# Delete
if [ -z delete ] || [ "$delete" == "conduit" ]; then
  kubectl delete -n thingsboard-demo -f ./thingsboard-demo-deployment.yaml

  kubectl delete namespace thingsboard-demo
fi

if [ -v delete ] && [ "$delete" == "istio" ]; then
  kubectl delete -n thingsboard-demo -f ./thingsboard-demo-deployment.yaml

  kubectl delete namespace thingsboard-demo
fi