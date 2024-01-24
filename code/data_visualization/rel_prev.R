# Author: Liam Tucker
# Used to create Figure 3

# Color scheme from https://www.schemecolor.com/transgender-pride-flag-colors-johnathan-andrew.php

library(tidyverse)
library(lubridate)
library(data.table)
library(gridExtra)
library(ggpubr)

figureDir = "/REU/paper_charts/"

################################################
# Displaying tokens with largest/smallest relative prevalence
tp <- fread("/REU/paper_data/token_data/sampled_tokens_rel_prev_2022.csv")
setorder(tp, cols = - "pronoun list")

p_chart = tp[1:20]
p_chart
p_chart$`pronoun list` <- as.numeric(p_chart$`pronoun list`)
p_chart$token <- factor(p_chart$token, levels = p_chart$token[order(p_chart$`pronoun list`)])

# Manually labeling token types
Category = c('hobby', 'gender or sexual identity', 'left-wing politics', 'gender or sexual identity', 'gender or sexual identity',
             'left-wing politics', 'gender or sexual identity', 'hobby', 'hobby', 'other',
             'gender or sexual identity', 'gender or sexual identity', 'gender or sexual identity', 'neurodivergence', 'gender or sexual identity',
             'gender or sexual identity', 'gender or sexual identity', 'neurodivergence', 'gender or sexual identity', 'other')

p_chart_data <- data.frame(p_chart$token, p_chart$`pronoun list`, Category)


top_plot <- ggplot(p_chart_data, aes(fill=Category, x=p_chart$token, y=p_chart$`pronoun list` )) +  
  geom_bar(position="dodge", stat="identity") +
  coord_flip() +
  xlab("Token") +
  ylab("Relative Prevalence") +
  labs(title="Highest Relative Prevalence") +
  theme(text = element_text(size = 28)) +
  scale_fill_manual(values=c("left-wing politics" = "#47A9FA",
                             "gender or sexual identity" = "#CA93CA",
                             "hobby" = "#65ED99",
                             "neurodivergence" = "#FFC18E",
                             "other" = "#FF8BC2"))
top_plot
ggsave("/REU/paper_charts/rel_prev_top_20_tokens.png", width = 18, height = 12, units = "in")


### Repeating for least common tokens
np <- fread("/REU/paper_data/token_data/sampled_tokens_rel_prev_2022.csv")
setorder(np, cols = "pronoun list")
n_chart = np[1:20]
n_chart
n_chart$`pronoun list` <- as.numeric(n_chart$`pronoun list`)
n_chart$token <- factor(n_chart$token, levels = n_chart$token[order(n_chart$`pronoun list`)])

Category <- c('financial', 'right-wing politics', 'corporate', 'right-wing politics', 'financial',
              'corporate', 'financial', 'financial', 'other', 'other',
              'corporate', 'financial', 'financial', 'Spanish', 'Spanish',
              'Spanish', 'financial', 'financial', 'financial', 'financial')

n_chart_data <- data.frame(n_chart$token, n_chart$`pronoun list`, Category)


bottom_plot <- ggplot(n_chart_data, aes(fill=Category, x=n_chart$token, y=n_chart$`pronoun list` )) +  
  geom_bar(position="dodge", stat="identity") +
  coord_flip() +
  xlab("Token") +
  ylab("Relative Prevalence") +
  labs(title="Lowest Relative Prevalence") +
  theme(text = element_text(size = 28)) +
  guides(col=guide_legend("Token Category")) +
  scale_fill_manual(values=c("right-wing politics" = "#e85c4d",
                             "financial" = "#FFC18E",
                             "Spanish" = "#EDD157",
                             "corporate" = "#ABCDE0",
                             "other" = "#FF8BC2"))
bottom_plot
ggsave("/REU/paper_charts/rel_prev_low_20_tokens.png", width = 18, height = 12, units = "in")

# Combining most prevalent, least prevalent charts
prev_plot <- ggarrange(top_plot, bottom_plot, 
                       labels = c("", ""),
                       ncol = 1, nrow = 2)
prev_chart <- annotate_figure(prev_plot, top = text_grob("Relative Prevalence of Tokens", 
                                                         color = "black", size = 32))
prev_chart

ggsave("/REU/paper_charts/rel_prev_20_tokens.png", width = 14, height = 20, units = "in")


################################################
# Displaying bigrams with largest/smallest relative prevalence
tp <- fread("/REU/paper_data/bigram_data/sampled_bigrams_rel_prev_2022.csv")
setorder(tp, cols = - "pronoun list")

p_chart = tp[1:20]
p_chart
p_chart$`pronoun list` <- as.numeric(p_chart$`pronoun list`)
p_chart$bigram <- factor(p_chart$bigram, levels = p_chart$bigram[order(p_chart$`pronoun list`)])

# Manually labeling bigram types
Category = c('left-wing politics', 'left-wing politics', 'Twitter shorthand', 'other', 'other',
             'gender or sexual identity', 'Twitter shorthand', 'left-wing politics', 'Twitter shorthand', 'Twitter shorthand',
             'Twitter shorthand', 'Twitter shorthand', 'Twitter shorthand', 'gender or sexual identity', 'other', 
             'left-wing politics', 'Twitter shorthand', 'Twitter shorthand', 'other', 'Twitter shorthand')
  
p_chart_data <- data.frame(p_chart$bigram, p_chart$`pronoun list`, Category)


top_plot <- ggplot(p_chart_data, aes(fill=Category, x=p_chart$bigram, y=p_chart$`pronoun list` )) +  
  geom_bar(position="dodge", stat="identity") +
  coord_flip() +
  xlab("Bigram") +
  ylab("Relative Prevalence") +
  labs(title="Highest Relative Prevalence") +
  theme(text = element_text(size = 28)) +
  scale_fill_manual(values=c("left-wing politics" = "#47A9FA",
                             "gender or sexual identity" = "#CA93CA",
                             "Twitter shorthand" = "#65ED99",
                             "other" = "#FF8BC2"))
top_plot
ggsave("/REU/paper_charts/rel_prev_top_20_bigrams.png", width = 18, height = 12, units = "in")


### Repeating for least common tokens
np <- fread("/REU/paper_data/bigram_data/sampled_bigrams_rel_prev_2022.csv")
setorder(np, cols = "pronoun list")
np<-subset(np, bigram != "/ her") # Removing ' / her' because it is used as 'she / her'
n_chart = np[1:20]
n_chart
n_chart$`pronoun list` <- as.numeric(n_chart$`pronoun list`)
n_chart$bigram <- factor(n_chart$bigram, levels = n_chart$bigram[order(n_chart$`pronoun list`)])


Category <- c('corporate', 'right-wing politics', 'right-wing politics', 'other', 'corporate',
              'corporate', 'corporate', 'sports', 'corporate', 'corporate',
              'right-wing politics', 'sports', 'sports', 'other', 'right-wing politics',
              'corporate', 'right-wing politics', 'corporate', 'corporate', 'sports')

n_chart_data <- data.frame(n_chart$bigram, n_chart$`pronoun list`, Category)


bottom_plot <- ggplot(n_chart_data, aes(fill=Category, x=n_chart$bigram, y=n_chart$`pronoun list` )) +  
  geom_bar(position="dodge", stat="identity") +
  coord_flip() +
  xlab("Bigram") +
  ylab("Relative Prevalence") +
  labs(title="Lowest Relative Prevalence") +
  theme(text = element_text(size = 28)) +
  guides(col=guide_legend("Bigram Category")) +
  scale_fill_manual(values=c("right-wing politics" = "#e85c4d",
                             "corporate" = "#FFC18E",
                             "sports" = "#ABCDE0",
                             "other" = "#FF8BC2"))
bottom_plot
ggsave("/REU/paper_charts/rel_prev_low_20_bigrams.png", width = 18, height = 12, units = "in")

# Combining most prevalent, least prevalent charts
prev_plot <- ggarrange(top_plot, bottom_plot, 
                       labels = c("", ""),
                       ncol = 1, nrow = 2)
prev_chart <- annotate_figure(prev_plot, top = text_grob("Relative Prevalence of Bigrams", 
                                                         color = "black", size = 32))
prev_chart

ggsave("/REU/paper_charts/rel_prev_20_bigrams.png", width = 14, height = 20, units = "in")

################################################
# Displaying trigrams with largest/smallest relative prevalence
tp <- fread("/REU/paper_data/trigram_data/sampled_trigrams_rel_prev_2022.csv")
setorder(tp, cols = - "pronoun list")

p_chart = tp[1:20]
p_chart
p_chart$`pronoun list` <- as.numeric(p_chart$`pronoun list`)
p_chart$trigram <- factor(p_chart$trigram, levels = p_chart$trigram[order(p_chart$`pronoun list`)])

# Manually labeling bigram types
Category = c('left-wing politics', 'left-wing politics', 'Twitter shorthand', 'left-wing politics', 'hobby',
             'hobby', 'other', 'other', 'Twitter shorthand', 'Twitter shorthand',
             'Twitter shorthand', 'Twitter shorthand', 'other', 'hobby', 'hobby',
             'Twitter shorthand', 'other', 'other', 'hobby', 'hobby')
  
p_chart_data <- data.frame(p_chart$trigram, p_chart$`pronoun list`, Category)


top_plot <- ggplot(p_chart_data, aes(fill=Category, x=p_chart$trigram, y=p_chart$`pronoun list` )) +  
  geom_bar(position="dodge", stat="identity") +
  coord_flip() +
  xlab("Trigram") +
  ylab("Relative Prevalence") +
  labs(title="Highest Relative Prevalence") +
  theme(text = element_text(size = 28)) +
  scale_fill_manual(values=c("left-wing politics" = "#47A9FA",
                             "hobby" = "#CA93CA",
                             "Twitter shorthand" = "#65ED99",
                             "other" = "#FF8BC2"))
top_plot
ggsave("/REU/paper_charts/rel_prev_top_20_trigrams.png", width = 18, height = 12, units = "in")


### Repeating for least common tokens
np <- fread("/REU/paper_data/trigram_data/sampled_trigrams_rel_prev_2022.csv")
np<-subset(np, trigram != "she / her") # Removing 'she / her' because it is a pronoun list
setorder(np, cols = "pronoun list")
n_chart = np[1:20]
n_chart
n_chart$`pronoun list` <- as.numeric(n_chart$`pronoun list`)
n_chart$trigram <- factor(n_chart$trigram, levels = n_chart$trigram[order(n_chart$`pronoun list`)])


Category <- c('corporate', 'corporate', 'corporate', 'right-wing politics', 'corporate',
              'financial', 'corporate', 'corporate', 'corporate', 'financial',
              'right-wing politics', 'religion', 'corporate', 'corporate', 'corporate',
              'other', 'other', 'corporate', 'corporate', 'religion')
  

n_chart_data <- data.frame(n_chart$trigram, n_chart$`pronoun list`, Category)


bottom_plot <- ggplot(n_chart_data, aes(fill=Category, x=n_chart$trigram, y=n_chart$`pronoun list` )) +  
  geom_bar(position="dodge", stat="identity") +
  coord_flip() +
  xlab("Trigram") +
  ylab("Relative Prevalence") +
  labs(title="Lowest Relative Prevalence") +
  theme(text = element_text(size = 28)) +
  guides(col=guide_legend("Trigram Category")) +
  scale_fill_manual(values=c("right-wing politics" = "#e85c4d",
                             "corporate" = "#FFC18E",
                             "religion" = "#ABCDE0",
                             "financial" = "#FFC18E",
                             "other" = "#FF8BC2"))
bottom_plot
ggsave("/REU/paper_charts/rel_prev_low_20_trigrams.png", width = 18, height = 12, units = "in")

# Combining most prevalent, least prevalent charts
prev_plot <- ggarrange(top_plot, bottom_plot, 
                       labels = c("", ""),
                       ncol = 1, nrow = 2)
prev_chart <- annotate_figure(prev_plot, top = text_grob("Relative Prevalence of Trigrams", 
                                                         color = "black", size = 32))
prev_chart

ggsave("/REU/paper_charts/rel_prev_20_trigrams.png", width = 14, height = 20, units = "in")

############################################################################
# No longer in paper
# Creates plot of the five tokens with the largest and smallest relative prevalences among bios with each pronoun list

# Reading in data
tp <- fread("/REU/paper_data/token_data/sampled_tokens_rel_prev_2022.csv")
last_5 = nrow(tp) - 4

#### Overall pronouns
setorder(tp, cols = - "pronoun list")
p_chart = tp[1:5]
for (i in last_5: nrow(tp)) {
  this_row = tp[i]
  p_chart <- rbind(p_chart, this_row)
}
rownames(p_chart) <- p_chart$token
p_common_chart <- transpose(p_chart)
colnames(p_common_chart) <- rownames(p_chart)

p_common_chart <- p_common_chart[9]
rownames(p_common_chart) <- c("pronoun list")

p_chart_data <- data.frame(colnames(p_common_chart), rownames(p_common_chart), as.numeric(p_common_chart[1]))

p_plot <- ggplot(p_chart_data, aes(fill=rownames(p_common_chart), y=as.numeric(p_common_chart[1]), x=colnames(p_common_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#555555") +
  xlab("Token") +
  ylab("Relative Prevalence") +
  coord_flip() +
  scale_x_discrete(limits = rev(colnames(p_common_chart))) +
  scale_fill_discrete(name="pronoun list") +
  theme(legend.position="none") +
  labs(title="pronoun list") +
  theme(text = element_text(size = 28)) 

#### she/her pronouns
setorder(tp, cols = - "she/her")
s_chart = tp[1:5]
for (i in last_5: nrow(tp)) {
  this_row = tp[i]
  s_chart <- rbind(s_chart, this_row)
}
rownames(s_chart) <- s_chart$token
s_common_chart <- transpose(s_chart)
colnames(s_common_chart) <- rownames(s_chart)

s_common_chart <- s_common_chart[4]
rownames(s_common_chart) <- c("she/her")

s_chart_data <- data.frame(colnames(s_common_chart), rownames(s_common_chart), as.numeric(s_common_chart[1]))

s_plot <- ggplot(s_chart_data, aes(fill=rownames(s_common_chart), y=as.numeric(s_common_chart[1]), x=colnames(s_common_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#FF8BC2") +
  xlab("Token") +
  ylab("Relative Prevalence") +
  coord_flip() +
  scale_x_discrete(limits = rev(colnames(s_common_chart))) +
  scale_fill_discrete(name="she/her") +
  theme(legend.position="none") +
  labs(title="she/her") +
  theme(text = element_text(size = 28)) 

#### he/him pronouns
setorder(tp, cols = - "he/him")
h_chart = tp[1:5]
for (i in last_5: nrow(tp)) {
  this_row = tp[i]
  h_chart <- rbind(h_chart, this_row)
}
rownames(h_chart) <- h_chart$token
h_common_chart <- transpose(h_chart)
colnames(h_common_chart) <- rownames(h_chart)

# Removing less prevalent pronoun lists
h_common_chart <- h_common_chart[3]
rownames(h_common_chart) <- c("he/him")

h_chart_data <- data.frame(colnames(h_common_chart), rownames(h_common_chart), as.numeric(h_common_chart[1]))

# Plotting data
h_plot <- ggplot(h_chart_data, aes(fill=rownames(h_common_chart), y=as.numeric(h_common_chart[1]), x=colnames(h_common_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#47A9FA") +
  xlab("Token") +
  ylab("Relative Prevalence") +
  coord_flip() +
  scale_x_discrete(limits = rev(colnames(h_common_chart))) +
  scale_fill_discrete(name="he/him") +
  labs(title="he/him") +
  theme(legend.position="none") +
  theme(text = element_text(size = 28)) 

#### they/them pronouns
setorder(tp, cols = - "they/them")
t_chart = tp[1:5]
for (i in last_5: nrow(tp)) {
  this_row = tp[i]
  t_chart <- rbind(t_chart, this_row)
}
rownames(t_chart) <- t_chart$token
t_common_chart <- transpose(t_chart)
colnames(t_common_chart) <- rownames(t_chart)

# Removing less prevalent pronoun lists
t_common_chart <- t_common_chart[5]
rownames(t_common_chart) <- c("they/them")

t_chart_data <- data.frame(colnames(t_common_chart), rownames(t_common_chart), as.numeric(t_common_chart[1]))

# Plotting data
t_plot <- ggplot(t_chart_data, aes(fill=rownames(t_common_chart), y=as.numeric(t_common_chart[1]), x=colnames(t_common_chart))) + 
  geom_bar(position="dodge", stat="identity", fill="#CA93CA") +
  xlab("Token") +
  ylab("Relative Prevalence") +
  coord_flip() +
  scale_x_discrete(limits = rev(colnames(t_common_chart))) +
  scale_fill_discrete(name="they/them") +
  theme(legend.position="none") +
  labs(title="they/them") +
  theme(text = element_text(size = 28)) 

# Putting relative prevalence charts together
prev_plot <- ggarrange(p_plot, s_plot, h_plot, t_plot, 
                       labels = c("", "", "", ""),
                       ncol = 2, nrow = 2)
prev_chart <- annotate_figure(prev_plot, top = text_grob("Relative Prevalence of Tokens", 
                                                         color = "black", size = 32))
prev_chart

ggsave("/REU/paper_charts/rel_prev_1.png", width = 18, height = 12, units = "in")

