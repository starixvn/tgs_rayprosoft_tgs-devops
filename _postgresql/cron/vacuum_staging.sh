#!/bin/bash
tables=$(psql -U postgres -d $db -c "select schemaname || '.' || tablename as tablename from pg_tables where schemaname in ('dbo','bet','report') order by schemaname, tablename;" |grep -v "tablename")

for table in $tables
do
        if [[ "$table" == *"("* ]] || [[ "$table" == *")"* ]]  ; then
           continue;
        fi

        echo "vacuum verbose analyze $table;"
        psql -U postgres -d $db -c "vacuum analyze $table;"
        echo "table $table has finished vacuum"
done
