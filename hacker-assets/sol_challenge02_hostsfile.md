# Set Variables for SQL Server
# Replace "sqlsrv74xyx" with your unique SQL Server name
sql_server_fqdn=sqlsrv74xyx.database.windows.net
sql_db_name=mydb
sql_username=sqladmin
sql_password='demo!pass123'

# Update hosts entry
sudo -- sh -c "echo '10.0.2.4  sqlsrv74xyx.database.windows.net' >> /etc/hosts"

# Set Variables for IaaS-based workload
api_image='erjosito/yadaapi:1.0'

# Stop and remove existing container
sudo docker stop api
sudo docker rm api

# Run the container
sudo docker run --restart always -d -p 8080:8080 -e "SQL_SERVER_FQDN=$sql_server_fqdn" -e "SQL_SERVER_USERNAME=$sql_username" -e "SQL_SERVER_PASSWORD=$sql_password" --name api $api_image