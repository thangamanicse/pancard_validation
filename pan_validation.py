import pandas as pd 
import re

#1) cleaing the data 
#importing data set
df  =pd.read_excel('PAN Number Validation Dataset.xlsx')
total_records=len(df)


#handling space and lowercase to uppercase
df["Pan_Numbers"]=df['Pan_Numbers'].astype('string').str.strip().str.upper()

# removeing null values
df=df.replace({"Pan_Numbers":''}, pd.NA).dropna(subset="Pan_Numbers")


#removing duplicate values
df=df.drop_duplicates(subset="Pan_Numbers",keep='first')
print(len(df))

#2) validate the data

#checking if it has repeatation 
def has_adjacent_repeatation(pan): #AABCD
 
    return any(pan[i]==pan[i+1] for i in range(len(pan)-1))
# print(has_adjacent_repeatation('AABCD'))
# print(has_adjacent_repeatation('AIBCD'))


def has_sequentitial(pan):

    return all(ord(pan[i+1])-ord(pan[i])==1 for i in range(len(pan)-1))
# print(has_sequentitial('ABDFG'))
# print(has_sequentitial('AHDFk'))
        
# overall validation 

def is_valid_pan(pan):
    if len(pan)!=10:
        return False
    if not re.match( r"^[A-Z]{5}[0-9]{4}[A-Z]$",pan):
        return False
    if has_adjacent_repeatation(pan):
        return False
    if has_sequentitial(pan):
        return False
    return True
            
df["status"]=df["Pan_Numbers"].apply(lambda x:"valid" if is_valid_pan(x) else "invalid")
#3) final report 
valid_count=(df["status"]=='valid').sum()
invalid_count=(df["status"]=='invalid').sum()
print("total_records=",total_records)
print("valid_count",valid_count)
print("invalid_count",invalid_count)
print("missing_or_incomple",total_records-(valid_count+invalid_count))