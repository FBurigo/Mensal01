# Saídas dos comandos no Minikube

Capturadas em 2026-10-17 15:59 (Minikube v1.39.0, Kubernetes v1.37.0).

## kubectl get pods -o wide -n estante
```
NAME                        READY   STATUS      RESTARTS        AGE     IP            NODE       NOMINATED NODE   READINESS GATES
backend-849fdfffcd-7zkxv    1/1     Running     0               47s     10.244.0.14   minikube   <none>           <none>
backend-849fdfffcd-887gn    1/1     Running     0               31s     10.244.0.15   minikube   <none>           <none>
backend-migrate-6ljmv       0/1     Completed   4 (5m33s ago)   7m17s   10.244.0.5    minikube   <none>           <none>
frontend-5c4d775847-hdfp6   1/1     Running     0               3m50s   10.244.0.9    minikube   <none>           <none>
frontend-5c4d775847-hhb4s   1/1     Running     0               3m43s   10.244.0.10   minikube   <none>           <none>
mysql-6b4c84bf84-w5r9r      1/1     Running     0               2m57s   10.244.0.11   minikube   <none>           <none>
```

## kubectl get services -n estante
```
NAME       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
backend    ClusterIP   10.105.47.132    <none>        8000/TCP       7m17s
frontend   NodePort    10.107.178.111   <none>        80:30080/TCP   7m16s
mysql      ClusterIP   10.107.168.150   <none>        3306/TCP       7m18s
```

## kubectl get deployments -n estante
```
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
backend    2/2     2            2           7m17s
frontend   2/2     2            2           7m16s
mysql      1/1     1            1           7m19s
```

## Balanceamento de carga (10 requisições a /api/version)
```
      8 x-served-by: backend-849fdfffcd-7zkxv
      2 x-served-by: backend-849fdfffcd-887gn
```

## Autocura: exclusão de um Pod do backend
```
$ kubectl delete pod/backend-849fdfffcd-7zkxv -n estante
pod "backend-849fdfffcd-7zkxv" deleted from estante namespace
NAME                       READY   STATUS              RESTARTS   AGE
backend-849fdfffcd-7zkxv   1/1     Terminating         0          49s
backend-849fdfffcd-887gn   1/1     Running             0          33s
backend-849fdfffcd-gw7x2   0/1     ContainerCreating   0          0s
--- segundos depois ---
NAME                       READY   STATUS    RESTARTS   AGE
backend-849fdfffcd-887gn   1/1     Running   0          39s
backend-849fdfffcd-gw7x2   1/1     Running   0          6s
```

## Escala: kubectl scale deployment backend --replicas=3
```
deployment.apps/backend scaled
deployment "backend" successfully rolled out
NAME                       READY   STATUS    RESTARTS   AGE
backend-849fdfffcd-887gn   1/1     Running   0          45s
backend-849fdfffcd-gw7x2   1/1     Running   0          12s
backend-849fdfffcd-nqvt7   1/1     Running   0          6s
```
