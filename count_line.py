import os

def count_sql_lines(directory):
    total_lines = 0
    file_line_counts = {}

    # Recursively walk through all files and subdirectories
    for root, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith('.sql'):
                file_path = os.path.join(root, filename)
                with open(file_path, 'r', encoding='utf-8') as file:
                    lines = file.readlines()
                    line_count = len(lines)
                    file_line_counts[file_path] = line_count
                    total_lines += line_count
    
    return file_line_counts, total_lines

# Get the current working directory
directory_path = os.getcwd()

# Get line counts for each file and the total
file_line_counts, total_lines = count_sql_lines(directory_path)

# Output the line counts
print("Line counts for each .sql file (including subdirectories):")
for file, line_count in file_line_counts.items():
    print(f"{file}: {line_count} lines")
    
print(f"\nTotal lines across all .sql files: {total_lines}")
