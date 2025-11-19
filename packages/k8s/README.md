# Kubernetes Deployment Setup

## tldr

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.2.1" | kubectl apply -f -
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.2.1/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.2.1/deploy/default/deploy.yaml
kubectl apply -f configmap.yaml -f deployment.yaml -f service.yaml -f ingress.yaml
```

## Prerequisites Installation

Before deploying your application, you need to install NGINX Gateway Fabric on your cluster.

### 1. Install Gateway API CRDs

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml
```

### 2. Install NGINX Gateway Fabric CRDs

```bash
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.2.1" | kubectl apply -f -
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.2.1/deploy/crds.yaml
```

### 3. Deploy NGINX Gateway Fabric

```bash
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.2.1/deploy/default/deploy.yaml
```

### 4. Verify Installation

```bash
kubectl get pods -n nginx-gateway
kubectl get gatewayclass
```

---

## Application Deployment

Once prerequisites are installed, deploy your application in order:

### 1. Apply ConfigMap

```bash
kubectl apply -f configmap.yaml
```

### 2. Apply Deployment

```bash
kubectl apply -f deployment.yaml
```

### 3. Apply Service

```bash
kubectl apply -f service.yaml
```

### 4. Apply Ingress (Gateway + HTTPRoute)

```bash
kubectl apply -f ingress.yaml
```

---

## Verification

Check deployment status:

```bash
# Check all resources
kubectl get all

# Check gateway
kubectl get gateway promo-proy-gateway

# Check HTTPRoute
kubectl describe httproute promo-proy-route

# Check service endpoints
kubectl describe svc promo-proy-svc | grep Endpoints

# Get external IP
kubectl get svc promo-proy-gateway-nginx
```

Test the application:

```bash
EXTERNAL_IP=$(kubectl get svc promo-proy-gateway-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$EXTERNAL_IP
```

---

## Cleanup

Remove application:

```bash
kubectl delete -f ingress.yaml
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
kubectl delete -f configmap.yaml
```

Remove NGINX Gateway Fabric (optional):

```bash
kubectl delete -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.2.1/deploy/default/deploy.yaml
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml
```
