'''
This script reduces all data from scence in parallel.
'''

# --------------
# import modules
# --------------

import argparse
import os
import numpy as np
from astropy.io import fits
import glob
from shutil import copyfile


# --------------
# read command line arguments
# --------------

parser = argparse.ArgumentParser()
parser.add_argument("--idx_pointing", type=int, help="index for data chunks")
parser.add_argument("--num_cores", type=int, help="number of cores")
parser.add_argument("--path_raw_data", type=str, help="path of data")
parser.add_argument("--path_flat_data", type=str, help="path of flats")
parser.add_argument("--environ", type=str, help="keyword for calibration files")
args = parser.parse_args()

idx_pointing = args.idx_pointing - 1  # translate to python counting (starting frmo 0)
num_cores = args.num_cores
path_to_raw_data = args.path_raw_data
path_to_flat_data = args.path_flat_data
environ = args.environ


# ------------
# define paths
# ------------

if (environ == 'laptop'):
    # Sandro Laptop
    path_calibration_files = '../cal/'
    ncdhas = '/Users/sandrotacchella/ASTRO/JWST/img_simulator/ncdhas-v2.0rev107/ncdhas '
elif (environ == 'cluster'):
    # Cluster
    path_calibration_files = '../guipytarra/data/cal/'
    ncdhas = '/n/eisenstein_lab/Users/stacchella/img_simulator/ncdhas-v2.0rev107/ncdhas '


# --------------
# chunk up data that needs to be reduced
# --------------

text_file = open(path_to_raw_data + "file_list.txt", "r")

list_raw_data = np.array(text_file.read().split('\n'))[:-1]

chunks_raw_data = np.array_split(list_raw_data, num_cores)

file_name_list = chunks_raw_data[idx_pointing]


# ----------------------------------
# define reduction specific features
# ----------------------------------

ncdhas_flags = ' +vb +ow +wi +ws -mr 2048 -zi +cbp +cs +cbs -cd +cl -rhf -rss -ipc -df 0 +cfg isimcv3 '

cfg_config = {}

cfg_config['481'] = path_calibration_files + 'SCAConfig/NRCA1_17004_SW_ISIMCV3.cfg'
cfg_config['482'] = path_calibration_files + 'SCAConfig/NRCA2_17006_SW_ISIMCV3.cfg'
cfg_config['483'] = path_calibration_files + 'SCAConfig/NRCA3_17012_SW_ISIMCV3.cfg'
cfg_config['484'] = path_calibration_files + 'SCAConfig/NRCA4_17048_SW_ISIMCV3.cfg'
cfg_config['485'] = path_calibration_files + 'SCAConfig/NRCA5_17158_LW_ISIMCV3.cfg'
cfg_config['486'] = path_calibration_files + 'SCAConfig/NRCB1_16991_SW_ISIMCV3.cfg'
cfg_config['487'] = path_calibration_files + 'SCAConfig/NRCB2_17005_SW_ISIMCV3.cfg'
cfg_config['488'] = path_calibration_files + 'SCAConfig/NRCB3_17011_SW_ISIMCV3.cfg'
cfg_config['489'] = path_calibration_files + 'SCAConfig/NRCB4_17047_SW_ISIMCV3.cfg'
cfg_config['490'] = path_calibration_files + 'SCAConfig/NRCB5_17161_LW_ISIMCV3.cfg'


# ------------
# run ncdhas, incl. flat-fielding
# ------------

for ii in range(len(file_name_list)):
    print 'progress in %: ', 100.0*ii/len(file_name_list)
    hdu_list = fits.open(file_name_list[ii])
    sca_id = str(hdu_list[0].header['SCA_ID'])
    filter_name = str(hdu_list[0].header['FILTER'])
    command = ncdhas + file_name_list[ii] + ncdhas_flags + '+cp ' + path_calibration_files + ' -P ' + cfg_config[sca_id]
    print 'executing... ', command
    os.system(command)
    # flatfielding
    copyfile(file_name_list[ii][:-5] + '.slp.fits', file_name_list[ii][:-5] + '.slp.flat.fits')
    # read in flats
    flat = fits.open(path_to_flat_data + 'sim_cube_' + filter_name + '_' + sca_id + '_flat.fits')
    # read in image
    with fits.open(file_name_list[ii][:-5] + '.slp.flat.fits', mode='update') as hdul:
            hdul[0].data[0] = hdul[0].data[0]/flat
            hdul.flush()
            hdul.close()







