# Author: Liam Tucker
# Used to create Figure 2, Figure 3

# Color scheme from https://www.schemecolor.com/transgender-pride-flag-colors-johnathan-andrew.php

library(tidyverse)
library(lubridate)
library(data.table)
library(gridExtra)
library(ggpubr)

figureDir = "/REU/charts/"

############################################################################
# Relative prevalence by pronoun list

# Reading in data
tp <- fread("/REU/TokensCross-2022/cutoff_5_5/sampled_tokens_rel_prev_2022.csv")
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

ggsave("/REU/Charts/rel_prev_5.png", width = 18, height = 12, units = "in")


################################################
# Creating overall relative prevalence, coded by token type chart
tp <- fread("/REU/TokensCross-2022/cutoff_5_5/sampled_tokens_rel_prev_2022.csv")
setorder(tp, cols = - "pronoun list")
p_chart = tp[1:20]
p_chart
p_chart$`pronoun list` <- as.numeric(p_chart$`pronoun list`)
p_chart$token <- factor(p_chart$token, levels = p_chart$token[order(p_chart$`pronoun list`)])

# Manually labeling token types
Category = c('left-wing politics', 'gender or sexual identity', 'gender or sexual identity', 'other', 'gender or sexual identity',
             "neurodivergence", 'hobby', 'gender or sexual identity', 'gender or sexual identity', 'Twitter shorthand',
             "neurodivergence", 'Twitter shorthand', 'Twitter shorthand', 'left-wing politics', 'gender or sexual identity',
             'Twitter shorthand', 'gender or sexual identity', 'Twitter shorthand', 'Twitter shorthand', 'gender or sexual identity')


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
                             "Twitter shorthand" = "#E7D5C7",
                             "neurodivergence" = "#FFC18E",
                             "other" = "#FF8BC2"))
top_plot
ggsave("/REU/Charts/rel_prev_top_20.png", width = 18, height = 12, units = "in")


### Repeating for least common tokens
np <- fread("/REU/TokensCross-2022/cutoff_5_5/sampled_tokens_rel_prev_2022.csv")
setorder(np, cols = "pronoun list")
n_chart = np[1:20]
n_chart
n_chart$`pronoun list` <- as.numeric(n_chart$`pronoun list`)
n_chart$token <- factor(n_chart$token, levels = n_chart$token[order(n_chart$`pronoun list`)])

Category <- c('financial', 'religious', 'Spanish', 'right-wing politics', 'financial',
              'other', 'other', 'sports', 'sports', 'patriotic',
              'patriotic', 'financial', 'Spanish', 'other', 'financial',
              'religious', 'other', 'other', 'other', 'patriotic')

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
                             "patriotic" = "#a772a9",
                             "financial" = "#FFC18E",
                             "sports" = "#FF9F45",
                             "Spanish" = "#EDD157",
                             "religious" = "#ABCDE0",
                             "other" = "#FF8BC2"))
bottom_plot
ggsave("/REU/Charts/rel_prev_low_20.png", width = 18, height = 12, units = "in")

# Combining most prevalent, least prevalent charts
prev_plot <- ggarrange(top_plot, bottom_plot, 
                       labels = c("", ""),
                       ncol = 1, nrow = 2)
prev_chart <- annotate_figure(prev_plot, top = text_grob("Relative Prevalence of Tokens", 
                                                         color = "black", size = 32))
prev_chart

ggsave("/REU/Charts/rel_prev_20.png", width = 14, height = 20, units = "in")

