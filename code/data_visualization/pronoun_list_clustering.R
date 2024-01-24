#Author: Liam Tucker
# Used to create Figure 5 and Figure 6

library(tidyverse)
library(lubridate)
library(data.table)

figureDir <- "/REU/paper_charts/"

#########################################################################
# Looking at friends data

# Loading in data
friends_data <- fread("/REU/paper_data/cluster_data/test_friend_percentages.csv") #, skip=1, col_names = c('user_id', 'has_pronouns', 'followers_sampled', 'raw_match', 'raw_non_match', 'precent_match', 'percent_non_match'))
colnames(friends_data) <- c('user_id', 'has_pronouns', 'friends_sampled', 'raw_match', 'raw_non_match', 'precent_match', 'percent_non_match')
friends_data$has_pronouns <- factor(friends_data$has_pronouns, levels = c(0, 1))

# Visualizing data
friends_data[1:10]
colnames(friends_data)
pronoun_values <- c()
no_pronoun_values <- c()

# Sanitizing data
for (x in 1:nrow(friends_data)) {
  if (friends_data[x][[2]] == 0) {
    per_match <- friends_data[x][[6]]
    friends_data[x][[6]] <- friends_data[x][[7]]
    friends_data[x][[7]] <- per_match
    friends_data[x][[2]] <- "no pronouns"
    no_pronoun_values <- append(no_pronoun_values, as.numeric(friends_data[x][[6]]))
  }
  else {
    friends_data[x][[2]] <- "pronouns"
    pronoun_values <- append(pronoun_values, as.numeric(friends_data[x][[6]]))
  }
}

# Plotting data
friend_plot <- ggplot(friends_data, aes(x=friends_data[[6]], fill=friends_data$has_pronouns)) +
  geom_histogram(binwidth = 0.025, position='identity', alpha = 0.7) +
  xlab("Proportion of friends with pronoun list in bios") +
  ylab("Frequency") +
  labs(title= "Friends with pronoun list in bios") +
  labs(fill="Twitter bios with") +
  guides(col=guide_legend("non-binary\ntoken")) +
  theme(text = element_text(size = 36)) +
  geom_segment(aes(x = 0.0461, y = 0, xend = 0.0461, yend = 1400)) +
  annotate("text", x = 0.19, y = 1400, label = "proportion of all bios with a pronoun list", size=10) +
  theme(legend.position = c(0.7, 0.5))

friend_plot
ggsave("/REU/paper_charts/friends_data.png", width = 18, height = 12, units = "in")  

### Calculating mean, standard deviation for both groups 
p_mean <- mean(pronoun_values)
p_sd <- sd(pronoun_values)
n_mean <- mean(no_pronoun_values)
n_sd <- sd(no_pronoun_values)

p_mean
p_sd
n_mean
n_sd

# T-test
friend_test <- t.test(precent_match ~ has_pronouns,
                      data = friends_data,
                      var.equal = FALSE,
                      alternative = "greater")
friend_test

################################################################################
# Looking at follower data

# Loading in data
followers_data <- fread("/REU/paper_data/cluster_data/test_follower_percentages.csv") #, skip=1, col_names = c('user_id', 'has_pronouns', 'followers_sampled', 'raw_match', 'raw_non_match', 'precent_match', 'percent_non_match'))
colnames(followers_data) <- c('user_id', 'has_pronouns', 'followers_sampled', 'raw_match', 'raw_non_match', 'precent_match', 'percent_non_match')
followers_data$has_pronouns <- factor(followers_data$has_pronouns, levels = c(0, 1))

# Visualizing data
followers_data[1:10]
colnames(followers_data)
pronoun_values <- c()
no_pronoun_values <- c()

# Sanitizing data
for (x in 1:nrow(followers_data)) {
  if (followers_data[x][[2]] == 0) {
    per_match <- followers_data[x][[6]]
    followers_data[x][[6]] <- followers_data[x][[7]]
    followers_data[x][[7]] <- per_match
    followers_data[x][[2]] <- "no pronouns"
    no_pronoun_values <- append(no_pronoun_values, as.numeric(followers_data[x][[6]]))
  }
  else {
    followers_data[x][[2]] <- "pronouns"
    pronoun_values <- append(pronoun_values, as.numeric(followers_data[x][[6]]))
  }
}

follower_plot <- ggplot(followers_data, aes(x=followers_data[[6]], fill=followers_data$has_pronouns)) +
  geom_histogram(binwidth = 0.025, position='identity', alpha = 0.7) +
  xlab("Proportion of followers with pronoun list in bio") +
  ylab("Frequency") +
  labs(title= "Followers with pronoun list in bio") +
  labs(fill="Twitter bios with") +
  guides(col=guide_legend("non-binary\ntoken")) +
  theme(text = element_text(size = 28)) +
  geom_segment(aes(x = 0.0461, y = 0, xend = 0.0461, yend = 1000))  +
  annotate("text", x = 0.23, y = 1000, label = "proportion of bios with a pronoun list", size=6) +
  theme(legend.position = c(0.7, 0.5))

follower_plot
ggsave("/REU/paper_charts/followers_data.png", width = 18, height = 12, units = "in")

### Calculating values
p_mean <- mean(pronoun_values)
p_sd <- sd(pronoun_values)
n_mean <- mean(no_pronoun_values)
n_sd <- sd(no_pronoun_values)

p_mean
p_sd
n_mean
n_sd

### t-test
follower_test <- t.test(precent_match ~ has_pronouns,
                        data = followers_data,
                        var.equal = FALSE,
                        alternative = "greater")
follower_test


### Box and whiskers plot (not in paper)
ggplot(friends_data) +
  aes(x = has_pronouns, y = precent_match) +
  geom_boxplot() +
  theme_minimal()

ggplot(followers_data) +
  aes(x = has_pronouns, y = precent_match) +
  geom_boxplot() +
  theme_minimal()
