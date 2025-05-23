#!/bin/bash

# Define base parameters
XENIUM_PATH="/diskmnt/primary/Xenium/data/20240821__204457__20240821_SenNet_bone/output-XETG00122__0033739__SN151R1-Ma1Fd2-2U1__20240821__204528"
BASE_OUTPUT="/diskmnt/Projects/SenNet_analysis/Main.analysis/bm/Xenium/Baysor_test"
QV_THRESHOLD=20
SNV_PATTERN="_WT\|_ALT"

# Define parameter ranges for sweep
MIN_MOLECULES_RANGE=(5 10)
CELL_SIZE_RANGE=(5 10)
PRIOR_CONF_RANGE=(0.85 0.9 0.95)

# Create output directories
SWEEP_DIR="${BASE_OUTPUT}/parameter_sweep"
mkdir -p ${SWEEP_DIR}

# Run BaysorFormatXenium.py once
echo "Running BaysorFormatXenium.py..."
conda run -n ficture python /diskmnt/Projects/SenNet_analysis/Main.analysis/bm/Xenium/src/WC/BaysorFormatXenium.py \
    -i ${XENIUM_PATH} -o ${BASE_OUTPUT} --qv_threshold ${QV_THRESHOLD} --SNV_pattern ${SNV_PATTERN}

# Function to run single Baysor analysis
export SWEEP_DIR
export BASE_OUTPUT
export QV_THRESHOLD
run_single() {
    local min_mol=$1
    local cell_size=$2
    local prior_conf=$3
    
    # Create specific output directory
    local out_dir="${SWEEP_DIR}/mol${min_mol}_size${cell_size}_conf${prior_conf}"
    echo ${out_dir}
    mkdir -p ${out_dir}
    
    echo "Running Baysor with parameters: min_mol=${min_mol}, cell_size=${cell_size}, prior_conf=${prior_conf}"
    
    # Run Baysor directly
    /diskmnt/Projects/Users/chouw/Software/baysor/bin/baysor/bin/baysor run \
        -x x_location -y y_location -z z_location -g feature_name \
        -m ${min_mol} -o "${out_dir}/baysor_segmentation.csv" -s ${cell_size} --scale-std 0.8 --n-clusters 15 \
        --polygon-format GeometryCollectionLegacy --prior-segmentation-confidence ${prior_conf} \
        "${BASE_OUTPUT}/transcripts_filtered_qv${QV_THRESHOLD}_ROIsubset.csv" :cell_id > "${out_dir}/run.log" 2>&1

}

export -f run_single

# Run parameter sweep in parallel
echo "Starting parameter sweep..."
parallel --jobs 4 run_single ::: "${MIN_MOLECULES_RANGE[@]}" ::: "${CELL_SIZE_RANGE[@]}" ::: "${PRIOR_CONF_RANGE[@]}"

echo "Parameter sweep complete. Results in ${SWEEP_DIR}"