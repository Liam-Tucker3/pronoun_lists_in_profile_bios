# coding: utf-8
'''
Author: Liam Tucker
Date: 12/23/2022
'''

# import pandas as pd
import sqlite3
import csv
import re


def get_activity_level(year):
    '''
    Accesses all bios for a given year
    Creates csv file of various attributes for each bio and whether it has a pronoun list
    
            Parameters:
                year (int): which year's data is being accessed. 2015 <= year <= 2022
            
            Returns:
                N/A
            
            Creates:
                Creates a csv file with columns: 
                user_id_str, pronoun_list, verified, followers_count, friends_count, statuses_count, created_at
    '''
    
    # Connecting to database
    database_name = "/gpfs/projects/JonesSkienaGroup/jason_tw/OneBioPerUserPerYear/data/one_bio_per_year_" + str(year) + ".sqlite"
    getBioConn = sqlite3.connect(database_name)
    getBioCursor = getBioConn.cursor()
    
    # Accessing records from database
    getBioCursor.execute("""SELECT user_id_str, bio, verified, followers_count, friends_count, statuses_count, created_at FROM one_bio_per_user_per_year;""")
    
    pronoun_lists = {'he/him', 'she/her', 'they/them', 'he/they', 'she/they'} # Set of pronoun lists
    record_list = [] # Creating dict to store individual records
    
    # Traversing through records
    for row in getBioCursor:
        
        # Determining if bio contains a pronoun list
        this_pronoun_list = "Blank"
        bioText = row[1] if row[1] else "" # This test is necessary, because empty bios get retrieved as None. re.search will error on 
        
        if bioText != "": # Don't need to tokenize bio if blank
            
            bioText = bioText.casefold()
            # Tokenize on any character not in a specific set.
            #   letters (lowercase or uppercase)
            #   numbers (0-9)
            #   the forward slash (because we don't want to split up pronoun lists)
            #   apostrophes (the three characters commonly used as apostrophes, because we want "it's" to be counted as a token)
            tokens = re.split("[^a-zA-Z0-9/'`’]", bioText)
            tokens = set(tokens)
            
            # Finding set intersection-- O(min(m, n)) time complexity
            overlap = tokens.intersection(pronoun_lists)
            if len(overlap) >= 2: this_pronoun_list = "Multiple"
            if len(overlap) == 1:
                for el in overlap: this_pronoun_list = el
            if len(overlap) == 0: this_pronoun_list = "None"       
 
        # Adding record to record_dict
        this_record = {'user_id_str': row[0],
                       'pronoun_list': this_pronoun_list,
                       'verified': row[2],
                       'followers_count': row[3],
                       'friends_count': row[4],
                       'statuses_count': row[5],
                       'created_at': row[6]}
        record_list.append(this_record)
        
    # Writing data to csv file 
    file_name = "/gpfs/home/letucker/data/activity_level_data_" + str(year) + ".csv"
    column_names = ['user_id_str', 'pronoun_list', 'verified', 'followers_count', 'friends_count', 'statuses_count', 'created_at']
    with open(file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = column_names)
        writer.writeheader()
        writer.writerows(record_list)
    
    print("Created file:", file_name)
    
def main():
    get_activity_level(2022)
    
if __name__ == '__main__':
    main()
