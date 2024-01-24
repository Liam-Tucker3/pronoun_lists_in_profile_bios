# coding: utf-8
'''
Author: Liam Tucker
Date: 07/13/2022
'''

# This code is adapted from data_visualization_script.ipyn
# That code accesses data in a local csv; this code accesses a SQL database on the cluster

# import pandas as pd
import sqlite3
import csv
import re

# Method that takes bio data from SQL and cre
def id_lists():
    '''
    Creates files containing the ids of users with and without pronouns in their bios
            Parameters: None
            
            Returns:
                None
                
            Creates:
                A csv file with one column and rows are IDs of bios with a pronoun list
                A csv file with one column and rows are IDs of bios without a pronoun list
    
    '''
    
    ### Code provided by Dr. Jones
    getBioConn = sqlite3.connect("/gpfs/projects/JonesSkienaGroup/jason_tw/OneBioPerUserPerYear/data/one_bio_per_year_2022.sqlite")
    getBioCursor = getBioConn.cursor()

    # Walk through the bios db and get counts.
    getBioCursor.execute("""SELECT user_id_str, bio FROM one_bio_per_user_per_year;""")

    # Hardcoding the pronouns I'll be looking at
    pronoun_list = ['he/him', 'she/her', 'they/them', 'he/they', 'she/they']

    denom = 0
    

    non_pronoun_ids = []
    pronoun_ids = []


    for row in getBioCursor:
        # Increment the count of bios.
        denom += 1
        # Get the bio as a string.
        bioText = row[1] if row[1] else "" # This test is necessary, because empty bios get retrieved as None. re.search will error on None.
        bioText = bioText.casefold()
        # Tokenize on any character not in a specific set.
        #   letters (lowercase or uppercase)
        #   numbers (0-9)
        #   the forward slash (because we don't want to split up pronoun lists)
        #   apostrophes (the three characters commonly used as apostrophes, because we want "it's" to be counted as a token)
        tokens = re.split("[^a-zA-Z0-9/'`’]", bioText)
        # Make the tokens list into a set.
        # We only want to count 1 if present; we want bio prevalence, not word count.
        tokens = set(tokens)
    
        # Seeing which pronoun lists appear in this dataset
        this_bio_pronouns = 'none'
        for pronoun in pronoun_list:
            if (pronoun in tokens):
                if this_bio_pronouns == 'none': this_bio_pronouns = pronoun
                else: this_bio_pronouns = 'multiple'
        # this_bio_pronouns should now contain either "none"; "multiple"; or an index.
        # if this_bio_pronouns has index i, that means the only pronoun list contained in this bio is pronouns_list[i]
        
        if this_bio_pronouns == none:
            this_dict = {'id': row[0]}
            non_pronoun_ids.append(this_dict)
        else:
            this_dict = {'id': row[0]}
            pronoun_ids.append(this_dict)
            
    # Output directory in which I'm storing data
    output_dir = "/gpfs/scratch/letucker/id_lists/"
    
    # Creating final pronoun file  
    pronoun_file_name = output_dir + 'pronoun_ids.csv'
    with open(pronoun_file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = 'id')
        writer.writeheader()
        writer.writerows(pronoun_ids)
        
    # Creating final no pronoun file
    no_pronoun_file_name = output_dir + 'no_pronoun_ids.csv'
    with open(no_pronoun_file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = 'id')
        writer.writeheader()
        writer.writerows(no_pronoun_ids)
    
    print("Created file:", pronoun_file_name)
    print("Created file:", no_pronoun_file_name)
    return

    
        
        