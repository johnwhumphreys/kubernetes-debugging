# Get the number of pods in each state across all namespaces in the cluster.
# This is a good initial check - you can see pending pods, Error pods, pods in crash loops,
# or pile-ups of completed pods that are not being removed, etc.
kubectl get pods --no-headers -A -o custom-columns=NODE:.status.phase | sort | uniq -c | sort -nr

# Get the pods per node in a given status (Pending in this case).
# This helps you track pods in a given state to specific nodes so you can find root causes (likely infra issues).
kubectl get pods -A -o custom-columns=NODE:.spec.nodeName --field-selector=status.phase=Pending | sort | uniq -c | sort -n  | tail -10

# Get the 10 nodes running the most pods.
# Often nodes running more pods have more issues, especailly if lots of ephemeral pods come up and donw.
# E.g. memory overuse if limits are not well set, EBS burst credit overuse, PLEG slow-downs, open files count issues
# depending on types of pods being run.
kubectl get pods -A -o custom-columns=NODE:.spec.nodeName | sort | uniq -c | sort -n  | tail -10l

# Get the 10 nodes running the least pods.
# Useful while trying to remove nodes for cost optimization or during releases.  Remember, most nodes have multiple
# pods for the normal system daemon sets that keep kubernetes running, so there is a base count unrelatd to your apps.
kubectl get pods -A -o custom-columns=NODE:.spec.nodeName | sort | uniq -c | sort -nr  | tail -10l

# Get the number of pods per namespace (spot your biggest namespaces).
kubectl get pods -A | awk '{print $1}' | sort | uniq -c | sort -nr  | head -5
