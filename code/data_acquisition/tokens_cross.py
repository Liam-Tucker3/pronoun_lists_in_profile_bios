# coding: utf-8
'''
Author: Liam Tucker
Date: 01/13/2022
This script is identical to tokens_cross_2022.py, except it allows for various regex expressions for tokenization
'''


# import pandas as pd
import sqlite3
import csv
import re

# Method that takes bio data from SQL database and creates csv file of token counts
def get_tokens_data(year, regex_expression):
    '''
    Creates a file displaying the counts of tokens in bios that also contain specific pronoun lists
    Accessed data from a SQL database
    
            Parameters:
                year (string): the year whose data is being accesed
                regex_expression: the regex expression being used for tokenization
            
            Returns:
                list_of_dicts (list[dict]): A list of dicts, where the data for each row is stored in a dict
            
            Creates:
                Creates a new file from tokens_df, where rows are tokens, columns are pronoun lists, and the data is counts
    
    '''
    
    ### Code provided by Dr. Jones
    db_name = "/gpfs/projects/JonesSkienaGroup/jason_tw/OneBioPerUserPerYear/data/one_bio_per_year_" + year + ".sqlite"
    getBioConn = sqlite3.connect(db_name)
    getBioCursor = getBioConn.cursor()

    # Walk through the bios db and get counts.
    getBioCursor.execute("""SELECT bio FROM one_bio_per_user_per_year;""")

    # Hardcoding the pronouns I'll be looking at
    pronoun_list = ['he/him', 'she/her', 'they/them', 'he/they', 'she/they']
    columns = ['token', 'overall'] + pronoun_list + ['multiple', 'pronoun list']
    blank_list = [0 for i in range(len(pronoun_list))] # A list of 0s the length of pronouns_list
    tokens_dict = {} #The keys will be tokens, 
                # The values will be lists storing the number of times the value appears overall and in bios with a specific pronoun list
    pronoun_counts = ['**BIO_COUNT**', 0] + blank_list + [0, 0] # A row showing the number of times each pronoun set appears (the denominator)
    denom = 0

    for row in getBioCursor:
        # Increment the count of bios.
        denom += 1
        # Get the bio as a string.
        bioText = row[0] if row[0] else "" # This test is necessary, because empty bios get retrieved as None. re.search will error on None.
        bioText = bioText.casefold()
        tokens = re.split(regex_expression, bioText)
        tokens = set(tokens) # Avoids double counting tokens that appear multiple times in same bio
    
        # Determining which pronoun lists appear in this dataset
        this_bio_pronouns = 'none'
        for i in range(len(pronoun_list)):
            if (pronoun_list[i] in tokens):
                if this_bio_pronouns == 'none': this_bio_pronouns = i
                else: this_bio_pronouns = 'multiple'
        # this_bio_pronouns should now contain either "none"; "multiple"; or an index.
        # if this_bio_pronouns has index i, that means the only pronoun list contained in this bio is pronouns_list[i]
    
        for token in tokens:
            if token == '': continue
    
            # Adding token to the token dictionary
            if token in tokens_dict:
                temp_array = tokens_dict[token]
                temp_array[1] = temp_array[1] + 1
                tokens_dict[token] = temp_array
            else:
                tokens_dict[token] = [token, 1] + blank_list + [0, 0]
    
            #Noting if this token appeared alongside a pronoun list
            if this_bio_pronouns != 'none':
                temp_array = tokens_dict[token]
                if this_bio_pronouns == 'multiple': temp_array[-2] = temp_array[-2] + 1
                else: temp_array[this_bio_pronouns + 2] = temp_array[this_bio_pronouns + 2] + 1 # Because first two columns are "token" and "overall"   
                temp_array[-1] += 1               
                tokens_dict[token] = temp_array
    
        #Incrementing pronoun_counts  
        pronoun_counts[1] += 1
        if this_bio_pronouns != 'none': # Meaning a pronoun list appeared
            pronoun_counts[-1] += 1
            # Counting the number of this pronoun
            if this_bio_pronouns == 'multiple': pronoun_counts[-2] += 1
            else: pronoun_counts[this_bio_pronouns + 2] += 1
    
    # Removing any tokens that don't appear in a bio with pronouns
    token_delete_list = []
    for token in tokens_dict.keys():
        this_row = tokens_dict[token]
        if this_row[-1] == 0: token_delete_list.append(token)
        elif 'she/her' in this_row[0] or 'he/him' in this_row[0] or 'they/them' in this_row[0]: token_delete_list.append(token) #To prevent other pronoun lists from being ni the dataset
    for token in token_delete_list:
        del tokens_dict[token]
        
    # Removing pronoun tokens from bio 
    for pronoun in pronoun_list: #Shouldn't apply anymore
        if pronoun in tokens_dict.keys(): del tokens_dict[pronoun]
        
    # Output directory in which I'm storing data
    output_dir = "/gpfs/home/letucker/data/token_data/"

    # Creating list that can become csv the new way    
    list_of_dicts = []
    for token in tokens_dict.keys():
        this_dict = {}
        this_row = tokens_dict[token]
        for i in range(len(columns)):
            this_dict[columns[i]] = this_row[i]
        list_of_dicts.append(this_dict)    
 
    # Adding pronoun_counts to list_of_dicts, to be accessed in other places
    temp_dict = {}
    for i in range(len(pronoun_counts)):
        temp_dict[columns[i]] = pronoun_counts[i]
    list_of_dicts.insert(0, temp_dict)    
       
    # Sorting list_of_dicts
    list_of_dicts = sorted(list_of_dicts, key = lambda x:(x['overall'], x['pronoun list']), reverse=True)
    
    # Creating final csv file  
    token_file_name = output_dir + 'sampled_tokens_' + year + '.csv'
    with open(token_file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = columns)
        writer.writeheader()
        writer.writerows(list_of_dicts)
    
    print("Created file:", token_file_name)
    return list_of_dicts   
  
    
def convert_to_prevalences(list_of_dicts, total_counts, ov_cutoff, pr_cutoff, year):
    '''
    Creates a file displaying the prevalences of tokens
    
            Parameters:
                list_of_dicts (list[dict]): A list of dicts, where the data for each row is stored in a dict
                total counts (list[int]): A list with the counts of each pronoun list
                ov_cutoff (int): A cutoff-- any token with a prevalence less than ov_cutoff is removed from the final csv file
                pr_cutoff (int): A cutoff-- any token with a prevalence less than pr_cutoff is removed from the final csv file
                year (string): The year the data is from (only used for output filename)
            
            Returns:
                new_file_name (string): The file path for the output file
            
            Creates:
                Creates a new file, in the same format as the input file. In place of raw counts, the output file contains prevalences
    
    '''
    
    # Hardcoding the pronouns I'll be looking at
    pronoun_list = ['he/him', 'she/her', 'they/them', 'he/they', 'she/they']
    columns = ['token', 'overall'] + pronoun_list + ['multiple', 'pronoun list']
    
    # Making a local copy of tokens_df
    prev_frame = list_of_dicts #***** NOT A DATA FRAME
    
    # Accessing the count of bios in each pronoun category, then removing it from the data file
    last_index = len(total_counts) - 1
    prev_frame.pop(0)
    
    # Removing tokens with a prevalence of less than 1 per 10,000 bios
    delete_rows = []
    for i in range(len(prev_frame)):
        temp_dict = prev_frame[i]  
        if temp_dict['overall'] * 10000.0 / total_counts['overall'] < ov_cutoff: delete_rows.append(i)
        elif temp_dict['pronoun list'] * 10000.0 / total_counts['pronoun list'] < pr_cutoff: delete_rows.append(i)
    for i in reversed(range(len(delete_rows))):
        del prev_frame[delete_rows[i]]
    
    # Calculating probability a bio contains a pronoun list, given that it contains the specified token
    for i in range(len(prev_frame)):
        temp_dict = prev_frame[i]
        for pronoun in columns[1:]:
            if (total_counts[pronoun] == 0): temp_dict[pronoun] = 0
            else : temp_dict[pronoun] = round(10000.0 * temp_dict[pronoun] / total_counts[pronoun], 3)
        prev_frame[i] = temp_dict
                   
    # Output directory in which I'm storing data
    output_dir = "/gpfs/home/letucker/data/token_data/"
                   
    # Sorting list_of_dicts
    prev_frame = sorted(prev_frame, key = lambda x:(x['pronoun list'], x['overall']), reverse=True)
    
    # Creating final csv file  
    token_file_name = output_dir + 'sampled_tokens_prev_' + year + '.csv'
    with open(token_file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = columns)
        writer.writeheader()
        writer.writerows(prev_frame)
    
    print("Created file:", token_file_name)
    return token_file_name  
    
    
def convert_to_relative_prevalences(list_of_dicts, total_counts, ov_cutoff, pr_cutoff, year):
    '''
    Creates a file displaying the prevalences of tokens
    
            Parameters:
                list_of_dicts (list[dict]): A list of dicts, where the data for each row is stored in a dict
                total counts (list[int]): A list with the counts of each pronoun list
                ov_cutoff (int): A cutoff-- any token with a prevalence less than ov_cutoff is removed from the final csv file
                pr_cutoff (int): A cutoff-- any token with a prevalence less than pr_cutoff is removed from the final csv file
                year (string): The year the data is from (only used for output filename)
            
            
            Returns:
                new_file_name (string): The file path for the output file
            
            Creates:
                Creates a new file, in the same format as the input file. In place of raw counts, the output file contains prevalences of tokens in bios with pronouns, relative to prevalence of token in all bios 
    
    '''
                   
    # Hardcoding the pronouns I'll be looking at
    pronoun_list = ['he/him', 'she/her', 'they/them', 'he/they', 'she/they']
    columns = ['token', 'overall'] + pronoun_list + ['multiple', 'pronoun list']
    
    # Making a local copy of tokens_df
    rel_frame = list_of_dicts #***** NOT A DATA FRAME
    
    # Accessing the count of bios in each pronoun category, then removing it from the data file
    last_index = len(total_counts) - 1
    rel_frame.pop(0)
    
    # Removing tokens with a prevalence of less than 1 per 10,000 bios
    delete_rows = []
    for i in range(len(rel_frame)):
        temp_dict = rel_frame[i]  
        if temp_dict['overall'] * 10000.0 / total_counts['overall'] < ov_cutoff: delete_rows.append(i)
        elif temp_dict['pronoun list'] * 10000.0 / total_counts['pronoun list'] < pr_cutoff: delete_rows.append(i)
    for i in reversed(range(len(delete_rows))):
        del rel_frame[delete_rows[i]]
    
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
    output_dir = "/gpfs/home/letucker/data/token_data/"
                   
    # Sorting list_of_dicts
    rel_frame = sorted(rel_frame, key = lambda x:(x['pronoun list'], x['overall']), reverse=True)
    
    # Creating final csv file  
    token_file_name = output_dir + 'sampled_tokens_rel_prev_' + year + '.csv'
    with open(token_file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = columns)
        writer.writeheader()
        writer.writerows(rel_frame)
    
    print("Created file:", token_file_name)
    return token_file_name 
        
    
def main():

    overall_cutoff = 1
    pronoun_cutoff = 1
    year = "2022"
    
    # Tokenize on any character not in a specific set.
    #   letters (lowercase or uppercase)
    #   numbers (0-9)
    #   the forward slash (because we don't want to split up pronoun lists)
    #   apostrophes (the three characters commonly used as apostrophes, because we want "it's" to be counted as a token)
    original_tokenization = "[^a-zA-Z0-9/'`’]"
    
    # Additionally does not split words at dash
    updated_tokenization = "[^a-zA-Z0-9/'`’-]"

    # Creating raw pronoun counts data with each other dataset
    tokens_df = get_tokens_data(year, updated_tokenization)
    total_counts = tokens_df[0]
    convert_to_prevalences(tokens_df, total_counts, overall_cutoff, pronoun_cutoff, year)

    tokens_df2 = get_tokens_data(year, updated_tokenization)
    total_counts = tokens_df2[0]
    convert_to_relative_prevalences(tokens_df2, total_counts, overall_cutoff, pronoun_cutoff, year)
    
    
    
if __name__ == '__main__':
    main()
