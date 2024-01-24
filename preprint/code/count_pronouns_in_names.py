'''
This code calculates the prevalence of pronoun lists in name, location, and bio fields.
'''

import sqlite3
import csv
import re
from datetime import timedelta, date

### Code provided by Dr. Jones
getBioConn = sqlite3.connect("/gpfs/projects/JonesSkienaGroup/jason_tw/OneBioPerUserPerYear/data/one_bio_per_year_2022.sqlite")
getBioCursor = getBioConn.cursor()
# Walk through the bios db and get counts.
getBioCursor.execute("""SELECT bio, location, name FROM one_bio_per_user_per_year;""")

# Hardcoding the pronouns I'll be looking at
pronoun_list = ['he/him', 'she/her', 'they/them', 'he/they', 'she/they']
denom = 0
in_bio = 0
in_name = 0
in_location = 0

for row in getBioCursor:
    this_bio = 0
    this_name = 0
    this_location = 0
    
    bioText = row[0] if row[0] else "" # This test is necessary, because empty bios get retrieved as None. re.search will error on None.
    bioText = bioText.casefold()
    locText = row[1] if row[1] else "" # This test is necessary, because empty bios get retrieved as None. re.search will error on None.
    locText = locText.casefold()
    nameText = row[2] if row[2] else "" # This test is necessary, because empty bios get retrieved as None. re.search will error on None.
    nameText = nameText.casefold()
    
    for pronoun in pronoun_list:
        if pronoun in bioText: this_bio = 1
        if pronoun in locText: this_location = 1
        if pronoun in nameText: this_name = 1
    
    denom += 1
    in_bio += this_bio
    in_name += this_name
    in_location += this_location
    
print("total bios:", denom)
print("pronoun bios:", in_bio, 100.0 * in_bio / denom)
print("pronoun names:", in_name, 100.0 * in_name / denom)
print("pronoun locations:", in_location, 100.0 * in_location / denom)

