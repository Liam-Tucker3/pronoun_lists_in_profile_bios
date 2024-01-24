# Author: Liam Tucker
# Used to create Figure 6

library(tidyverse)
library(lubridate)
library(data.table)

figureDir = "/REU/charts/"

# Reading in data
raw_data <- fread("/REU/TokensCross-2022/cutoff_0_0/sampled_tokens_prev_2022.csv")

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
  labs(title="Calculating average relative prevalence", caption=caption) +
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


ggsave(paste0(figureDir, "prev_scatterplot_0_0.png"), width = 12, height = 8, units = "in")

