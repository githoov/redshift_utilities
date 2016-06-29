/*
Make sure to hardcode/fill in the following 
variables with your actual tables and columns:
	MODERATE_CARDINALITY_COLUMN
	TIME_COLUMN
	JOIN_TABLE
	JOIN_COLUMN_FK
	JOIN_COLUMN_PK
	COLUMN_1
	SOME_VALUE
	COLUMN_2
	SOME_OTHER_VALUE
	COLUMN_3
	SOME_FINAL_VALUE

${TABLE} is a placeholder for the table variants
you will be benchmarking with this script. Leave
${TABLE} in, as it will be used to dynamical substitute
your table names at the command line.
*/

\timing on
\o /dev/null

/* simple count: checks baseline performance and metadata querying */
select count(*) from ${TABLE};
select count(*) from ${TABLE};
select count(*) from ${TABLE};
select count(*) from ${TABLE};
select count(*) from ${TABLE};
select count(*) from ${TABLE};

/* simple count and group by: checks baseline performance and metadata querying */
select MODERATE_CARDINALITY_COLUMN, count(*) from ${TABLE} group by 1;
select MODERATE_CARDINALITY_COLUMN, count(*) from ${TABLE} group by 1;
select MODERATE_CARDINALITY_COLUMN, count(*) from ${TABLE} group by 1;
select MODERATE_CARDINALITY_COLUMN, count(*) from ${TABLE} group by 1;
select MODERATE_CARDINALITY_COLUMN, count(*) from ${TABLE} group by 1;
select MODERATE_CARDINALITY_COLUMN, count(*) from ${TABLE} group by 1;

/* simple count with date restriction: checks sortkey/filter performance */
select count(*) from ${TABLE} where TIME_COLUMN >= current_date - interval '90 day';
select count(*) from ${TABLE} where TIME_COLUMN >= current_date - interval '90 day';
select count(*) from ${TABLE} where TIME_COLUMN >= current_date - interval '90 day';
select count(*) from ${TABLE} where TIME_COLUMN >= current_date - interval '90 day';
select count(*) from ${TABLE} where TIME_COLUMN >= current_date - interval '90 day';
select count(*) from ${TABLE} where TIME_COLUMN >= current_date - interval '90 day';

/* simple count with join: checks join performance */
select count(*) from ${TABLE} left join JOIN_TABLE on ${TABLE}.JOIN_COLUMN_FK = JOIN_TABLE.JOIN_COLUMN_PK;
select count(*) from ${TABLE} left join JOIN_TABLE on ${TABLE}.JOIN_COLUMN_FK = JOIN_TABLE.JOIN_COLUMN_PK;
select count(*) from ${TABLE} left join JOIN_TABLE on ${TABLE}.JOIN_COLUMN_FK = JOIN_TABLE.JOIN_COLUMN_PK;
select count(*) from ${TABLE} left join JOIN_TABLE on ${TABLE}.JOIN_COLUMN_FK = JOIN_TABLE.JOIN_COLUMN_PK;
select count(*) from ${TABLE} left join JOIN_TABLE on ${TABLE}.JOIN_COLUMN_FK = JOIN_TABLE.JOIN_COLUMN_PK;
select count(*) from ${TABLE} left join JOIN_TABLE on ${TABLE}.JOIN_COLUMN_FK = JOIN_TABLE.JOIN_COLUMN_PK;

/* simple count with join and numerous filters: checks looker-style queries with joins and many filters */
select count(*) from ${TABLE} left join JOIN_TABLE on ${TABLE}.JOIN_COLUMN_FK = JOIN_TABLE.JOIN_COLUMN_PK where COLUMN_1 = SOME_VALUE and COLUMN_2 = SOME_OTHER_VALUE and COLUMN_3 = SOME_FINAL_VALUE;
select count(*) from ${TABLE} left join JOIN_TABLE on ${TABLE}.JOIN_COLUMN_FK = JOIN_TABLE.JOIN_COLUMN_PK where COLUMN_1 = SOME_VALUE and COLUMN_2 = SOME_OTHER_VALUE and COLUMN_3 = SOME_FINAL_VALUE;
select count(*) from ${TABLE} left join JOIN_TABLE on ${TABLE}.JOIN_COLUMN_FK = JOIN_TABLE.JOIN_COLUMN_PK where COLUMN_1 = SOME_VALUE and COLUMN_2 = SOME_OTHER_VALUE and COLUMN_3 = SOME_FINAL_VALUE;
select count(*) from ${TABLE} left join JOIN_TABLE on ${TABLE}.JOIN_COLUMN_FK = JOIN_TABLE.JOIN_COLUMN_PK where COLUMN_1 = SOME_VALUE and COLUMN_2 = SOME_OTHER_VALUE and COLUMN_3 = SOME_FINAL_VALUE;
select count(*) from ${TABLE} left join JOIN_TABLE on ${TABLE}.JOIN_COLUMN_FK = JOIN_TABLE.JOIN_COLUMN_PK where COLUMN_1 = SOME_VALUE and COLUMN_2 = SOME_OTHER_VALUE and COLUMN_3 = SOME_FINAL_VALUE;
select count(*) from ${TABLE} left join JOIN_TABLE on ${TABLE}.JOIN_COLUMN_FK = JOIN_TABLE.JOIN_COLUMN_PK where COLUMN_1 = SOME_VALUE and COLUMN_2 = SOME_OTHER_VALUE and COLUMN_3 = SOME_FINAL_VALUE;
