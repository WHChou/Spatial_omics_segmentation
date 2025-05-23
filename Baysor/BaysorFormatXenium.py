# This script converts Xenium transcript output to Baysor input format
# It filters out transcripts with QV below a threshold and SNV transcripts
# It takes the following inputs:
# input_folder: Path to input folder
# output_folder: Path to output folder
# qv_threshold: QV threshold
# SNV_pattern: SNV pattern

import argparse
import numpy as np
import pandas as pd

parser = argparse.ArgumentParser(description='Convert Xenium format to Baysor format')
parser.add_argument('-i', '--input_folder', type=str, help='Path to input folder')
parser.add_argument('-o', '--output_folder', type=str, help='Path to output folder')
parser.add_argument('--qv_threshold', type=int, help='QV threshold')
parser.add_argument('--SNV_pattern', type=str, help='SNV pattern')
args = parser.parse_args()

# Read transcript.csv.gz
transcript = pd.read_csv(f'{args.input_folder}/transcripts.csv.gz')

# Keep only qv>=qv_threshold
transcript_filtered = transcript[transcript['qv'] >= args.qv_threshold]

# Filter out SNV transcripts (feature name contains SNV_pattern)
transcript_filtered = transcript_filtered[
    ~transcript_filtered['feature_name'].str.contains(args.SNV_pattern)
]

# Change unique cell_ids to integers and UNASSIGNED to 0
# Create mapping dictionary with enumerate
cell_id_map = {cell_id: idx for idx, cell_id in enumerate(transcript_filtered['cell_id'].unique())}
cell_id_map['UNASSIGNED'] = 0  # Ensure UNASSIGNED maps to 0

# Apply mapping to all cell_ids at once
transcript_filtered['cell_id'] = transcript_filtered['cell_id'].map(cell_id_map)

# Write to filtered transcript file
output_path = f'{args.output_folder}/transcripts_filtered_qv{args.qv_threshold}.csv'
transcript_filtered.to_csv(output_path, index=False)

# For small tests, output a subset of transcripts within specified region
mask = (
    (transcript_filtered['x_location'] >= 2000)
    & (transcript_filtered['x_location'] <= 3000)
    & (transcript_filtered['y_location'] >= 3500)
    & (transcript_filtered['y_location'] <= 4500)
)
transcript_filtered_subset = transcript_filtered[mask]
subset_path = (
    f'{args.output_folder}/transcripts_filtered_qv{args.qv_threshold}'
    '_ROIsubset.csv'
)
transcript_filtered_subset.to_csv(subset_path, index=False)

print("Xenium output has been formatted to Baysor format!")