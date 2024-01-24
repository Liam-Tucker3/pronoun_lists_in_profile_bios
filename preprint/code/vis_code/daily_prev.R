library(tidyverse)
library(lubridate)
library(data.table)
library(ggplot2)

figureDir = "/REU/charts/"

# Reading in, cleaning data
daily_prev = read_csv("/REU/DailyPrev/daily_prev.csv", skip=2, col_names = c('count', 'he/him', 'she/her', 'they/them', 'she/they', 'he/they', 'us_day_YYYY_MM_DD'))
daily_prev <- daily_prev[daily_prev$count != 0, ]
daily_prev$us_day_YYYY_MM_DD <- as.Date(daily_prev$us_day_YYYY_MM_DD, format = "%Y_%m_%d")
daily_prev$us_day_YYYY_MM_DD

# Looking at data
daily_prev

# Stacking data
sheSLASHher <- cbind(list(rep("she/her", nrow(daily_prev))), daily_prev[3], daily_prev[7])
heSLASHhim <- cbind(list(rep("he/him", nrow(daily_prev))), daily_prev[2], daily_prev[7])
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
  # filter(searchName %in% c("heSLASHhim", "sheSLASHher", "theySLASHthem", "heSLASHthey", "sheSLASHthey")) %>%
  ggplot(aes(x = Date, y = Prevalence, color = `Pronoun List`, fill = `Pronoun List`)) +
  geom_point() +
  ggtitle("Daily Prevalence of Pronoun Lists") +
  xlab("Date") + ylab("Prevalence") +
  scale_x_date(limits = c(as.Date("2017-01-01"),as.Date("2022-07-01")), date_breaks = "12 months", date_labels = "%b\n%Y", date_minor_breaks = "3 months", expand = expansion(mult = 0, add = 0) ) +
  scale_color_manual(values = c("#FF0000", "#F2AD00", "#A020F0", "#00A08A", "#0000FF")) +
  # Replace the legend with in-graph annotations.
  # theme(legend.position="none") +
  # annotate(geom="label", label.size = 1, x = as.Date("2020-03-15"), y = 350, label = "she / her", color="#F2AD00", size = 18 / .pt) +
  # annotate(geom="label", label.size = 1, x = as.Date("2021-07-01"), y = 225, label = "he / him", color="#FF0000", size = 18 / .pt) +
  # annotate(geom="label", label.size = 1, x = as.Date("2021-07-15"), y = 25, label = "they / them", color="#00A08A", size = 18 / .pt) +
  theme(text = element_text(size=16)) + 
  # Add some plot margin to keep x label from being cut off.
  #theme(plot.margin = margin(5.5, 14, 5.5, 5.5)) + # Note that default margin is 5.5. Default unit is points.
  labs(caption = "N ~ 200,000 active US Twitter accounts per day.") +
  theme(plot.caption = element_text(size=10, color = "#666666"))
#ggsave(paste0(figureDir, "pronouns-daily-cross-2017-2022.svg") )
ggsave(paste0(figureDir, "pronouns-daily-cross-2017-2022.png"), width = 12, height = 8, units = "in")

# Get dates with prevalence >= 450
# Sanitizing data
dates <- data.frame(`Pronoun List` = character(), Prevalence = double(), Date = Date())
for (x in 1:nrow(sheSLASHher)) {
  if (sheSLASHher[[2]][[x]] >= 450) {
    dates <- rbind(dates, sheSLASHher[x, ])
  }
}


#### Old chart, Ignore###
daily_prev %>%
  ggplot() +
  geom_point() +
  geom_path(aes(x = us_day_YYYY_MM_DD, y = `he/him`, group=1), size=0.1, color = "blue", alpha = 0.8, show.legend = TRUE) +
  geom_path(aes(x = us_day_YYYY_MM_DD, y = `she/her`, group=1), size=0.1, color = "pink", alpha = 0.8, show.legend = TRUE) +
  geom_path(aes(x = us_day_YYYY_MM_DD, y = `they/them`, group=1), size=0.1, color = "purple", alpha = 0.8, show.legend = TRUE) +
  geom_path(aes(x = us_day_YYYY_MM_DD, y = `she/they`, group=1), size=0.1, color = "green", alpha = 0.8, show.legend = TRUE) +
  geom_path(aes(x = us_day_YYYY_MM_DD, y = `he/they`, group=1), size=0.1, color = "orange", alpha = 0.8, show.legend = TRUE) +
  xlab("Date") + ylab("Daily Prevalence in Twitter bios") +
  labs(title = "Prevalence of Pronoun Lists by Day") +
  scale_x_date(date_breaks = "2 months", date_labels = "%b\n%Y", date_minor_breaks = "1 month") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(plot.title = element_text(size=17)) +
  # theme(legend.position = "none") +
  theme(axis.text=element_text(size=12)) +
  theme(axis.title.y = element_text(size=15)) +
  theme(axis.title.x = element_text(size=15)) +
  scale_color_manual(name = "Pronoun List", values = c("he/him" = "blue", "she/her" = "pink", "they/them" = "purple", "he/they" = "orange", "she/they" = "green"))
  labs(color = 'Y series')