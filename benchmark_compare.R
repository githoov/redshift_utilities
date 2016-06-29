# preliminaries
library(ggplot2)

# read in file
df <- read.csv(file = "~/bench_summary.txt", header = FALSE)

# generate query numbers and merge with data frame
df <- cbind(df, rep(rep(c(1:5),each = 5), 5))

# rename columns
names(df) <- c("table_name", "run_sequence", "execution_time_ms", "query_number")

# tabular summary
ddply(df, c("query_number", "table_name"), summarise, median_exec = median(execution_time_ms))

# visual summary
ggplot(df, aes(x = table_name, y = execution_time_ms, group = table_name)) +  geom_boxplot(aes(colour = table_name)) + facet_grid(. ~ query_number) + xlab("Table Name") + ylab("Execution Time (ms)") + theme(legend.position = "none")