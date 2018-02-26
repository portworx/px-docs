Monitor the portworx pods

```bash
kubectl get pods -o wide -n kube-system -l name=portworx
```

Monitor Portworx cluster status

```bash
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status
```

If you are still experiencing issues, please refer to [Troubleshooting PX on Kubernetes](/scheduler/kubernetes/support.html) and [General FAQs](/knowledgebase/faqs.html).