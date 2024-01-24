# Author: Liam Tucker
# Used to create Figure

library(tidyverse)
library(lubridate)
library(data.table)
library(ggplot2)

figureDir = "/REU/paper_charts/"

# Reading in, cleaning data
daily_prev = read_csv("/REU/paper_data/daily_prev.csv", skip=2, col_names = c('count', 'he/him', 'she/her', 'they/them', 'she/they', 'he/they', 'us_day_YYYY_MM_DD'))
daily_prev <- daily_prev[daily_prev$count != 0, ]
daily_prev$us_day_YYYY_MM_DD <- as.Date(daily_prev$us_day_YYYY_MM_DD, format = "%Y_%m_%d")
daily_prev$us_day_YYYY_MM_DD

# Looking at data
daily_prev

# Stacking data
heSLASHhim <- cbind(list(rep("he/him", nrow(daily_prev))), daily_prev[2], daily_prev[7])
sheSLASHher <- cbind(list(rep("she/her", nrow(daily_prev))), daily_prev[3], daily_prev[7])
theySLASHthem <- cbind(list(rep("they/them", nrow(daily_prev))), daily_prev[4], daily_prev[7])
sheSLASHthey <- cbind(list(rep("she/they", nrow(daily_prev))), daily_prev[5], daily_prev[7])
heSLASHthey <- cbind(list(rep("he/they", nrow(daily_prev))), daily_prev[6], daily_prev[7])
colnames(sheSLASHher) <- c("Pronoun List","Prevalence", "Date")
colnames(heSLASHhim) <- c("Pronoun List","Prevalence", "Date")
colnames(theySLASHthem) <- c("Pronoun List","Prevalence", "Date")
colnames(sheSLASHthey) <- c("Pronoun List","Prevalence", "Date")
colnames(heSLASHthey) <- c("Pronoun List","Prevalence", "Date")
data <- rbind(sheSLASHher, heSLASHhim, theySLASHthem, sheSLASHthey, heSLASHthey)

# Quick look.
data %>% 
  select("Date", "Pronoun List", "Prevalence") %>%
  ggplot(aes(x = Date, y = Prevalence, color = `Pronoun List`, fill = `Pronoun List`)) +
  geom_path(size = 0.75)

# Plot 2017 forward.
data %>% 
  select("Date", "Pronoun List", "Prevalence") %>%
  ggplot(aes(x = Date, y = Prevalence, color = `Pronoun List`, fill = `Pronoun List`)) +
  geom_point() +
  ggtitle("Daily Prevalence of Pronoun Lists") +
  xlab("Date") + ylab("Prevalence") +
  scale_x_date(limits = c(as.Date("2017-01-01"),as.Date("2022-07-01")), date_breaks = "12 months", date_labels = "%b\n%Y", date_minor_breaks = "3 months", expand = expansion(mult = 0, add = 0) ) +
  scale_color_manual(values = c("#FF0000", "#F2AD00", "#A020F0", "#00A08A", "#0000FF")) +
  theme(text = element_text(size=16)) + 
  labs(caption = "N ~ 200,000 active US Twitter accounts per day.") +
  theme(plot.caption = element_text(size=10, color = "#666666"))
ggsave(paste0(figureDir, "pronouns-daily-cross-2017-2022.png"), width = 12, height = 8, units = "in")

# Get dates with she/her prevalence >= 450
dates <- data.frame(`Pronoun List` = character(), Prevalence = double(), Date = Date())
for (x in 1:nrow(sheSLASHher)) {
  if (sheSLASHher[[2]][[x]] >= 450) {
    dates <- rbind(dates, sheSLASHher[x, ])
  }
}
dates
