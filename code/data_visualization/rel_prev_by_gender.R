# Author: Liam Tucker
# Used to create Figure X

library(tidyverse)
library(lubridate)
library(data.table)

figureDir = "/REU/paper_charts/"

raw_data <- fread("/REU/paper_data/token_data/sampled_tokens_rel_prev_2022.csv")

# Looking at data
raw_data[1:20] #Data table
colnames(raw_data) # Pronouns
raw_data[1:20][[1]] #Tokens

raw_data <- raw_data[raw_data$token != "nigga"]

# Preparing plot
setorder(raw_data, cols = - "overall")
p <- ggplot(raw_data, aes(raw_data[[3]], raw_data[[4]], label = raw_data[[1]]))

# Plotting chart
p + geom_text(check_overlap = TRUE) +
  # p + geom_text() +
  labs(title="Relative Prevalence of Tokens by Gender") +
  xlab("Relative prevalence among bios with he/him") +
  ylab("Relative prevalence among bios with she/her") +
  annotate("rect", xmin = 0, xmax = 20, ymin = 0, ymax = 20,
           alpha = .1,fill = "blue") +
  annotate("rect", xmin = -20, xmax = 0, ymin = 0, ymax = 20,
           alpha = .1,fill = "red") +
  annotate("rect", xmin = -20, xmax = 0, ymin = -20, ymax = 0,
           alpha = .1,fill = "green") +
  annotate("rect", xmin = 0, xmax = 20, ymin = -20, ymax = 0,
           alpha = .1,fill = "yellow") +
  ylim(-20, 20) + # Cutoff at -20/20 is logical for unigrams, arbitrary for n-grams
  xlim(-20, 20)   # A cutoff is needed to enhance value of chart
                  # Change the limits as desired

# Saving plot
ggsave(paste0(figureDir, "rel_prev_by_gender_1_1_updated.png"), width = 12, height = 8, units = "in")

##################################################
# Repeating with bigrams

# Reading in data
bigram_data <- fread("/REU/paper_data/bigram_data/sampled_bigrams_rel_prev_2022.csv")

# Looking at data
bigram_data[1:20] #Data table
colnames(bigram_data) # Pronouns
bigram_data[1:20][[1]] #Tokens

# Preparing plot
setorder(bigram_data, cols = - "overall")
p <- ggplot(bigram_data, aes(bigram_data[[3]], bigram_data[[4]], label = bigram_data[[1]]))

# Plotting chart
p + geom_text(check_overlap = TRUE) +
  # p + geom_text() +
  labs(title="Relative Prevalence of Bigrams by Gender") +
  xlab("Relative prevalence among bios with he/him") +
  ylab("Relative prevalence among bios with she/her") +
  annotate("rect", xmin = 0, xmax = 20, ymin = 0, ymax = 20,
           alpha = .1,fill = "blue") +
  annotate("rect", xmin = -20, xmax = 0, ymin = 0, ymax = 20,
           alpha = .1,fill = "red") +
  annotate("rect", xmin = -20, xmax = 0, ymin = -20, ymax = 0,
           alpha = .1,fill = "green") +
  annotate("rect", xmin = 0, xmax = 20, ymin = -20, ymax = 0,
           alpha = .1,fill = "yellow") +
  ylim(-20, 20) +
  xlim(-20, 20)

# Saving plot
ggsave(paste0(figureDir, "rel_prev_by_gender_bigram.png"), width = 12, height = 8, units = "in")

##################################################
# Repeating with trigrams

# Reading in data
trigram_data <- fread("/REU/paper_data/trigram_data/sampled_trigrams_rel_prev_2022.csv")

# Looking at data
trigram_data[1:20] #Data table
colnames(trigram_data) # Pronouns
trigram_data[1:20][[1]] #Tokens

# Preparing plot
setorder(trigram_data, cols = - "overall")
p <- ggplot(trigram_data, aes(trigram_data[[3]], trigram_data[[4]], label = trigram_data[[1]]))

# Plotting chart
p + geom_text(check_overlap = TRUE) +
  # p + geom_text() +
  labs(title="Relative Prevalence of Trigrams by Gender") +
  xlab("Relative prevalence among bios with he/him") +
  ylab("Relative prevalence among bios with she/her") +
  annotate("rect", xmin = 0, xmax = 20, ymin = 0, ymax = 20,
           alpha = .1,fill = "blue") +
  annotate("rect", xmin = -20, xmax = 0, ymin = 0, ymax = 20,
           alpha = .1,fill = "red") +
  annotate("rect", xmin = -20, xmax = 0, ymin = -20, ymax = 0,
           alpha = .1,fill = "green") +
  annotate("rect", xmin = 0, xmax = 20, ymin = -20, ymax = 0,
           alpha = .1,fill = "yellow") +
  ylim(-20, 20) +
  xlim(-20, 20)

# Saving plot
ggsave(paste0(figureDir, "rel_prev_by_gender_trigram.png"), width = 12, height = 8, units = "in")

###################################################
# Plotting unigrams, bigrams, trigrams on same chart

col_names <- c("phrase", "overall", "he/him", "she/her", "they/them", "he/they", "she/they", "multiple", "pronoun list")
colnames(raw_data) <- col_names
colnames(bigram_data) <- col_names
colnames(trigram_data) <- col_names

all_data <- rbind(raw_data, bigram_data, trigram_data)

# Looking at data
all_data[1:20] #Data table
colnames(all_data) # Pronouns
all_data[1:20][[1]] #Tokens

all_data <- all_data[all_data$phrase != "nigga"]

# Preparing plot
setorder(all_data, cols = - "overall")
p <- ggplot(all_data, aes(all_data[[3]], all_data[[4]], label = all_data[[1]]))

# Plotting chart
p + geom_text(check_overlap = TRUE) +
  # p + geom_text() +
  labs(title="Relative Prevalence of Phrases by Gender") +
  xlab("Relative prevalence among bios with he/him") +
  ylab("Relative prevalence among bios with she/her") +
  annotate("rect", xmin = 0, xmax = 20, ymin = 0, ymax = 20,
           alpha = .1,fill = "blue") +
  annotate("rect", xmin = -20, xmax = 0, ymin = 0, ymax = 20,
           alpha = .1,fill = "red") +
  annotate("rect", xmin = -20, xmax = 0, ymin = -20, ymax = 0,
           alpha = .1,fill = "green") +
  annotate("rect", xmin = 0, xmax = 20, ymin = -20, ymax = 0,
           alpha = .1,fill = "yellow") +
  ylim(-20, 20) +
  xlim(-20, 20)

# Saving plot
ggsave(paste0(figureDir, "rel_prev_by_gender_allgrams.png"), width = 12, height = 8, units = "in")
