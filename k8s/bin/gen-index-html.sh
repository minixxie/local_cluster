#!/bin/bash

tmp=$(mktemp /tmp/XXXXXX)
mv "$tmp" "$tmp".html
tmp="$tmp".html

grafanaPwd=$(kubectl get secret -n tools grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)
mysqlPwd=$(kubectl get secret --namespace db mysql -o jsonpath="{.data.mysql-root-password}" | base64 -d)
postgresqlPwd=$(kubectl get secret --namespace db postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)

time=$(TZ=UTC date +"%Y-%m-%d %H:%M:%SZ")

cat <<EOF > "$tmp"
<html>
<head>
<style>
div.xterm {
	background-color: #000000;
	font-family: "Courier New", Courier, "Lucida Sans Typewriter", "Lucida Typewriter", monospace;
	color: #ffffff;
	padding: 10px 5px;
}
</style>
</head>
<body>

<h3>Generated at: $time</h3>
<table border="1">
	<tr>
		<td>Grafana</td>
		<td>
			<a target="_blank" href="http://grafana.minikube/">http://grafana.minikube/</a><br />
			user: admin<br />
			pass: $grafanaPwd<br />
		</td>
	</tr>
	<tr>
		<td>MySQL</td>
		<td>
			root pass: $mysqlPwd<br />
			<br />
			<div class="xterm">
			kubectl run mysql-client --rm --tty -i --restart='Never' --image  docker.io/bitnami/mysql:8.0.31-debian-11-r10 --namespace db --env MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace db mysql -o jsonpath="{.data.mysql-root-password}" | base64 -d) --command -- bash -c 'mysql -h mysql.db.svc.cluster.local -uroot -p"\$MYSQL_ROOT_PASSWORD"'
			</div>
			OR
			<div class="xterm">
			cd mysql/ && make cli
			</div>
		</td>
	</tr>
	<tr>
		<td>PostgreSQL</td>
		<td>
			root pass: $postgresqlPwd<br />
			<br />
			<div class="xterm">
			kubectl run postgresql-client --rm --tty -i --restart='Never' --namespace db --image docker.io/bitnami/postgresql:11.13.0-debian-10-r0 --env="PGPASSWORD=\$(kubectl get secret --namespace db postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)" --command -- psql --host postgresql -U postgres -d postgres -p 5432
			</div>
			OR
			<div class="xterm">
			cd postgresql/ && make cli
			</div>
		</td>
	</tr>

</table>

</body>
</html>
EOF

open "$tmp"
sleep 5 && rm -f "$tmp"
