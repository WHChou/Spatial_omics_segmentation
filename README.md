This folder contains working scripts to test and run various spatial omics segmentation packages.

# RNA2seg
 RNA2seg is a deep learning-based segmentation tool that takes into account tissue staining and transcript localation. To run the tool, first create a Zarr store from the Xenium output using `rna2seg/src/createZarrFromXenium.py`. This will create a `rna2seg/data/` folder where you can run the subsequent analysis using `rna2seg/src/rna2seg.ipynb`. Datasets will not be uploaded due to size constraints. 

 The paper for this tool is [here](https://www.biorxiv.org/content/10.1101/2025.03.03.641259v3). The github repository of this tool is [here](https://github.com/fish-quant/rna2seg).
