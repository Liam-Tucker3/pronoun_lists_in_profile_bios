'''
Author: Liam Tucker
Date: 01/18/23
This code selects n random bios from 2022 and writes bios to a csv file. Can be used to simply see how tokens are used. 
'''

import sqlite3
import csv
import re
from datetime import timedelta, date

### Code provided by Dr. Jones
getBioConn = sqlite3.connect("/gpfs/projects/JonesSkienaGroup/jason_tw/OneBioPerUserPerYear/data/one_bio_per_year_2022.sqlite")
getBioCursor = getBioConn.cursor()
# user_id_str is as a unique identifier only
getBioCursor.execute("""SELECT user_id_str, bio FROM one_bio_per_user_per_year ORDER BY RANDOM() LIMIT 250000;""")

data = []
colnumns = ['user_id_str', 'bio']

for row in getBioCursor:
    
    bioText = row[1] if row[1] else "" 
    user_id = row[0] if row[0] else ""
    
    this_dictionary = {'user_id_str': user_id, 'bio': bioText}
    data.append(this_dictionary)
    
# Creating output csv file  
output_dir = "/gpfs/home/letucker/data/"
file_name = output_dir + 'random_250000_bios.csv'
with open(file_name, 'w', encoding="utf-8") as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames = columns)
    writer.writeheader()
    writer.writerows(data)
    
print("Created file:", file_name) 

