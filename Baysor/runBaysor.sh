#!/bin/bash

# Define parameters
XENIUM_PATH="/diskmnt/primary/Xenium/data/20240821__204457__20240821_SenNet_bone/output-XETG00122__0033739__SN151R1-Ma1Fd2-2U1__20240821__204528/"
OUTPUT_PATH="/diskmnt/Projects/SenNet_analysis/Main.analysis/bm/Xenium/Baysor_test/SN151/"
SAMPLE_ID="SN151R1"

# BaysorFormatXenium parameters
QV_THRESHOLD=20
SNV_PATTERN="_WT\|_ALT\|NegCon\|BLANK"  # Example pattern

# Baysor parameters
MIN_MOLECULES=10
CELL_SIZE=5
N_CLUSTERS=15
PRIOR_SEGMENTATION_CONFIDENCE=0.8

cd ${OUTPUT_PATH}

# Run BaysorFormatXenium.py
echo "Running BaysorFormatXenium.py..."
conda run -n ficture python /diskmnt/Projects/SenNet_analysis/Main.analysis/bm/Xenium/src/WC/BaysorFormatXenium.py \
    -i ${XENIUM_PATH} -o ${OUTPUT_PATH} --qv_threshold ${QV_THRESHOLD} --SNV_pattern ${SNV_PATTERN}

# Run Baysor
/diskmnt/Projects/Users/chouw/Software/baysor/bin/baysor/bin/baysor run \
    -x x_location -y y_location -z z_location -g feature_name \
    -m ${MIN_MOLECULES} -o baysor_segmentation.csv -s ${CELL_SIZE} --scale-std 50% --n-clusters ${N_CLUSTERS} \
    --polygon-format GeometryCollectionLegacy --prior-segmentation-confidence ${PRIOR_SEGMENTATION_CONFIDENCE} \
    --plot transcripts_filtered_qv${QV_THRESHOLD}.csv :cell_id

# Run Xeniumranger to re-assign transcripts to cells
/diskmnt/Projects/Users/chouw/Software/xeniumranger-xenium3.1/xeniumranger import-segmentation \
    --xenium-bundle ${XENIUM_PATH} \
    --id ${SAMPLE_ID}_baysor_resegment_m${MIN_MOLECULES}_s${CELL_SIZE}_pc${PRIOR_SEGMENTATION_CONFIDENCE} \
    --viz-polygons baysor_segmentation_polygons_2d.json \
    --transcript-assignment baysor_segmentation.csv \
    --localmem 256