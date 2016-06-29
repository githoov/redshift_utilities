:'
WARNING: THIS SCRIPT CAN DO DAMAGE IF
YOU DON'T KNOW WHAT YOU'RE DOING.
REACH OUT TO SCOTT@LOOKER.COM OR
GITHOOV ON GITHUB FOR ASSISTANCE.

Make sure to hardcode/fill in the following 
variables with your actual tables and columns:
	REDSHIFT_HOST
	REDSHIFT_DATABASE
	REDSHIFT_USER
	replace_me1
	replace_me2
	replace_me3
'

REDSHIFT_HOST=your_host
REDSHIFT_DATABASE=your_database_name
REDSHIFT_USER=your_database_user

# create tmp tables
psql -h $REDSHIFT_HOST -p 5439 -d $REDSHIFT_DATABASE -U $REDSHIFT_USER -f benchmark_creates.sql -e

# perform insert (select) from material table into tmp tables
for VARIANT in replace_me1, replace_me2, replace_me3
do
  cat benchmark_inserts.sql | TABLE=$VARIANT envsubst | psql -h $REDSHIFT_HOST -p 5439 -d $REDSHIFT_DATABASE -U $REDSHIFT_USER -e
done

# run benchmarks on table variants
for VARIANT in replace_me1, replace_me2, replace_me3
do
  cat benchmark_queries.sql | TABLE=$VARIANT envsubst | psql -h $REDSHIFT_HOST -p 5439 -d $REDSHIFT_DATABASE -U $REDSHIFT_USER -e  > benchmarks_$VARIANT.out
  awk '/Time.*/' benchmarks_$VARIANT.out | awk '{split($0, a, " "); print "$VARIANT," NR "," a[2]}' >> bench_summary.txt
done

# drop tmp tables
for VARIANT in replace_me1, replace_me2, replace_me3
do
  cat benchmark_drops.sql | TABLE=$VARIANT envsubst | psql -h $REDSHIFT_HOST -p 5439 -d $REDSHIFT_DATABASE -U $REDSHIFT_USER -e
done