#Author: Liam Tucker
# Used for Characteristics of Pronoun Users Section

library(tidyverse)
library(lubridate)
library(data.table)
library(scales)
library(RColorBrewer)
library(dplyr)

figureDir <- "/REU/paper_charts/"

# Reading in data
data <- fread("/REU/paper_data/activity_level_data_2022.csv")
colnames(data) <- c('user_id_str', 'pronoun_list', 'verified', 'followers_count', 'friends_count', 'statuses_count', 'created_at')
data$pronoun_list[data$pronoun_list == "None"] <- "No Pronoun List"
data$pronoun_list[data$pronoun_list == "Blank"] <- "Blank Bio"
data$pronoun_list <- factor(data$pronoun_list, levels = c('No Pronoun List', 'Blank Bio', 'she/her', 'he/him', 'they/them', 'he/they', 'she/they', 'Multiple'))

# Visualizing data
data[1:10]


# Plotting data as cumulative probability distribution (not in paper)
status_count_plot <- ggplot(data, aes(x=data[[6]], colour=data$pronoun_list)) +
  stat_ecdf() +
  scale_y_continuous(labels=percent) +
  xlim(0, 100000) +
  xlab("Status count") +
  ylab("Proportion of users") +
  labs(fill="Pronoun List") +
  labs(title= "Cumulative Probability Distribution of Status Count by Pronoun List Status")

status_count_plot


# Plotting data as histogram (not in paper)
split_status_count_barplot <- ggplot(data, aes(x=statuses_count, fill=pronoun_list)) +
  geom_histogram(aes(y=0.5*..density..), position="identity", binwidth = 10000) +
  xlim(-9999, 90000) +
  facet_wrap(~pronoun_list, nrow=2) +
  scale_color_brewer(palette="Set2") +
  xlab("Status Count") +
  ylab("Proportion of bios") +
  theme(axis.text.y=element_blank()) +
  labs(title="Status Count by Pronoun List")
split_status_count_barplot

joint_status_count_barplot <- ggplot(data, aes(x=statuses_count, fill=pronoun_list)) +
  geom_histogram(aes(y=0.5*..density..), position="identity", binwidth = 10000, alpha = 0.2) +
  xlim(0, 100000)
joint_status_count_barplot


# Calculating proportion of accounts that are verified, by pronoun list
aggregate(data$verified, list(data$pronoun_list), FUN=mean)
aggregate(data$verified, list(data$pronoun_list), FUN=sd)
aggregate(data$verified, list(data$pronoun_list), FUN=sum)

# Calculating average follower and friend counts of account, by pronoun list
aggregate(data$followers_count, list(data$pronoun_list), FUN=mean)
aggregate(data$followers_count, list(data$pronoun_list), FUN=median)
aggregate(data$followers_count, list(data$pronoun_list), FUN=sd)

aggregate(data$friends_count, list(data$pronoun_list), FUN=mean)
aggregate(data$friends_count, list(data$pronoun_list), FUN=median)
aggregate(data$friends_count, list(data$pronoun_list), FUN=sd)


# Calculating pronoun list prevalence by creation date
data$created_at = as.Date(strptime(data$created_at, "%a %b %d %H:%M:%S +0000 %Y", tz = "UTC"))
setDT(data)[, month_year := format(as.Date(created_at), "%Y-%m") ]
setDT(data)[, creation_year := format(as.Date(created_at), "%Y") ]
by_creation_month <- aggregate(data$user_id_str, by=list(data$month_year, data$pronoun_list), FUN=length)
by_creation_year <- aggregate(data$user_id_str, by=list(data$creation_year, data$pronoun_list), FUN=length)
colnames(by_creation_month) <- c('Month Year', 'Pronoun List', 'Count')
colnames(by_creation_year) <- c('Year', 'Pronoun List', 'Count')

# Removing entries from 1970, which is bad data
by_creation_year<-subset(by_creation_year, Year != "1970")

# Plotting chart
creation_year_plot <- ggplot(by_creation_year, aes(x=Year, y=`Count`, fill=`Pronoun List`)) +
  geom_bar(stat="identity", position="fill") +
  scale_fill_brewer(palette="Set2") +
  labs(title= "Pronoun List Status by Creation Year") +
  ylab("Proportion of users")
creation_year_plot

# Saving plot
ggsave(paste0(figureDir, "creation_year_status_no_n.png"), width = 12, height = 8, units = "in")

# Adding sample size (in 1000 bios) for each year to chart
totals <- by_creation_year %>%
  group_by(`Year`) %>%
  summarize(total = floor(sum(Count) / 1000))

creation_year_plot <- ggplot(data=by_creation_year) +
  geom_bar(stat="identity", position="fill") +  
  aes(x = `Year`, y = `Count`, label = `Count`, fill = `Pronoun List`) +
  theme() +
  geom_text(aes(x=Year, y=-.02, label = total, fill = NULL), data = totals) +
  scale_fill_brewer(palette="Set2") +
  labs(title= "Pronoun List Status by Creation Year") +
  ylab("Proportion of Bios") +
  xlab("Creation Year")
  
creation_year_plot
ggsave(paste0(figureDir, "creation_year_status.png"), width = 12, height = 8, units = "in")


# Creating table of metrics for status count by pronoun list
status_count_table <- aggregate(data$statuses_count, list(data$pronoun_list), FUN=mean)
status_count_table$median <- aggregate(data$statuses_count, list(data$pronoun_list), FUN=median)[2]
p90 <- data %>% group_by(pronoun_list) %>%
  summarise(p90 = quantile(statuses_count, probs=0.9, na.rm = TRUE))
p90 <- as.data.frame(p90)
status_count_table$p90 <- p90[2]
p10 <- data %>% group_by(pronoun_list) %>%
  summarise(p10 = quantile(statuses_count, probs=0.1, na.rm = TRUE))
p10 <- as.data.frame(p10)
status_count_table$p10 <- p10[2]
p99 <- data %>% group_by(pronoun_list) %>%
  summarise(p99 = quantile(statuses_count, probs=0.99, na.rm = TRUE))
p99 <- as.data.frame(p99)
status_count_table$p99 <- p99[2]
p01 <- data %>% group_by(pronoun_list) %>%
  summarise(p01 = quantile(statuses_count, probs=0.01, na.rm = TRUE))
p01 <- as.data.frame(p01)
status_count_table$p01 <- p01[2]

colnames(status_count_table) <- c("Pronoun List", "Mean", "Median", "90th Percentile", "10th Percentile", "99th Percentile", "1st Percentile")

status_count_table

# Looking at status count, grouped by pronoun list and year
status_count_yearly_table <- aggregate(data$statuses_count, list(data$pronoun_list, data$creation_year), FUN=mean)
status_count_yearly_table
# Conclusion: variance in status count among users with different pronoun list status is NOT due to variance in creation year

# Checking follower count data when excluding verified accounts
not_verified_data<-subset(data, verified != 1)
aggregate(not_verified_data$followers_count, list(not_verified_data$pronoun_list), FUN=mean)
aggregate(not_verified_data$friends_count, list(not_verified_data$pronoun_list), FUN=mean)
# Conclusion: verified accounts are responsible for the majority of the large follower count for users w/o a pronoun list
# Theory: many corporate or brand accounts (e.g. NFL, NASA) have large numbers of followers and don't have pronoun lists  
