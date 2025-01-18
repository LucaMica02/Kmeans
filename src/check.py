# open seq result for reading
with open('seq_result.txt', 'r') as seq_file:
    content1 = seq_file.read()

# open parallel result for reading
with open('result.txt', 'r') as file:
    content2 = file.read()

# check if the results are equals
if content1 == content2:
    print("### CHECK PASSED ###")
else:
    print("### CHECK FAILED ###")