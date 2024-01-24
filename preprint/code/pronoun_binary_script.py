# coding: utf-8
'''
Author: Liam Tucker
Date: 07/13/2022
'''

# import pandas as pd
import sqlite3
import csv
import re

# Method that takes bio data from SQL and creates cs file of counts
def get_tokens_data():
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
    getBioConn = sqlite3.connect("/gpfs/projects/JonesSkienaGroup/jason_tw/OneBioPerUserPerYear/data/one_bio_per_year_2022.sqlite")
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
    
    keywords = ['binary', 'nonbinary', 'non-binary', 'non binary', 'multiple']
    list_of_dicts = []
    for key in keywords:
        this_dict = {}
        this_dict['token'] = key
        this_dict['overall'] = 0
        for pronoun in pronoun_list:
            this_dict[pronoun] = 0
        this_dict['multiple'] = 0
        this_dict['pronoun list'] = 0
    keywords = keywords[:3]


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
        
        # Counting whether binary, non-binary, nonbinary, non binary appear
        add_list = []
        for i in range(len(keywords)):
            if keywords[i] in bioText:
                add_list.append(i)
        if (len(add_list) > 3): add_list[0, 4]
        for i in add_list:
            this_dict = list_of_dicts[i]
            this_dict['overall'] += 1
            if (this_bio_pronouns != 'none'):
                list_of_dicts['pronoun list'] += 1
                list_of_dicts[this_bio_pronouns] += 1
            
         
    # Output directory in which I'm storing data
    output_dir = "/gpfs/scratch/letucker/keyword_data/"
    
    # Sorting list_of_dicts
    list_of_dicts = sorted(list_of_dicts, key = lambda x:(x['overall'], x['pronoun list']), reverse=True)
    
    # Creating final csv file  
    token_file_name = output_dir + 'binary_pronouns.csv'
    with open(token_file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = columns)
        writer.writeheader()
        writer.writerows(list_of_dicts)
    
    print("Created file:", token_file_name)
    return list_of_dicts   
  
    
def convert_to_probabilities(list_of_dicts1, ov_cutoff, pr_cutoff):
    '''
    Creates a file displaying the probabilities a bio contains a pronoun lists, given that it contains a token
    
            Parameters:
                list_of_dicts1 (list[dict]): A list of dicts, where the data for each row is stored in a dict
            
            Returns:
                new_file_name (string): The file path for the output file
            
            Creates:
                Creates a new file, in the same format as the input file. In place of raw counts, the output file contains the probability for the given pronoun list and token
    
    '''    
    # Hardcoding the pronouns I'll be looking at
    pronoun_list = ['he/him', 'she/her', 'they/them', 'he/they', 'she/they']
    columns = ['token', 'overall'] + pronoun_list + ['multiple', 'pronoun list']
    
    # Making a local copy of tokens_df
    new_frame = list_of_dicts1 #***** NOT A DATA FRAME
    
    # Accessing the count of bios in each pronoun category, then removing it from the data file
    total_counts = new_frame[0] # A dictionary
    last_index = len(total_counts) - 1
    new_frame.pop(0)
    
    # Removing tokens with a prevalence of less than 1 per 10,000 bios
    delete_rows = []
    for i in range(len(new_frame)):
        temp_dict = new_frame[i]  
        if temp_dict['overall'] * 10000.0 / total_counts['overall'] < ov_cutoff: delete_rows.append(i)
        elif temp_dict['pronoun list'] * 10000.0 / total_counts['pronoun list'] < pr_cutoff: delete_rows.append(i)
    for i in reversed(range(len(delete_rows))):
        del new_frame[delete_rows[i]]
    
    # Calculating probability a bio contains a pronoun list, given that it contains the specified token
    for i in range(len(new_frame)):
        temp_dict = new_frame[i]
        for pronoun in columns[2:]:
            temp_dict[pronoun] = round(1.0 * temp_dict[pronoun] / temp_dict['overall'], 3)
        new_frame[i] = temp_dict
                   
    # Output directory in which I'm storing data
    output_dir = "/gpfs/scratch/letucker/keyword_data/"
                   
    # Sorting list_of_dicts
    new_frame = sorted(new_frame, key = lambda x:(x['pronoun list'], x['overall']), reverse=True)
    
    # Creating final csv file  
    token_file_name = output_dir + 'sampled_tokens_prob_2022.csv'
    # token_file_name = '/REU/bio_data/tokens/sampled_tokens_2022_prob_test.csv' #For local tests
    with open(token_file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = columns)
        writer.writeheader()
        writer.writerows(new_frame)
    
    print("Created file:", token_file_name)
    return token_file_name 
    
    
def convert_to_prevalences(list_of_dicts2, total_counts2, ov_cutoff, pr_cutoff):
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
    columns = ['token', 'overall'] + pronoun_list + ['multiple', 'pronoun list']
    
    # Making a local copy of tokens_df
    prev_frame = list_of_dicts2 #***** NOT A DATA FRAME
    
    # Accessing the count of bios in each pronoun category, then removing it from the data file
    last_index = len(total_counts2) - 1
    prev_frame.pop(0)
    
    # Removing tokens with a prevalence of less than 1 per 10,000 bios
    delete_rows = []
    for i in range(len(prev_frame)):
        temp_dict = prev_frame[i]  
        if temp_dict['overall'] * 10000.0 / total_counts2['overall'] < ov_cutoff: delete_rows.append(i)
        elif temp_dict['pronoun list'] * 10000.0 / total_counts2['pronoun list'] < pr_cutoff: delete_rows.append(i)
    for i in reversed(range(len(delete_rows))):
        del prev_frame[delete_rows[i]]
    
    # Calculating probability a bio contains a pronoun list, given that it contains the specified token
    for i in range(len(prev_frame)):
        temp_dict = prev_frame[i]
        for pronoun in columns[1:]:
            if (total_counts2[pronoun] == 0): temp_dict[pronoun] = 0
            else : temp_dict[pronoun] = round(10000.0 * temp_dict[pronoun] / total_counts2[pronoun], 3)
        prev_frame[i] = temp_dict
                   
    # Output directory in which I'm storing data
    output_dir = "/gpfs/scratch/letucker/keyword_data/"
                   
    # Sorting list_of_dicts
    prev_frame = sorted(prev_frame, key = lambda x:(x['pronoun list'], x['overall']), reverse=True)
    
    # Creating final csv file  
    token_file_name = output_dir + 'sampled_tokens_prev_2022.csv'
    with open(token_file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = columns)
        writer.writeheader()
        writer.writerows(prev_frame)
    
    print("Created file:", token_file_name)
    return token_file_name  
    
    
def convert_to_relative_prevalences(list_of_dicts, total_counts, ov_cutoff, pr_cutoff):
    '''
    Creates a file displaying the prevalences of tokens
    
            Parameters:
                list_of_dicts (list[dict]): A list of dicts, where the data for each row is stored in a dict
            
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
    output_dir = "/gpfs/scratch/letucker/keyword_data/"
                   
    # Sorting list_of_dicts
    rel_frame = sorted(rel_frame, key = lambda x:(x['pronoun list'], x['overall']), reverse=True)
    
    # Creating final csv file  
    token_file_name = output_dir + 'sampled_tokens_rel_prev_2022.csv'
    with open(token_file_name, 'w', encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = columns)
        writer.writeheader()
        writer.writerows(rel_frame)
    
    print("Created file:", token_file_name)
    return token_file_name 
        
    
def main():

    overall_cutoff = 1
    pronoun_cutoff = 1

    # Creating raw pronoun counts data with each other dataset
    tokens_df = get_tokens_data()
    total_counts = tokens_df[0]
    convert_to_probabilities(tokens_df, overall_cutoff, pronoun_cutoff)

    tokens_df2 = get_tokens_data()
    total_counts = tokens_df2[0]
    convert_to_prevalences(tokens_df2, total_counts, overall_cutoff, pronoun_cutoff)

    tokens_df3 = get_tokens_data()
    total_counts = tokens_df3[0]
    convert_to_relative_prevalences(tokens_df3, total_counts, overall_cutoff, pronoun_cutoff)
    
    
    
if __name__ == '__main__':
    main()