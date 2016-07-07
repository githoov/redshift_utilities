/*
Make sure to hardcode/fill in the following 
variables with your actual tables and columns:
	YOUR_MATERIAL_TABLE

${TABLE} is a placeholder for the table variants
you will be benchmarking with this script. Leave
${TABLE} in, as it will be used to dynamical substitute
your table names at the command line.
*/

insert into ${TABLE} (
select * from YOUR_MATERIAL_TABLE
);