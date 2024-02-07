import re
import sys
import glob
from collections import defaultdict

def process_lines(lines):
    shard_pattern = re.compile(r'^--- SHARD #(\d+) ---$')
    window_pattern = re.compile(r'\[Window (\d+):')
    file_pattern = re.compile(r'{ ([a-z]{2}-\d+-big-Scylla\.db):', re.IGNORECASE)
    shards = defaultdict(lambda: [])
    current_shard = None
    current_window = None
    current_files = []

    for line in lines:
        shard_match = shard_pattern.match(line)
        if shard_match:
            if current_shard is not None and current_window is not None:
                shards[current_shard].append((current_window, current_files))
            current_shard = int(shard_match.group(1))
            current_window = None
            current_files = []
            continue

        window_match = window_pattern.search(line)
        if window_match:
            if current_window is not None:
                shards[current_shard].append((current_window, current_files))
            current_window = int(window_match.group(1))
            current_files = []
            continue

        file_match = file_pattern.search(line)
        if file_match:
            current_files.append(file_match.group(1))

    if current_shard is not None and current_window is not None:
        shards[current_shard].append((current_window, current_files))

    return shards

if __name__ == "__main__":
    if not sys.stdin.isatty():
        input_source = sys.stdin.readlines()
    else:
        print("Error: This script expects piped input.")
        sys.exit(1)

    shards = process_lines(input_source)

    schema_name = "keyspace1"
    table_name = "standard1"
    pattern = f"/var/lib/scylla/data/{schema_name}/{table_name}-*"
    matching_dirs = glob.glob(pattern)

    if matching_dirs:
        directory = matching_dirs[0].split('/')[-1]

        for shard, windows in shards.items():
            for window, files in sorted(windows, key=lambda x: x[0])[:2]:
                for file in files:
                    header = '-'.join(file.split('-')[:2])
                    file_pattern = f"/var/lib/scylla/data/{schema_name}/{directory}/{header}-*"
                    matching_files = glob.glob(file_pattern)
                    for matching_file in matching_files:
                        print(matching_file)
    else:
        print("No matching directories found.")

