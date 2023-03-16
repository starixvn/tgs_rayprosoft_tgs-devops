#!/bin/bash
indexes=$(curl https://elasticsearch.srvptt.com/_cat/indices?v&index=log-game*)

for 



curl https://elasticsearch.srvptt.com/_cat/indices?index=log-game*&h=index

 | cut -d ' ' -f2 | sort

curl https://elasticsearch.srvptt.com/_cat/indices?v&index=log-game* | cut -d ' ' -f2 | sort