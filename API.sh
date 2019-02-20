#Add user Admin 
zbxUser='Admin'
#Put password
zbxPass='zabbix'
#Location API
zbxAPI='http://192.168.55.55/zabbix/api_jsonrpc.php'
agentIP=`ifconfig enp0s8 | grep inet | awk '{print $2}' | cut -d':' -f2`
agentHost=$1
# Get authentificate token from zabbix
function authenticate(){
	curl -i -X POST -H 'Content-Type: application/json-rpc' -d "{\"params\": {\"password\": \"$zbxPass\", \"user\": \"$zbxUser\"}, \"jsonrpc\":\"2.0\", \"method\": \"user.login\", \"id\": 0}" $zbxAPI | grep -Eo 'Set-Cookie: zbx_sessionid=.+' | head -n 1 | cut -d '=' -f 2 | tr -d '\r'
}
}
authToken=$(authenticate)
#Getting OS Linux ID
templ=`curl -sS -i -X POST -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\", \"method\": \"template.get\",\"params\":{ \"filter\": {\"host\" : [ \"Template OS Linux\"] } }, \"auth\":\"$authToken\",  \"id\": 1}" $zbxAPI`
templid=`echo $templ| grep -oP '(?<=templateid":")[^ ]*' | cut -f1 -d"\""`
echo $templid
#Getting Linux Servers ID
group=`curl -sS -i -X POST -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\", \"method\": \"hostgroup.get\",\"params\":{ \"filter\": {\"name\" : [ \"Linux Servers\"] } }, \"auth\":\"$authToken\",  \"id\": 2}" $zbxAPI`
groupid=`echo $group|grep -oP '(?<=id":)[^ ]*' | cut -f1 -d"\"" | cut -c-1`
echo $groupid
#Creating host
curl -i -X POST -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\", \"method\": \"host.create\",\"params\": { \"host\": \"$agentHost\", \"interfaces\": [ { \"type\": 1, \"main\": 1,\"useip\": 1,\"ip\": \"$agentIP\",\"dns\":\"\",\"port\": 10050 } ],\"groups\": [ {\"groupid\": \"$groupid\"} ],\"templates\": [ {\"templateid\": \"$templid\"} ]},\"auth\":\"$authToken\", \"id\": 3}" $zbxAPI

