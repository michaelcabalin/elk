#!/bin/sh

echo "Adding Repo for ELK - Metricbeat"

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

sleep 1s

touch /etc/yum.repos.d/elasticsearch.repo

echo '[elasticsearch-6.x]' >> /etc/yum.repos.d/elasticsearch.repo
echo 'name=Elasticsearch repository for 6.x packages' >> /etc/yum.repos.d/elasticsearch.repo
echo 'baseurl=https://artifacts.elastic.co/packages/6.x/yum' >> /etc/yum.repos.d/elasticsearch.repo
echo 'gpgcheck=1' >> /etc/yum.repos.d/elasticsearch.repo
echo 'gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch' >> /etc/yum.repos.d/elasticsearch.repo
echo 'enabled=1' >> /etc/yum.repos.d/elasticsearch.repo
echo 'autorefresh=1' >> /etc/yum.repos.d/elasticsearch.repo
echo 'type=rpm-md' >> /etc/yum.repos.d/elasticsearch.repo

yum repolist

sleep 2s

yum install -y nano git metricbeat heartbeat-elastic


sed -re 's/localhost:9200/cms01.fj04.swiftserve.com:9200/' -i /etc/metricbeat/metricbeat.yml



sleep 5s
mv /etc/heartbeat/heartbeat.yml /etc/heartbeat/heartbeat.yml_old
sleep 2s
cp cms-heartbeat.yml /etc/heartbeat/
mv /etc/heartbeat/cms-heartbeat.yml /etc/heartbeat/heartbeat.yml
sleep 2s
sed -i -e "s/cms01.fj02.swiftserve.com/$(hostname)/g" /etc/heartbeat/heartbeat.yml
 
sleep 5s

sudo metricbeat setup --template -E 'output.elasticsearch.hosts=["cms01.fj04.swiftserve.com:9200"]' -E setup.kibana.host=cms01.fj04.swiftserve.com:5601

sleep 5s

systemctl start metricbeat
systemctl enable metricbeat
systemctl start heartbeat-elastic
systemctl enable heartbeat-elastic

sleep 5s

curl -XGET 'http://cms01.fj04.swiftserve.com:9200/metricbeat-*/_search?pretty'

echo "ELK Node added to cms01.fj04.swiftserve.com - Completed"

sleep 5s

exit
