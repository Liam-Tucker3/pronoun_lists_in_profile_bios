# Author: Liam Tucker
# Used to create Figure 7, Figure 8

library(tidyverse)
library(lubridate)
library(data.table)
library(gridExtra)

figureDir = "/REU/charts/"


################################################################################
# creating Figure 10

# Loading and cleaning the Sampled Tokens file
tp <- fread("/REU/keyword_data/specified_tokens_2022.csv")
some_nonbinary <- tp[17]
tp <- tp[1:4] # Trimming to just binary data
tp <- rbind(tp, some_nonbinary)
tpt_chart <- transpose(tp)

# Visualizing data
tpt_chart

# Getting rid of raw count data
tpt_chart <- tpt_chart[3]

# Setting row and column names
colnames(tpt_chart) <- c("binary", "non-binary", "nonbinary", "non binary", "total nonbinary")
rownames(tpt_chart) <- c("prevalence")

data <- data.frame(colnames(tpt_chart), rownames(tpt_chart), as.numeric(tpt_chart[1]))
palette <- c("#47A9FA", "#FF8BC2", "#FF8BC2", "#FF8BC2", "#FF8BC2")

# Plotting chart
ggplot(data, aes(y=as.numeric(tpt_chart[1]), x=colnames(tpt_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#47A9FA") +
  xlab("Token") +
  ylab("Prevalence") +
  # scale_x_discrete(limits = rev(colnames(tpt_chart))) +
  # scale_fill_discrete(name="pronoun list") +
  scale_fill_manual(values=c("binary" = "#47A9FA",
                             "non-binary" = "#FF8BC2",
                             "nonbinary" = "#FF8BC2",
                             "non binary" = "#FF8BC2",
                             "total nobinary" = "#47A9FA")) +
  theme(legend.position="none") +
  labs(title="Prevalence of 'binary' tokens")
ggsave("/REU/charts/binary_tokens.svg", width = 12, height = 8, units = "in")
ggsave("/REU/charts/binary_tokens.png", width = 12, height = 8, units = "in")

###########################################################
# Creating Figure 11

# Reading in data
tp <- fread("/REU/keyword_data/pronouns_binary_prob.csv")

# Looking at data
tp

# Removing (empty) multiple_nonbinary_signals row
tp <- tp[1:4]

# Storing binary data separately
binary_counts <- tp[1]
tp <- tp[2:4]

#Labeling data
colnames(tp) <- c('token', 'overall', 'he/him', 'she/her', 'they/them', 'he/they', 'she/they', 'multiple', 'pronoun list')
tp <- subset(tp, select = - token)
rownames(tp) <- c('non-binary', 'nonbinary', 'non binary')

# Prepping data to be graphed
prev_data = c()
pronoun_data = c()
token_data = c()
for (x in 1:ncol(tp)) {
  for (y in 1:nrow(tp)) {
    prev_data <- c(prev_data, as.numeric(tp[[x]][[y]]))
    token_data <- c(token_data, colnames(tp)[[x]])
    pronoun_data <- c(pronoun_data, rownames(tp)[[y]])
    
  }
}

chart_data <- data.frame(token_data, pronoun_data, prev_data)

# Plotting data
ggplot(chart_data, aes(fill=pronoun_data, y=prev_data, x=token_data)) + 
  geom_bar(position="stack", stat="identity") +
  xlab("Tokens") +
  ylab("Proportion of appearences of 'binary'") +
  labs(title= "Binary appearing to mean non-binary") +
  labs(fill="") +
  scale_x_discrete(limits = rev(colnames(tp))) +
  scale_fill_discrete(name="Token") +
  scale_fill_manual(values=c("nonbinary" = "#47A9FA",
                             "non-binary" = "#FF8BC2",
                             "non binary" = "#CA93CA")) +
  coord_flip() +
  guides(col=guide_legend("non-binary\ntoken"))


ggsave("/REU/charts/binary_prob.svg", width = 12, height = 8, units = "in")

## Calculating confidence interval

# Calculating counts
tp_nb = tp[1][[4]] + tp[2][[4]] + tp[3][[4]]
ovd<- binary_counts[[5]]
ov <- round(tp_nb * binary_counts[[5]])

# Calculating confidence interval
ov_interval <- prop.test(x=ov, n=ovd, conf.level=.95, correct=FALSE)
ov_interval
ov_interval[6]

# Probability: 99.0%
# Confidence interval: [98.3%, 99.4$]
