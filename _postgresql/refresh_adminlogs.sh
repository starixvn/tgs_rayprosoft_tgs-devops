#!/bin/bash
export PGPASSWORD='wXfrQBjK4XYFY3KH6D2D'
export PGHOST='16.162.237.128'
export PGPORT='5433'
export PGUSER='postgres'

result=$(psql -d $1 -c "select count(1) from log.admin_logs where recorded_on >= CURRENT_TIMESTAMP - interval '$3 minutes'")
result2=${result//-/}
result3=${result2/count /}
result4=${result3/\(1 row\)/}
echo $result
echo $result4

if [ $result4 = "0" ]; then
        for p in $(kubectl -n $2 get pods | grep backoffice-api | awk '{print $1}'); do kubectl delete pod $p -n $2 --grace-period=0 --force;done
        echo "Staging Executed"
        curl "https://api.telegram.org/bot1780137038:AAHDIVxs2somlHZ5QbZKq1X403NnWAPXVn4/sendMessage?chat_id=-1001114115188&text=$2%20adminlogs%20updated"
fi

result=$(psql -d $1 -c "select count(1) from log.api_logs where recorded_on >= CURRENT_TIMESTAMP - interval '$3 minutes'")
result2=${result//-/}
result3=${result2/count /}
result4=${result3/\(1 row\)/}
echo $result
echo $result4

if [ $result4 = "0" ]; then
        for p in $(kubectl -n $2 get pods | grep log-api | awk '{print $1}'); do kubectl delete pod $p -n $2 --grace-period=0 --force;done
        echo "Staging Executed"
        curl "https://api.telegram.org/bot1780137038:AAHDIVxs2somlHZ5QbZKq1X403NnWAPXVn4/sendMessage?chat_id=-1001114115188&text=$2%20apilogs%20updated"
fi