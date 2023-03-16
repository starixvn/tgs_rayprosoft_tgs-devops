#!/bin/bash
table=$(psql -d tgs -t << EOF
    SELECT 'analyze verbose TABLE ' || N.nspname || '.' || quote_ident(relname) || ' /*' || pg_size_pretty(pg_total_relation_size(C.oid)) || '*/;'
    FROM pg_class C
    LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
    WHERE nspname in ('bet')
      AND C.relkind = 'r'
      AND nspname !~ '^pg_toast'
    ORDER BY pg_total_relation_size(C.oid) ASC;"
EOF
)

IFS=$'\n'
count=0
for row in ${table};do
        count=$((count+1))
        echo "count=${count}"
        echo ${row}
done