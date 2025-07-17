import os

folder1 = "Solidity"
folder2 = "smartbugs/Solidity"

# Get all filenames (excluding subfolders)
files1 = set(f for f in os.listdir(folder1) if os.path.isfile(os.path.join(folder1, f)))
files2 = set(f for f in os.listdir(folder2) if os.path.isfile(os.path.join(folder2, f)))

all_files = files1 | files2

same = []
different = []
missing_in_folder1 = []
missing_in_folder2 = []

for filename in sorted(all_files):
    path1 = os.path.join(folder1, filename)
    path2 = os.path.join(folder2, filename)

    if filename not in files1:
        missing_in_folder1.append(filename)
        continue
    if filename not in files2:
        missing_in_folder2.append(filename)
        continue

    # Read both files and compare content
    try:
        with open(path1, 'r', encoding='utf-8') as f1, open(path2, 'r', encoding='utf-8') as f2:
            content1 = f1.read().strip()
            content2 = f2.read().strip()

        if content1 == content2:
            same.append(filename)
        else:
            different.append(filename)

    except Exception as e:
        print(f"Error comparing {filename}: {e}")

# Summary Report
print(f"\n✅ Same content: {len(same)} files")
print(f"❌ Different content: {len(different)} files")
print(f"⚠️ Missing in '{folder1}': {len(missing_in_folder1)} files")
print(f"⚠️ Missing in '{folder2}': {len(missing_in_folder2)} files")

if different:
    print("\nFiles with different content:")
    for f in different:
        print("  ", f)

if missing_in_folder1:
    print(f"\nFiles missing in {folder1}:")
    for f in missing_in_folder1:
        print("  ", f)

if missing_in_folder2:
    print(f"\nFiles missing in {folder2}:")
    for f in missing_in_folder2:
        print("  ", f)

if not different and not missing_in_folder1 and not missing_in_folder2:
    print("\n🎉 All files match perfectly in name and content!")
