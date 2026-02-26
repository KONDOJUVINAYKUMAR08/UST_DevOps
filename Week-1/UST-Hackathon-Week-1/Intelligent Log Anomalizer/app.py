'''3. Intelligent Log "Anomalizer"
Instead of just searching for "Error," this script reads a log file 
and uses a dictionary to count occurrences of every unique word. 
It then flags lines that contain words that appear in less than 1% 
of the total log (finding the "needle in the haystack").

Key Libraries: collections.Counter, re.'''

from collections import Counter

with open("Intelligent Log Anomalizer/app.log") as f:
    lines = f.read()
words = lines.split()
lines_list=lines.split('\n')
# print(ll)
wc = Counter(words)
# print(wc)
total=sum(wc.values())
rare_list=[]
for i in wc.keys():
    t=wc[i]
    if (t/total)*100 <1:
        rare_list.append(i)

count=1
for i in lines_list:
    for j in rare_list:
        if j in i:
            print(count)
    count+=1