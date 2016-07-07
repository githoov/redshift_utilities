## About
It's often useful to benchmark different table architectures when setting up Redshift or adding new data. While there's plenty of literature on best practices, each data set is unique; when it comes to performance, everything depends. Based on my experience, it's best to use these rules of thumb as a loose guide, and test a few different ideas empirically to see which table architecture is ideal for your data. With that in mind, I'm adding a few scripts that we use at Looker to benchmark new tables to a dedicated repo on GitHub. I encourage people to use these, comment, and contribute.

### What's Included?
- `benchmark_creates.example.sql`
This will need to be replaced with your own `create table` statements. However, it may be a useful guide to see which sort of variant architectures one might want to consider benchmarking.

- `benchmark_inserts.example.sql`
Assuming you have a pre-existing variant of the table in question, you can `insert into` from a `select` using this script. Alternatively, you may need to `copy` data from S3, EC2, etc.

- `benchmark_queries.example.sql`
These are some standard queries that might be useful for benchmarking different table architectures.

- `benchmark_drops.example.sql`
After we're done with the space-consuming variants, we may want to drop them.

- `run.sh`
Runs the following steps in sequence:
  - create table variants
  - for each table variant, insert data from material table
  - for each table variant, run benchmark queries, output to file, scrape file and append results to `benchmark_summary.txt`
  - for each table variant, drop table

- `benchmark_compare.R`
R script to visualize the differences in query execution times.

### Usage
Clone this repo: `git@github.com:looker/redshift_utilities.git`

Open up each file and follow the instructions at the top. Save all files, removing the `example` suffix. `chmod 750 run.sh`. `./run.sh`