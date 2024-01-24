tp <- fread("/REU/keyword_data/pronouns_binary_prob.csv")

# Looking at data
tp

# Removing multiple row, because it is empty
tp <- tp[1:4]
# Storing binary data seperately
binary_counts <- tp[1]
tp <- tp[2:4]

#Labeling data

colnames(tp) <- c('token', 'overall', 'he/him', 'she/her', 'they/them', 'he/they', 'she/they', 'multiple', 'pronoun list')
tp <- subset(tp, select = - token)
rownames(tp) <- c('non-binary', 'nonbinary', 'non binary')