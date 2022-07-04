#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install java-openjdk11 -y
curl -L -O https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-8.20.10-x64.bin
chmod u+x atlassian-jira-software-8.20.10-x64.bin
cat <<EOT >> response.varfile
launch.application\$Boolean=false
rmiPort\$Long=8005
app.jiraHome=/var/atlassian/application-data/jira
app.install.service\$Boolean=false
sys.confirmedUpdateInstallationString=false
sys.languageId=en
sys.installationDir=/opt/atlassian/jira
executeLauncherAction\$Boolean=true
httpPort\$Long=8080
portChoice=default
executeLauncherAction\$Boolean=false
EOT
sudo ./atlassian-jira-software-8.20.10-x64.bin -q -varfile response.varfile
sudo mkdir -p /media/atl/jira/shared
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0e02c460cd3d2ede8.efs.us-west-2.amazonaws.com:/ /media/atl/jira/shared
cat <<EOT >> /var/atlassian/application-data/jira/dbconfig.xml
<?xml version="1.0" encoding="UTF-8"?>
<jira-database-config>
<name>defaultDS</name>
<delegator-name>default</delegator-name>
<database-type>postgres72</database-type>
<schema-name>public</schema-name>
<jdbc-datasource>
<url>jdbc:postgresql://demo-jiradb.ck17xzth3uhk.us-west-2.rds.amazonaws.com:5432/jiradb</url>
<driver-class>org.postgresql.Driver</driver-class>
<username>postgres</username>
<password>postgres</password>
<pool-min-size>30</pool-min-size>
<pool-max-size>30</pool-max-size>
<pool-max-wait>30000</pool-max-wait>
<validation-query>select 1</validation-query>
<min-evictable-idle-time-millis>60000</min-evictable-idle-time-millis>
<time-between-eviction-runs-millis>300000</time-between-eviction-runs-millis>
<pool-max-idle>30</pool-max-idle>
<pool-remove-abandoned>true</pool-remove-abandoned>
<pool-remove-abandoned-timeout>300</pool-remove-abandoned-timeout>
<pool-test-on-borrow>false</pool-test-on-borrow>
<pool-test-while-idle>true</pool-test-while-idle>
<connection-properties>tcpKeepAlive=true;socketTimeout=240</connection-properties>
</jdbc-datasource>
</jira-database-config>
EOT
sudo chown jira:jira /var/atlassian/application-data/jira/dbconfig.xml
cat <<EOT >> /var/atlassian/application-data/jira/cluster.properties
jira.node.id = jira-node-$(shuf -i 0-100 -n 1)
jira.shared.home = /media/atl/jira/shared
EOT
sudo chown jira:jira /var/atlassian/application-data/jira/cluster.properties
cd /opt/atlassian/jira/bin
sudo /bin/su -m jira -c "/opt/atlassian/jira/bin/start-jira.sh"
