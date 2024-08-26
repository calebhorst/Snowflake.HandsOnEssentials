import os
import subprocess

# Adjust the root directory to the parent directory
root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '.'))

# Set SQL dialect for Snowflake
sqlfluff_command = ['sqlfluff', 'fix', '--dialect', 'snowflake']

# Loop through all directories and subdirectories
for subdir, _, files in os.walk(root_dir):
    for file in files:
        # Check if the file ends with '.sql'
        if file.endswith('.sql'):
            # Get the full file path
            file_path = os.path.join(subdir, file)
            print(f'Linting file: {file_path}')
            
            # Run sqlfluff lint on the file
            try:
                subprocess.run(sqlfluff_command + [file_path], check=True)
            except subprocess.CalledProcessError as e:
                print(f'Error linting {file_path}: {e}')
                # Handle or log the error as needed, e.g., by continuing

print('Finished linting all .sql files.')
