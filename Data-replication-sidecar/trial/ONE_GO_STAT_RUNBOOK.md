MySQL Replication One-Go Runbook (stat namespace)

Use this runbook to reset and redeploy in one pass on low-resource clusters.

## 0) Variables

```bash
NS=stat
ROOT_PWD='RootPass!123'
REPL_USER='repl'
REPL_PWD='repl123'
MASTER_HOST='mysql-0.mysql-headless.stat.svc.cluster.local'
APP_USER='appuser'
APP_PWD='AppPass123!'
```

## 1) Fresh reset

```bash
kubectl create namespace $NS --dry-run=client -o yaml | kubectl apply -f -

kubectl -n $NS delete deploy mysql-rw-gateway --ignore-not-found
kubectl -n $NS delete sts mysql --ignore-not-found
kubectl -n $NS delete svc mysql mysql-headless mysql-write mysql-read mysql-rw-gateway --ignore-not-found
kubectl -n $NS delete pvc data-mysql-0 data-mysql-1 data-mysql-2 --ignore-not-found
kubectl -n $NS delete secret mysql-secret --ignore-not-found
kubectl -n $NS delete configmap mysql-config --ignore-not-found
```

Optional only if old credentials still persist on replicas:

```bash
sudo rm -rf /var/lib/mysql-demo/mysql-1 /var/lib/mysql-demo/mysql-2
```

## 2) Apply manifests

Run from this folder: UST-Material/Data-replication-Manual/k8s

```bash
kubectl apply -f 02-secret.yaml
kubectl apply -f 03-configmap.yaml
kubectl apply -f 04-services.yaml -n $NS
kubectl apply -f 06-pv.yaml
kubectl apply -f 05-statefulset.yaml
```

## 3) Wait for MySQL pods

```bash
kubectl -n $NS get pods -w
```

Expected:
- mysql-0 Running
- mysql-1 Running
- mysql-2 Running

If any pod is Pending:

```bash
kubectl -n $NS describe pod mysql-1
kubectl -n $NS describe pod mysql-2
kubectl -n $NS get events --sort-by=.lastTimestamp | tail -n 40
```

## 4) Baseline checks

```bash
kubectl -n $NS exec mysql-0 -- env MYSQL_PWD="$ROOT_PWD" mysql --no-defaults -uroot -e "SELECT VERSION(); SHOW VARIABLES LIKE 'server_id'; SHOW VARIABLES LIKE 'log_bin';"
kubectl -n $NS exec mysql-1 -- env MYSQL_PWD="$ROOT_PWD" mysql --no-defaults -uroot -e "SHOW VARIABLES LIKE 'server_id';"
kubectl -n $NS exec mysql-2 -- env MYSQL_PWD="$ROOT_PWD" mysql --no-defaults -uroot -e "SHOW VARIABLES LIKE 'server_id';"
```

## 5) Create users and schema on master

```bash
kubectl -n $NS exec mysql-0 -- env MYSQL_PWD="$ROOT_PWD" mysql --no-defaults -uroot -e "CREATE USER IF NOT EXISTS '$REPL_USER'@'%' IDENTIFIED BY '$REPL_PWD'; ALTER USER '$REPL_USER'@'%' IDENTIFIED BY '$REPL_PWD'; GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO '$REPL_USER'@'%'; FLUSH PRIVILEGES;"

kubectl -n $NS exec mysql-0 -- env MYSQL_PWD="$ROOT_PWD" mysql --no-defaults -uroot -e "CREATE DATABASE IF NOT EXISTS appdb; CREATE USER IF NOT EXISTS '$APP_USER'@'%' IDENTIFIED BY '$APP_PWD'; ALTER USER '$APP_USER'@'%' IDENTIFIED BY '$APP_PWD'; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX ON appdb.* TO '$APP_USER'@'%'; FLUSH PRIVILEGES;"
```

## 6) Configure replication (MySQL 8 syntax)

```bash
kubectl -n $NS exec mysql-1 -- env MYSQL_PWD="$ROOT_PWD" mysql --no-defaults -uroot -e "STOP REPLICA; RESET REPLICA ALL; CHANGE REPLICATION SOURCE TO SOURCE_HOST='$MASTER_HOST', SOURCE_PORT=3306, SOURCE_USER='$REPL_USER', SOURCE_PASSWORD='$REPL_PWD', SOURCE_AUTO_POSITION=1; START REPLICA;"

kubectl -n $NS exec mysql-2 -- env MYSQL_PWD="$ROOT_PWD" mysql --no-defaults -uroot -e "STOP REPLICA; RESET REPLICA ALL; CHANGE REPLICATION SOURCE TO SOURCE_HOST='$MASTER_HOST', SOURCE_PORT=3306, SOURCE_USER='$REPL_USER', SOURCE_PASSWORD='$REPL_PWD', SOURCE_AUTO_POSITION=1; START REPLICA;"
```

## 7) Validate replication

```bash
kubectl -n $NS exec mysql-1 -- env MYSQL_PWD="$ROOT_PWD" mysql --no-defaults -uroot -e "SHOW REPLICA STATUS\\G"
kubectl -n $NS exec mysql-2 -- env MYSQL_PWD="$ROOT_PWD" mysql --no-defaults -uroot -e "SHOW REPLICA STATUS\\G"
```

Success fields:
- Replica_IO_Running: Yes
- Replica_SQL_Running: Yes

## 8) Data proof

```bash
kubectl -n $NS exec mysql-0 -- env MYSQL_PWD="$ROOT_PWD" mysql --no-defaults -uroot -e "CREATE TABLE IF NOT EXISTS appdb.seed_data(id INT PRIMARY KEY AUTO_INCREMENT, message VARCHAR(255), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP); INSERT INTO appdb.seed_data(message) VALUES ('one-go demo row'); SELECT * FROM appdb.seed_data ORDER BY id DESC LIMIT 5;"

kubectl -n $NS exec mysql-1 -- env MYSQL_PWD="$ROOT_PWD" mysql --no-defaults -uroot -e "SELECT * FROM appdb.seed_data ORDER BY id DESC LIMIT 5;"
kubectl -n $NS exec mysql-2 -- env MYSQL_PWD="$ROOT_PWD" mysql --no-defaults -uroot -e "SELECT * FROM appdb.seed_data ORDER BY id DESC LIMIT 5;"
```

## 9) Deploy gateway

```bash
kubectl -n $NS apply -f 07-fastapi-gateway.yaml
kubectl -n $NS set env deploy/mysql-rw-gateway DB_USER=$APP_USER DB_PASSWORD=$APP_PWD
kubectl -n $NS rollout restart deploy/mysql-rw-gateway
kubectl -n $NS rollout status deploy/mysql-rw-gateway
```

## 10) Gateway checks

```bash
kubectl -n $NS run curltest --rm -it --image=curlimages/curl --restart=Never -- curl -sS http://mysql-rw-gateway/health
```

Local port-forward demo:

```bash
kubectl -n $NS port-forward svc/mysql-rw-gateway 8080:80
```

```bash
curl http://127.0.0.1:8080/health
curl -X POST http://127.0.0.1:8080/messages -H "Content-Type: application/json" -d '{"message":"hello from one-go"}'
curl http://127.0.0.1:8080/messages
```
