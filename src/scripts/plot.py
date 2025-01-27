import matplotlib.pyplot as plt
import numpy as np

# Function to read data from a file and parse it
def read_computation_times(file_path):
    data = {}
    with open(file_path, 'r') as file:
        lines = file.readlines()
        current_file = None
        
        for line in lines:
            line = line.strip()
            if line.endswith('.inp'):  # Detect new input file name
                current_file = line
                if current_file not in data:
                    data[current_file] = []
            elif line.startswith('Computation:'):
                # Extract the computation time from the line
                time = float(line.split()[1])
                data[current_file].append(time)
    
    for key in data.keys():
        times = data[key]
        seq = 0
        parallel = 0
        for i,time in enumerate(times):
            if i % 2 == 0:
                seq += time
            else:
                parallel += time
        size = len(times) / 2
        data[key] = [seq/ size, parallel / size]
    return data

file_path = "test_output.txt"

# Data
data = read_computation_times(file_path)
for item in data.items():
    print(item)

# Separate the first and second computation times for each input file
input_files = list(data.keys())
first_times = [times[0] for times in data.values()]
second_times = [times[1] for times in data.values()]

# Set up x locations for each group of bars
x = np.arange(len(input_files))

# Width of the bars for each computation time
width = 0.35

# Plotting
plt.figure(figsize=(10, 6))

# Create side-by-side bars for each input file
plt.bar(x - width/2, first_times, width, label='Serial Computation', color='skyblue')
plt.bar(x + width/2, second_times, width, label='Parallel Computation', color='lightcoral')

# Add labels, title, and legend
plt.xlabel('Input Files')
plt.ylabel('Computation Time (seconds)')
plt.title('Comparison of Computation Times for Each Input File')
plt.xticks(x, input_files, rotation=45)
plt.legend()

plt.tight_layout()

# Display the plot
plt.show()
