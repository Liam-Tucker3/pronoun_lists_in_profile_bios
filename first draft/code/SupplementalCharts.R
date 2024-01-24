library(tidyverse)
library(lubridate)
library(data.table)
library(gridExtra)
library(ggpubr)

# Authors: Liam E. Tucker, Jason J. Jones

########################################################
# Scatterplot

# Load the prevalence table
raw_data <- fread("/REU/TokensCross-2022/cutoff_1_1/sampled_tokens_prev_2022.csv")

# Looking at data
raw_data[1:20] #Data table
colnames(raw_data) # Pronouns
raw_data[1:20][[1]] #Tokens

# Cleaning up data
col_headings = c("token", "overall", "he/him", "she/her", "they/them", "he/they", "she/they", "multiple", "pronoun list")
prev_data <- raw_data %>% select(-one_of('token', 'he/him', 'she/her', 'they/them', 'he/they', 'she/they', 'multiple'))

#Analyzing the best fit line
model <- lm(prev_data$`pronoun list` ~ prev_data$overall, data = prev_data)
summary(model)
confint(model)
cf <- coef(model)
Intercept <- cf[1]
Slope <- cf[2]
caption = paste("Slope: ", substring(toString(Slope), 1, 4), "\nIntercept: ", substring(toString(Intercept), 1, 4))

# Plotting the data
ggplot(data=prev_data, mapping = aes(x = prev_data$overall, y = prev_data$`pronoun list`), position = 'jitter') +
  geom_point() +
  geom_smooth(method='lm', se = FALSE) +
  xlab("Prevalence in all bios") +
  ylab("Prevalence in bios with pronoun lists") +
  labs(title="Token prevalence", caption=caption) +
  # Adding labels to certain tokens
  annotate("text", x = 1870, y = 2300, label = "and") +
  annotate("text", x = 1530, y = 1225, label = "the") +
  annotate("text", x = 1136, y = 975, label = "to") +
  annotate("text", x = 1000, y = 1550, label = "i") +
  annotate("text", x = 783, y = 1350, label = "my") +
  annotate("text", x = 248, y = 600, label = "by") +
  annotate("text", x = 352, y = 682, label = "are") +
  annotate("text", x = 299, y = 125, label = "life") +
  annotate("segment", x = 0, xend = 64, y = 1000, yend = 525,
           colour = "red", size = 1, arrow = arrow()) +
  annotate("text", x = 0, y = 1075, label = "blm") + #(94, 514)
  annotate("segment", x = 105, xend = 129, y = 1000, yend = 530,
           colour = "red", size = 1, arrow = arrow()) +
  annotate("text", x = 105, y = 1075, label = "writer") + #(155, 498)
  annotate("segment", x = 200, xend = 157, y = 900, yend = 492,
           colour = "red", size = 1, arrow = arrow()) +
  annotate("text", x = 200, y = 975, label = "artist") + #(162, 467)
  annotate("segment", x = 300, xend = 190, y = 1000, yend = 484,
           colour = "red", size = 1, arrow = arrow()) +
  annotate("text", x = 300, y = 1075, label = "own") #(183, 459)

################################################
# Lowest relative prevalence tokens

# Looking at tokens with minimum prevalence of 5
tp <- fread("/REU/TokensCross-2022/cutoff_5_5/sampled_tokens_rel_prev_2022.csv")

# Trimming data to only 20 tokens
setorder(tp, cols = "pronoun list")
t_chart = tp[1:20]
rownames(t_chart) <- t_chart$token
t_common_chart <- transpose(t_chart)
colnames(t_common_chart) <- rownames(t_chart)

# Visualizing data
t_common_chart
colnames(t_common_chart)

# Removing less prevalent pronoun lists
t_common_chart <- t_common_chart[9]
rownames(t_common_chart) <- c("pronoun list")

t_chart_data <- data.frame(colnames(t_common_chart), rownames(t_common_chart), as.numeric(t_common_chart[1]))

# Plotting data
t_plot <- ggplot(t_chart_data, aes(fill=rownames(t_common_chart), y=as.numeric(t_common_chart[1]), x=colnames(t_common_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#FF8BC2") +
  xlab("Token") +
  ylab("Relative Prevalence") +
  coord_flip() +
  scale_x_discrete(limits = rev(colnames(t_common_chart))) +
  scale_fill_discrete(name="pronoun list") +
  theme(legend.position="none") +
  labs(title="Minimum prevalence = 5")

# Looking at tokens with minimum prevalence of 1
tp <- fread("/REU/TokensCross-2022/cutoff_1_1/sampled_tokens_rel_prev_2022.csv")

# Trimming data to only 20 tokens
setorder(tp, cols = "pronoun list")
a_chart = tp[1:20]
rownames(a_chart) <- a_chart$token
a_common_chart <- transpose(a_chart)
colnames(a_common_chart) <- rownames(a_chart)

# Visualizing data
a_common_chart
colnames(a_common_chart)

# Removing less prevalent pronoun lists
a_common_chart <- a_common_chart[9]
rownames(a_common_chart) <- c("pronoun list")

a_chart_data <- data.frame(colnames(a_common_chart), rownames(a_common_chart), as.numeric(a_common_chart[1]))

# Plotting data
a_plot <- ggplot(a_chart_data, aes(fill=rownames(a_common_chart), y=as.numeric(a_common_chart[1]), x=colnames(a_common_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#47A9FA") +
  xlab("Token") +
  ylab("Relative Prevalence") +
  coord_flip() +
  scale_x_discrete(limits = rev(colnames(a_common_chart))) +
  scale_fill_discrete(name="pronoun list") +
  theme(legend.position="none") +
  labs(title="Minimum prevalence = 1")

# Creating final chart
plot <- ggarrange(t_plot, a_plot, 
                  labels = c("", "", "", ""),
                  ncol = 2, nrow = 1)
annotate_figure(plot, top = text_grob("Tokens with Lowest Relative Prevalence", 
                                      color = "black", size = 16))


####################################################
# Relative prevalence of crypto terms
# Color scheme from https://www.schemecolor.com/transgender-pride-flag-colors-johnathan-andrew.php

tp <- fread("/REU/crypto_data/5_5/sampled_tokens_rel_prev_2022.csv")

#Creating chart for any crypto term
setorder(tp, cols = - "any crypto")
a_chart = tp[1:10]

rownames(a_chart) <- a_chart$token
a_common_chart <- transpose(a_chart)
colnames(a_common_chart) <- rownames(a_chart)

a_common_chart <- a_common_chart[11]
rownames(a_common_chart) <- c("any crypto")

a_chart_data <- data.frame(colnames(a_common_chart), rownames(a_common_chart), as.numeric(a_common_chart[1]))

a_plot <- ggplot(a_chart_data, aes(fill=rownames(a_common_chart), y=as.numeric(a_common_chart[1]), x=colnames(a_common_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#555555") +
  xlab("Token") +
  ylab("Relative Prevalence") +
  coord_flip() +
  # facet_wrap(~pronoun_data) +
  scale_x_discrete(limits = rev(colnames(a_common_chart))) +
  scale_fill_discrete(name="Any crypto token") +
  theme(legend.position="none") +
  labs(title="any crypto token")

#### Creating chart for "crypto" 
setorder(tp, cols = - "crypto")
c_chart = tp[1:10]

rownames(c_chart) <- c_chart$token
c_common_chart <- transpose(c_chart)
colnames(c_common_chart) <- rownames(c_chart)

c_common_chart <- c_common_chart[3]
rownames(c_common_chart) <- c("crypto")

c_chart_data <- data.frame(colnames(c_common_chart), rownames(c_common_chart), as.numeric(c_common_chart[1]))

c_plot <- ggplot(c_chart_data, aes(fill=rownames(c_common_chart), y=as.numeric(c_common_chart[1]), x=colnames(c_common_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#FF8BC2") +
  xlab("Token") +
  ylab("Relative Prevalence") +
  coord_flip() +
  # facet_wrap(~pronoun_data) +
  scale_x_discrete(limits = rev(colnames(c_common_chart))) +
  scale_fill_discrete(name="crypto") +
  theme(legend.position="none") +
  labs(title="crypto")

#### Creating chart for "blockchain" 
setorder(tp, cols = - "blockchain")
b_chart = tp[1:10]

rownames(b_chart) <- b_chart$token
b_common_chart <- transpose(b_chart)
colnames(b_common_chart) <- rownames(b_chart)

b_common_chart <- b_common_chart[9]
rownames(b_common_chart) <- c("blockchain")

b_chart_data <- data.frame(colnames(b_common_chart), rownames(b_common_chart), as.numeric(b_common_chart[1]))

b_plot <- ggplot(b_chart_data, aes(fill=rownames(b_common_chart), y=as.numeric(b_common_chart[1]), x=colnames(b_common_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#AAAAAA") +
  xlab("Token") +
  ylab("Relative Prevalence") +
  coord_flip() +
  # facet_wrap(~pronoun_data) +
  scale_x_discrete(limits = rev(colnames(b_common_chart))) +
  scale_fill_discrete(name="blockchain") +
  theme(legend.position="none") +
  labs(title="blockchain")

#### Creating chart for "trader" 
setorder(tp, cols = - "trader")
t_chart = tp[1:10]

rownames(t_chart) <-t_chart$token
t_common_chart <- transpose(t_chart)
colnames(t_common_chart) <- rownames(t_chart)

t_common_chart <- t_common_chart[6]
rownames(t_common_chart) <- c("trader")

t_chart_data <- data.frame(colnames(t_common_chart), rownames(t_common_chart), as.numeric(t_common_chart[1]))

t_plot <- ggplot(t_chart_data, aes(fill=rownames(t_common_chart), y=as.numeric(t_common_chart[1]), x=colnames(t_common_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#F6EA65") +
  xlab("Token") +
  ylab("Relative Prevalence") +
  coord_flip() +
  # facet_wrap(~pronoun_data) +
  scale_x_discrete(limits = rev(colnames(t_common_chart))) +
  scale_fill_discrete(name="trader") +
  theme(legend.position="none") +
  labs(title="trader")

#### Creating chart for "nft"
setorder(tp, cols = - "nft")
n_chart = tp[1:10]

rownames(n_chart) <- n_chart$token
n_common_chart <- transpose(n_chart)
colnames(n_common_chart) <- rownames(n_chart)

# Removing less prevalent pronoun lists
n_common_chart <- n_common_chart[4]
rownames(n_common_chart) <- c("nft")

n_chart_data <- data.frame(colnames(n_common_chart), rownames(n_common_chart), as.numeric(n_common_chart[1]))

# Plotting data
n_plot <- ggplot(n_chart_data, aes(fill=rownames(n_common_chart), y=as.numeric(n_common_chart[1]), x=colnames(n_common_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#47A9FA") +
  xlab("Token") +
  ylab("Relative Prevalence") +
  coord_flip() +
  # facet_wrap(~pronoun_data) +
  scale_x_discrete(limits = rev(colnames(n_common_chart))) +
  scale_fill_discrete(name="nft") +
  labs(title="nft") +
  theme(legend.position="none")

#### Creating chart for "bitcoin"
setorder(tp, cols = - "bitcoin")
bit_chart = tp[1:10]

rownames(bit_chart) <- bit_chart$token
bit_common_chart <- transpose(bit_chart)
colnames(bit_common_chart) <- rownames(bit_chart)

bit_common_chart <- bit_common_chart[5]
rownames(bit_common_chart) <- c("bitcoin")

bit_chart_data <- data.frame(colnames(bit_common_chart), rownames(bit_common_chart), as.numeric(bit_common_chart[1]))

bit_plot <- ggplot(bit_chart_data, aes(fill=rownames(bit_common_chart), y=as.numeric(bit_common_chart[1]), x=colnames(bit_common_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#CA93CA") +
  xlab("Token") +
  ylab("Relative Prevalence") +
  coord_flip() +
  scale_x_discrete(limits = rev(colnames(bit_common_chart))) +
  scale_fill_discrete(name="bitcoin") +
  theme(legend.position="none") +
  labs(title="bitcoin")

# Putting charts together
prev_plot <- ggarrange(a_plot, c_plot, n_plot, bit_plot, b_plot, t_plot, 
                       labels = c("", "", "", ""),
                       ncol = 3, nrow = 2)
prev_chart <- annotate_figure(prev_plot, top = text_grob("Relative frequency of Tokens", 
                                                         color = "black", size = 16))
prev_chart


################################################################################
# Prevalence chart (for binary tokens)

# Load thedata
tp <- fread("/REU/keyword_data/specified_tokens_2022.csv")

# Cleaning data
some_nobinary <- tp[17]
tp <- tp[1:4] # Trimming to just binary data
tp <- rbind(tp, some_nonbinary)
tpt_chart <- transpose(tp)

# Looking at data
tpt_chart

# Getting rid of rows that aren't needed
tpt_chart <- tpt_chart[3]

# Setting row and column names
colnames(tpt_chart) <- c("binary", "non-binary", "nonbinary", "non binary", "total nonbinary")
rownames(tpt_chart) <- c("prevalence")

# Preparing to plot data
data <- data.frame(colnames(tpt_chart), rownames(tpt_chart), as.numeric(tpt_chart[1]))
palette <- c("#47A9FA", "#FF8BC2", "#FF8BC2", "#FF8BC2", "#FF8BC2")

ggplot(data, aes(y=as.numeric(tpt_chart[1]), x=colnames(tpt_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#47A9FA") +
  xlab("Token") +
  ylab("Relative Prevalence") +
  theme(legend.position="none") +
  labs(title="Prevalence of 'binary' tokens")


#################################################################
# Probability chart (for binary tokens)

# Reading in data
tp <- fread("/REU/keyword_data/pronouns_binary_prob.csv")

# Looking at data
tp

# Removing multiple_nonbinary_signals row, because it is empty
tp <- tp[1:4]

# Storing the counts data seperately
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

