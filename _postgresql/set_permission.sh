#!/bin/bash
psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA dbo TO tgs_app;"
psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA dbo TO tgs_app;"
psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA dbo TO tgs_app;"

psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA dbo TO tgs_migration;"
psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA dbo TO tgs_migration;"
psql -d $1 -c "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA dbo TO tgs_migration;"

psql -d $1 -c "GRANT select ON ALL TABLES IN SCHEMA dbo TO tgs_reader;"
psql -d $1 -c "GRANT select ON ALL SEQUENCES IN SCHEMA dbo TO tgs_reader;"
psql -d $1 -c "GRANT select ON ALL FUNCTIONS IN SCHEMA dbo TO tgs_reader;"