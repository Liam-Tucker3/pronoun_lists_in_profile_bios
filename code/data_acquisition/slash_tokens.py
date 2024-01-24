# coding: utf-8
### Script for Python code on the cluster
'''
Author: Liam Tucker
Date: 07/05/2022
Gets the token data for only tokens with a '/' in the name
'''


# import pandas as pd
import sqlite3
import csv
import re

# Method that takes bio data from SQL and cre
def get_tokens_data(y):
    '''
    Creates a file displaying the counts of tokens in bios that also contain specific pronoun lists
    Accessed data from a SQL database
    
            Parameters: None
            
            Returns:
                list_of_dicts (list[dict]): A list of dicts, where the data for each row is stored in a dict
            
            Creates:
                Creates a new file from tokens_df, where rows are tokens, columns are pronoun lists, and the data is counts
    
    '''
    
    ### Code provided by Dr. Jones
    conn_str = "/gpfs/projects/JonesSkienaGroup/jason_tw/OneBioPerUserPerYear/data/one_bio_per_year_" + y + ".sqlite"
    getBioConn = sqlite3.connect(conn_str)
    getBioCursor = getBioConn.cursor()

    # Walk through the bios db and get counts.
    getBioCursor.execute("""SELECT bio FROM one_bio_per_user_per_year;""")

    denom = 0
    tokens_dict = {}
    final_df = []
    final_df_columns = ['token', 'count', 'prevalence']
    print("Starting year", y)

    for row in getBioCursor:
        # Increment the count of bios.
        denom += 1
        # Get the bio as a string.
        bioText = row[0] if row[0] else "" # This test is necessary, because empty bios get retrieved as None. re.search will error on None.
        bioText = bioText.casefold()
        # Tokenize on any character not in a specific set.
        #   letters (lowercase or uppercase)
        #   numbers (0-9)
        #   the forward slash (because we don't want to split up pronoun lists)
        #   apostrophes (the three characters commonly used as apostrophes, because we want "it's" to be counted as a token)
        #   hyphen (because words like non-binary should be treated as one entity
        tokens = re.split("[^a-zA-Z0-9/'`’-]", bioText)
        # Make the tokens list into a set.
        # We only want to count 1 if present; we want bio prevalence, not word count.
        tokens = set(tokens)
        
        for token in tokens:
            # Making sure this token is what we want
            if '/' not in token: continue # So we only get slash lists in tokens
            if token in tokens_dict: tokens_dict[token] += 1
            else: tokens_dict[token] = 1

    for token in tokens_dict.keys():
        this_dict = {}
        this_dict['token'] = token
        this_dict['count'] = tokens_dict[token]
        this_dict['prevalence'] = 10000.0 * tokens_dict[token] / denom
        final_df.append(this_dict)
            
    # Output directory in which I'm storing data
    output_dir = "/gpfs/home/letucker/data/slash_data/"
    

    # Sorting list_of_dicts
    final_df = sorted(final_df, key = lambda x:(x['prevalence']), reverse=True)
    
    # Creating final csv file  
    token_file_name = output_dir + 'slash_list_' + y + '.csv'
    with open(token_file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = final_df_columns)
        writer.writeheader()
        writer.writerows(final_df)
    
    print("Created file:", token_file_name)        
    
def main():

    # Creating raw pronoun counts data with each other dataset
    tokens_df = get_tokens_data('2015')
    tokens_df = get_tokens_data('2016')
    tokens_df = get_tokens_data('2017')
    tokens_df = get_tokens_data('2018')
    tokens_df = get_tokens_data('2019')
    tokens_df = get_tokens_data('2020')
    tokens_df = get_tokens_data('2021')  
    
if __name__ == '__main__':
    main()
