# coding: utf-8
### Script for Python code on the cluster
'''
Author: Liam Tucker
Date: 07/18/2022
Creates a csv file that's the rpevalence of various pronoun lists on each day from 2015-2022
'''

# import pandas as pd
import sqlite3
import csv
import re
import random
from datetime import timedelta, date

def daterange(date1, date2):
    for n in range(int ((date2 - date1).days)+1):
        yield date1 + timedelta(n)

def get_pronoun_prev(pronoun_list):
    '''
    Creates a file displaying the counts of tokens in bios that also contain specific pronoun lists
    Accessed data from a SQL database
    
            Parameters: None
            
            Returns:
                list_of_dicts (list[dict]): A list of dicts, where the data for each row is stored in a dict
            
            Creates:
                Creates a new file from tokens_df, where rows are tokens, columns are pronoun lists, and the data is counts
    
    '''
    #Setting up output data file
    header_row = ['bio_count'] + pronoun_list + ['us_day_YYYY_MM_DD']
    output_dir = '/gpfs/home/letucker/data/'
 
    output_file = output_dir + "daily_prev.csv"
    with open(output_file, 'a', encoding="utf-8", newline='') as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(header_row)
        
    denom = 0

    start_dt = date(2015, 1, 1)
    end_dt = date(2022, 6, 30)

    # Looping through dates to connect to
    for dt in daterange(start_dt, end_dt):

        this_db = "one_bio_per_day_" + dt.strftime("%Y_%m_%d") 
        this_denom = 0
        this_row = [0, 0, 0, 0, 0, 0, dt.strftime("%Y_%m_%d")]
    
        ### Code provided by Dr. Jones
        getBioConn = sqlite3.connect("/gpfs/projects/JonesSkienaGroup/jason_tw/OneBioPerUserPerDay/data/" + this_db + ".sqlite")
        getBioCursor = getBioConn.cursor()
        # Walk through the bios db and get counts.
        getBioCursor.execute("""SELECT * FROM one_bio_per_day_us;""")
    
        for row in getBioCursor:
            denom += 1
            this_denom += 1
            this_row[0] += 1
            # Get the bio as a string.
            if not row[2]: continue
            bioText = row[2]
            # bioText = row[2] if row[2] else continue # This is necessary, because empty bios get retrieved as None. re.search will error on None.
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
        
            # Noting if there's a pronoun list in the bio
            # pronoun_in_bio = False
            for i in range(len(pronoun_list)):
                if pronoun_list[i] in tokens:
                    this_row[i+1] += 1
    
        if this_row[0] != 0:
            for i in range(len(pronoun_list)):
                this_row[i + 1] = 100000.0 * this_row[i + 1] / this_row[0]
        with open(output_file, 'a', encoding="utf-8", newline='') as csvfile:
            csvwriter = csv.writer(csvfile)
            csvwriter.writerow(this_row)
        print(this_row)

    print("Created file:", output_file)
    # print("Denom:", denom)
            
        
        
def main():
    # get_pronoun_prev(['she/her', 'he/him', 'they/them', 'she/they', 'he/they'])
    get_pronoun_prev(['he/him', 'she/her', 'they/them', 'she/they', 'he/they'])
    # get_pronoun_bios(['they/them'])
    
    
if __name__ == '__main__':
    main()
    
