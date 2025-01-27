import statistics

# Function to read data from a file
def readData(file_path):
    data = []
    with open(file_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            line = line.strip()
            data.append(float(line))
    return data

def getMean(data):
    return sum(data) / len(data)

def getStdDev(data):
    return statistics.stdev(data) 

file = "../result_tests/Sequential/2Dinput6.inp"
data = readData(file)
print("Filename: ", file)
print("Number of iteration: ", len(data))
print("Mean: ", getMean(data))
print("Standard Dev: ", getStdDev(data))