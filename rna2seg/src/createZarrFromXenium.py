import spatialdata as sd
import spatialdata_io as sdio
import optparse
import os

parser = optparse.OptionParser()
parser.add_option('-i', '--input', type = 'string', help = 'input xenium data path')
parser.add_option('-o', '--output', type = 'string', help = 'output zarr data path')

(opts, args) = parser.parse_args()

if opts.input is None:
    parser.error('input xenium data path is required')

if opts.output is None:
    parser.error('output zarr data path is required')

# Check if the output directory lies under the data/ directory
# Use os to avoid string comparison
if not os.path.abspath(opts.output).startswith(os.path.abspath('../data/')):
    parser.error('output zarr data path must lie under the ../data/ directory')

if not os.path.exists(opts.output):
    os.makedirs(opts.output)

print(f"Loading xenium data from {opts.input}", flush = True)
xe_data = sdio.xenium(path = opts.input, cells_as_circles = False)

print(f"Writing zarr data to {opts.output}", flush = True)
xe_data.write(os.path.join(opts.output, 'xenium.zarr'))

print("Done", flush = True)