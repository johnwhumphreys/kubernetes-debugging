# Put your namespace and pod name here.
NAMESPACE="<your-namespace>"
POD="<your-pod>"

# Get the node for the pod.
NODE=$(kubectl get pod -n $NAMESPACE $POD -o=custom-columns=NODE:.spec.nodeName --no-headers)

# Get the instance ID from the node name.
INSTANCE_ID=$(kubectl get node $NODE -o jsonpath='{.spec.providerID}' | cut -d'/' -f5)

# Get the subnet ID used by the node.
SUBNET_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[].Instances[].SubnetId' --output text)

# Get the free IPs for that subnet-id.
echo "Pod's node runs on subnet-id = $SUBNET_ID, checking available IPs."
aws ec2 describe-subnets --subnet-ids $SUBNET_ID --query 'Subnets[*].{AvailableIPs:AvailableIpAddressCount, TotalIPs:CidrBlock}' --output text
