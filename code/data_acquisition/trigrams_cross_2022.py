# coding: utf-8
'''
Author: Liam Tucker
Date: 01/12/2023
Adapted from bigram_generation.py
'''

# import pandas as pd
import sqlite3
import csv
import re

# Method that removes entries with value < count for dict formatted as we have
def trim_dictionary(dict, count):
    for key in list(dict):
        if dict[key][1] < count: del dict[key]
    return dict
    

# Method that takes bio data from SQL and cre
def get_trigram_data(cutoff):
    '''
    Creates a file displaying the counts of trigrams in bios that also contain specific pronoun lists
    Accessed data from a SQL database
    
            Parameters: 
                cutoff (int): The prevalence that a trigram must have after 100,000 bios to be included
            
            Returns:
                list_of_dicts (list[dict]): A list of dicts, where the data for each row is stored in a dict
            
            Creates:
                Creates a new file from tokens_df, where rows are trigrams, columns are pronoun lists, and the data is counts
    
    '''
    
    ### Code provided by Dr. Jones
    getBioConn = sqlite3.connect("/gpfs/projects/JonesSkienaGroup/jason_tw/OneBioPerUserPerYear/data/one_bio_per_year_2022.sqlite")
    getBioCursor = getBioConn.cursor()

    # Walk through the bios db and get counts.
    # Ordering randomly, because we disregard tokens that don't appear with a prevalence of at least 1 within a subset of bios
    getBioCursor.execute("""SELECT bio FROM one_bio_per_user_per_year ORDER BY RANDOM();""")
   

    # Hardcoding the pronouns I'll be looking at
    pronoun_list = ['he/him', 'she/her', 'they/them', 'he/they', 'she/they']
    columns = ['trigram', 'overall'] + pronoun_list + ['multiple', 'pronoun list']
    blank_list = [0 for i in range(len(pronoun_list))] # A list of 0s the length of pronouns_list
    trigram_dict = {} #The keys will be trigrams, 
                # The values will be lists storing the number of times the value appears overall and in bios with a specific pronoun list
    pronoun_counts = ['**BIO_COUNT**', 0] + blank_list + [0, 0] # A row showing the number of times each pronoun set appears (the denominator)
    denom = 0

    for row in getBioCursor:
        # Trim the dictionary after 100,000 bios to save time
        # if denom == 100000: bigram_dict = trim_dictionary(bigram_dict, cutoff*10)
        
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
        tokens = [i for i in tokens if i != ""] # Removing any extraneously added characters
        
        # Create empty dict of trigrams
        # Ensures that we don't count any trigram twice for one bio
        this_bio_trigrams = {}
    
        # Seeing which pronoun lists appear in this dataset
        this_bio_pronouns = 'none'
        for i in range(len(pronoun_list)):
            if (pronoun_list[i] in tokens):
                if this_bio_pronouns == 'none': this_bio_pronouns = i
                else: this_bio_pronouns = 'multiple'
        # this_bio_pronouns should now contain either "none"; "multiple"; or an index.
        # if this_bio_pronouns has index i, that means the only pronoun list contained in this bio is pronouns_list[i]
        
        for i in range(len(tokens) - 2): # No trigram starting with last or second to last token
            # No trigrams containing a pronoun list
            if tokens[i] in pronoun_list or tokens[i+1] in pronoun_list or tokens[i+2] in pronoun_list: continue 
            # No duplicate trigrams
            trigram = (tokens[i], tokens[i+1], tokens[i+2])
            if trigram in this_bio_trigrams.keys(): continue
            else: this_bio_trigrams[trigram] = 1
            
            # Adding trigram to the trigram dictionary
            if trigram in trigram_dict:
                temp_array = trigram_dict[trigram]
                temp_array[1] = temp_array[1] + 1
                trigram_dict[trigram] = temp_array
            # elif denom > 100000: continue # Only adding new trigrams to dict for first 100,000 bios
            else: trigram_dict[trigram] = [trigram, 1] + blank_list + [0, 0]
    
            #Noting if this trigram appeared alongside a pronoun list
            if this_bio_pronouns != 'none':
                temp_array = trigram_dict[trigram]
                if this_bio_pronouns == 'multiple': temp_array[-2] = temp_array[-2] + 1
                else: temp_array[this_bio_pronouns + 2] = temp_array[this_bio_pronouns + 2] + 1 # Because first two columns are "trigram" and "overall"   
                temp_array[-1] += 1               
                trigram_dict[trigram] = temp_array
    
        #Incrementing pronoun_counts  
        pronoun_counts[1] += 1
        if this_bio_pronouns != 'none': # Meaning a pronoun list appeared
            pronoun_counts[-1] += 1
            # Counting the number of this pronoun
            if this_bio_pronouns == 'multiple': pronoun_counts[-2] += 1
            else: pronoun_counts[this_bio_pronouns + 2] += 1

    # Output directory in which I'm storing data
    output_dir = "/gpfs/home/letucker/data/trigram_data/"  

    trigram_dict = trim_dictionary(trigram_dict, cutoff * denom / 10000.0) 

    # Creating list of dicts that will become a csv    
    list_of_dicts = []
    for trigram in trigram_dict.keys():
        this_dict = {}
        this_row = trigram_dict[trigram]
        for i in range(len(columns)):
            if i == 0: this_dict[columns[i]] = this_row[i][0] + " " + this_row[i][1] + " " + this_row[i][2]
            else: this_dict[columns[i]] = this_row[i]
        list_of_dicts.append(this_dict)    
 
    # Adding pronoun_counts to list_of_dicts, to be accessed in other places
    temp_dict = {}
    for i in range(len(pronoun_counts)):
        temp_dict[columns[i]] = pronoun_counts[i]
    list_of_dicts.insert(0, temp_dict)    
       
    # Sorting list_of_dicts
    list_of_dicts = sorted(list_of_dicts, key = lambda x:(x['overall'], x['pronoun list']), reverse=True)
    
    # Creating final csv file  
    token_file_name = output_dir + 'sampled_trigrams_2022.csv'
    with open(token_file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = columns)
        writer.writeheader()
        writer.writerows(list_of_dicts)
    
    print("Created file:", token_file_name)
    return list_of_dicts   
  

    
def convert_to_prevalences(list_of_dicts2):
    '''
    Creates a file displaying the prevalences of tokens
    
            Parameters:
                list_of_dicts (list[dict]): A list of dicts, where the data for each row is stored in a dict
            
            Returns:
                new_file_name (string): The file path for the output file
            
            Creates:
                Creates a new file, in the same format as the input file. In place of raw counts, the output file contains prevalences
    
    '''
    
    # Hardcoding the pronouns I'll be looking at
    pronoun_list = ['he/him', 'she/her', 'they/them', 'he/they', 'she/they']
    columns = ['trigram', 'overall'] + pronoun_list + ['multiple', 'pronoun list']
    
    # Making a local copy of tokens_df
    prev_frame = list_of_dicts2 #***** NOT A DATA FRAME
    
    # Accessing the count of bios in each pronoun category, then removing it from the data file
    total_counts = prev_frame.pop(0)
    
    
    # Calculating prevalence for each token, given that it contains the specified token
    for i in range(len(prev_frame)):
        temp_dict = prev_frame[i]
        for pronoun in columns[1:]:
            if (total_counts[pronoun] == 0): temp_dict[pronoun] = 0
            else : temp_dict[pronoun] = round(10000.0 * temp_dict[pronoun] / total_counts[pronoun], 3)
        prev_frame[i] = temp_dict
                   
    # Output directory in which I'm storing data
    output_dir = "/gpfs/home/letucker/data/trigram_data/"
                   
    # Sorting list_of_dicts
    prev_frame = sorted(prev_frame, key = lambda x:(x['pronoun list'], x['overall']), reverse=True)
    
    # Creating final csv file  
    token_file_name = output_dir + 'sampled_trigrams_prev_2022.csv'
    with open(token_file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = columns)
        writer.writeheader()
        writer.writerows(prev_frame)
    
    print("Created file:", token_file_name)
    return token_file_name  
    
    
def convert_to_relative_prevalences(list_of_dicts):
    '''
    Creates a file displaying the prevalences of tokens
    
            Parameters:
                list_of_dicts (list[dict]): A list of dicts, where the data for each row is stored in a dict
            
            Returns:
                new_file_name (string): The file path for the output file
            
            Creates:
                Creates a new file, in the same format as the input file. In place of raw counts, the output file contains prevalences of trigrams in bios with pronouns, relative to prevalence of trigrams in all bios 
    
    '''
                   
    # Hardcoding the pronouns I'll be looking at
    pronoun_list = ['he/him', 'she/her', 'they/them', 'he/they', 'she/they']
    columns = ['trigram', 'overall'] + pronoun_list + ['multiple', 'pronoun list']
    
    # Making a local copy of tokens_df
    rel_frame = list_of_dicts #***** NOT A DATA FRAME
    
    # Accessing the count of bios in each pronoun category, then removing it from the data file
    total_counts = rel_frame.pop(0)
    
    
    # Calculating probability a bio contains a pronoun list, given that it contains the specified token
    for i in range(len(rel_frame)):
        temp_dict = rel_frame[i]
        for pronoun in columns[1:]:
            if (total_counts[pronoun] == 0):
                temp_dict[pronoun] = 0
                continue
            temp_dict[pronoun] = round(10000.0 * temp_dict[pronoun] / total_counts[pronoun], 3)
            # Now creating relative prevalences
            if pronoun != 'overall':
                if temp_dict[pronoun] >= temp_dict['overall']: #Will be a positive relative prevalence
                    temp_dict[pronoun] = round(1.0 * temp_dict[pronoun] / temp_dict['overall'], 3)
                else:
                    if (temp_dict[pronoun] != 0):
                        temp_dict[pronoun] = round(-1.0 * temp_dict['overall'] / temp_dict[pronoun], 3)
        rel_frame[i] = temp_dict
                   
    # Output directory in which I'm storing data
    output_dir = "/gpfs/home/letucker/data/trigram_data/"
                   
    # Sorting list_of_dicts
    rel_frame = sorted(rel_frame, key = lambda x:(x['pronoun list'], x['overall']), reverse=True)
    
    # Creating final csv file  
    token_file_name = output_dir + 'sampled_trigrams_rel_prev_2022.csv'
    with open(token_file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = columns)
        writer.writeheader()
        writer.writerows(rel_frame)
    
    print("Created file:", token_file_name)
    return token_file_name 
        
    
def main():

    overall_cutoff = 1

    # Creating raw pronoun counts data with each other dataset
    tokens_df2 = get_trigram_data(overall_cutoff)
    total_counts = tokens_df2[0]
    convert_to_prevalences(tokens_df2)

    tokens_df3 = get_trigram_data(overall_cutoff)
    total_counts = tokens_df3[0]
    convert_to_relative_prevalences(tokens_df3)
    
    
    
if __name__ == '__main__':
    main()
