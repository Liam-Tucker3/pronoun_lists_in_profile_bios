import csv
import random
import tweepy
import pandas as pd
import schedule
import time
import re
from datetime import datetime

    

'''
# Setup
follower_list_name = "C:/REU/network_cluster/friend_percentages.csv"
this_bio_columns = ['user_id', 'has_pronouns', 'followers_sampled', 'raw_match', 'raw_non_match', 'percent_match', 'percent_non_match']
with open(follower_list_name, 'w', encoding="utf-8", newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow(this_bio_columns)
'''

# Getting ID lists
pronoun_ids = pd.read_csv(r"C:/REU/network_cluster/pronoun_ids.csv")
pronoun_ids = pronoun_ids['0'].tolist()

non_pronoun_ids = pd.read_csv(r"C:/REU/network_cluster/no_pronoun_ids.csv")
non_pronoun_ids = non_pronoun_ids['0'].tolist()

searched_pronoun_ids = set()
searched_non_pronoun_ids = set()

print('Starting data collection')
        
# Setup: put your own keys into the quotes
consumer_key = ""
consumer_secret = ""
access_token = ""
access_token_secret = ""

pronoun_in_bio = True
pronoun_list = ['he/him', 'she/her', 'they/them', 'he/they', 'she/they']

follower_list_name = "C:/REU/network_cluster/friend_percentages.csv"

#should not be global because it's specific to each user
pages = 0
has_more = True
cursor = -1
t_followers = 0
  
#matching increments if the follower is in the same group as the source user (both have pronouns or both don't)
matching_followers = 0
non_matching_followers = 0

while True:
    if pronoun_in_bio:
        s_userid = random.sample(pronoun_ids, k=1)[0]
        if s_userid not in searched_pronoun_ids: # We have unique ID
            searched_pronoun_ids.add(s_userid)
            break
    else:
        s_userid = random.sample(non_pronoun_ids, k=1)[0]
        if s_userid not in searched_non_pronoun_ids:  # We have unique ID
            searched_non_pronoun_ids.add(s_userid)
            break


# One call to search_followers will get ALL the data for one user
def search_friends():
    #needs to be global because we want it to swap back and forth between repeated method calls
    global pronoun_in_bio
    global pages
    global has_more
    global cursor
    global t_followers
    global matching_followers
    global non_matching_followers
    global s_userid
    global searched_pronoun_ids
    global searched_non_pronoun_ids
    
    # To count the number of times we actually called get_followers
    api_accesses = 0

    # authorization of consumer key and consumer secret
    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    # set access to user's access key and access secret
    auth.set_access_token(access_token, access_token_secret)
    # calling the api
    api = tweepy.API(auth)
    
    while api_accesses < 15:
    
        '''
        # Getting s_userid
        while True:
            if pronoun_in_bio:
                s_userid = random.sample(pronoun_ids, k=1)[0]
                if s_userid not in searched_pronoun_ids: # We have unique ID
                    searched_pronoun_ids.add(s_userid)
                    break
            else:
                s_userid = random.sample(non_pronoun_ids, k=1)[0]
                if s_userid not in searched_non_pronoun_ids:  # We have unique ID
                    searched_non_pronoun_ids.add(s_userid)
                    break
        '''   
        '''
        #only continue if the user still has followers to look at AND we haven't looked at 1000 yet
        while has_more == True and pages < 5:
            pages += 1
        '''
        
        if has_more == False or pages >= 5:
            reset_data()
            continue
            
        # Accessing another 200 followers for this user
        pages += 1
        api_accesses += 1

        try:
            followers = api.get_friends(user_id = s_userid, count = 200, cursor = cursor)
            cursor = followers[1][1]
        except Exception as e:
            print(e)
            reset_data()
            continue

        # if the user has no more followers, we don't do another loop
        if cursor == 0: has_more = False

        for follower in followers[0]:
            follower_bio_pronouns = False
            #print(follower.id)
            # Prepping bio
            
            bio = follower.description if follower.description else ""

            bioText = bio.casefold()
            tokens = re.split("[^a-zA-Z0-9/'`’]", bioText)
            tokens = set(tokens)
            # Seeing which pronoun lists appear in this dataset
            follower_bio_pronouns = False
            for j in range(len(pronoun_list)):
                if (pronoun_list[j] in tokens):
                    follower_bio_pronouns = True
                    # break

            t_followers += 1
            if follower_bio_pronouns == pronoun_in_bio:
                #if the boolean matches, the users are of the same type
                matching_followers += 1
            else: 
                non_matching_followers += 1

        if has_more == False or pages >= 5:
            if t_followers == 0:
                reset_data()
                continue
            #this is outside the while loop because it happens once for each user
            #we want proportions, so we need to divide last two columns by the total
            this_row = [s_userid, 0, t_followers, matching_followers, non_matching_followers, matching_followers / t_followers, non_matching_followers / t_followers]
            if pronoun_in_bio: this_row[1] = 1

            with open(follower_list_name, 'a', encoding="utf-8", newline='') as csvfile:
                csvwriter = csv.writer(csvfile)
                csvwriter.writerow(this_row)
            print(s_userid, "with", t_followers, "records.", str(datetime.now()))
            reset_data()
        
def reset_data():
    global pronoun_in_bio
    global pages
    global has_more
    global cursor
    global t_followers
    global matching_followers
    global non_matching_followers
    global s_userid    
    global searched_pronoun_ids
    global searched_non_pronoun_ids
    # global follower_bio_pronouns

    pronoun_in_bio = not pronoun_in_bio
    pages = 0
    has_more = True
    cursor = -1
    t_followers = 0
    matching_followers = 0
    non_matching_followers = 0
    # follower_bio_pronouns = False    

    while True:
        if pronoun_in_bio:
            s_userid = random.sample(pronoun_ids, k=1)[0]
            if s_userid not in searched_pronoun_ids: # We have unique ID
                searched_pronoun_ids.add(s_userid)
                break
        else:
            s_userid = random.sample(non_pronoun_ids, k=1)[0]
            if s_userid not in searched_non_pronoun_ids:  # We have unique ID
                searched_non_pronoun_ids.add(s_userid)
                break



schedule.every(15).minutes.do(search_friends)

while True:
    schedule.run_pending()
    time.sleep(1)
