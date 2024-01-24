library(tidyverse)
library(lubridate)
library(data.table)
library(gridExtra)
library(ggpubr)

# Authors: Liam E. Tucker, Jason J. Jones

################################################################################
# Creating conditional probability graph
# Using colors from https://www.schemecolor.com/google-celebrating-50-years-of-pride-colors.php
# And # Color scheme from https://www.schemecolor.com/transgender-pride-flag-colors-johnathan-andrew.php

# Load the data
tp <- fread("/REU/TokensCross-2022/cutoff_5_5/sampled_tokens_prob_2022.csv")
tp_chart <- tp[1:20]
rownames(tp_chart) <- tp_chart$token

# Looking at the data
tp_chart

# Creating chart with only data to be graphed
tpt_chart <- transpose(tp_chart)
colnames(tpt_chart) <- rownames(tp_chart)
tpt_chart <- tpt_chart[4:nrow(tpt_chart) - 1] # Removing extraneous rows
rownames(tpt_chart) <- c("he/him", "she/her", "they/them", "he/they", "she/they", "multiple")


# Loading data into lists
prev_data = c()
pronoun_data = c()
token_data = c()
for (x in 1:ncol(tpt_chart)) {
  for (y in 1:nrow(tpt_chart)) {
    prev_data <- c(prev_data, as.numeric(tpt_chart[[x]][[y]]))
    token_data <- c(token_data, colnames(tpt_chart)[[x]])
    pronoun_data <- c(pronoun_data, rownames(tpt_chart)[[y]])
    
  }
}
chart_data <- data.frame(token_data, pronoun_data, prev_data)
chart_data$pronoun_data <- factor(chart_data$pronoun_data, levels = c("multiple", "she/they", "he/they", "they/them", "he/him", "she/her"))

# Plotting data
prob_plot <- ggplot(chart_data, aes(fill=pronoun_data, y=prev_data, x=token_data)) + 
  geom_bar(position="stack", stat="identity") +
  xlab("Token") +
  ylab("Probability pronoun list in bio") +
  # labs(subtitle="Given that a token appears in the twitter bio", title= "Conditional probability of pronoun list in twitter bios", fill="Pronoun\nList") +
  labs(fill="Pronoun\nList") +
  scale_x_discrete(limits = rev(colnames(tpt_chart))) +
  scale_fill_discrete(name="Pronoun\nList") +
  scale_fill_manual(values=c("he/him" = "#47A9FA",
                             "she/her" = "#FF8BC2",
                             "they/them" = "#CA93CA",
                             "he/they" = "#65ED99",
                             "she/they" = "#E64A39",
                             "multiple" = "#EDD157")) +
  coord_flip() +
  theme(legend.position = c(0.88, 0.16))
prob_plot


############################################################################
# Relative probability graph (diff for different tokens)
# Color scheme from https://www.schemecolor.com/transgender-pride-flag-colors-johnathan-andrew.php

tp <- fread("/REU/TokensCross-2022/cutoff_5_5/sampled_tokens_rel_prev_2022.csv")
last_10 = nrow(tp) - 4

#### Overall pronouns
setorder(tp, cols = - "pronoun list")
p_chart = tp[1:5]
for (i in last_10: nrow(tp)) {
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
  # facet_wrap(~pronoun_data) +
  scale_x_discrete(limits = rev(colnames(p_common_chart))) +
  scale_fill_discrete(name="pronoun list") +
  theme(legend.position="none") +
  labs(title="pronoun list")

#### she/her pronouns
setorder(tp, cols = - "she/her")
s_chart = tp[1:5]
for (i in last_10: nrow(tp)) {
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
  # facet_wrap(~pronoun_data) +
  scale_x_discrete(limits = rev(colnames(s_common_chart))) +
  scale_fill_discrete(name="she/her") +
  theme(legend.position="none") +
  labs(title="she/her")

#### he/him pronouns
setorder(tp, cols = - "he/him")
h_chart = tp[1:5]
for (i in last_10: nrow(tp)) {
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
  # facet_wrap(~pronoun_data) +
  scale_x_discrete(limits = rev(colnames(h_common_chart))) +
  scale_fill_discrete(name="he/him") +
  labs(title="he/him") +
  theme(legend.position="none")

#### they/them pronouns
setorder(tp, cols = - "they/them")
t_chart = tp[1:5]
for (i in last_10: nrow(tp)) {
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
  labs(title="they/them")

# Putting relative prevalence charts together
prev_plot <- ggarrange(p_plot, s_plot, h_plot, t_plot, 
                       labels = c("", "", "", ""),
                       ncol = 2, nrow = 2)
prev_chart <- annotate_figure(prev_plot, top = text_grob("Relative frequency of Tokens", 
                                                         color = "black", size = 16))
prev_chart

##########################################################################
# Combining charts

grid.arrange(
  grobs = list(prob_plot, prev_plot),
  widths = c(1, 1, 1),
  layout_matrix = rbind(c(1, 1, 2))
)

overall_plot <- ggarrange(prob_plot, prev_plot,
                          labels = c("A", "B"),
                          ncol = 2, nrow = 1)
overall_plot
