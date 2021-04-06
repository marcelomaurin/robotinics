USER=root
PASSWORD="226468"

all: drop create tables procedures samples 

create:
	mysql -u $(USER) -p$(PASSWORD) < robotinicsdb.sql
drop:
	mysql -u $(USER) -p$(PASSWORD) < dropdb.sql
tables:
	mysql -u $(USER) -p$(PASSWORD) < users.sql
	mysql -u $(USER) -p$(PASSWORD) < security.sql
procedures:

samples:
	mysql -u $(USER) -p$(PASSWORD) < i_users.sql



