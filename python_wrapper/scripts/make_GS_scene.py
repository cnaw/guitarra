'''
This script collects the input for guipytarra and
also runs it.
'''

# --------------
# import modules
# --------------

import argparse
import os
import numpy as np
import hickle
import guipytarra
import map_sca
from astropy.table import Table

# --------------
# read command line arguments
# --------------


parser = argparse.ArgumentParser()
parser.add_argument("--idx_pointing", type=int, help="number of cores")
args = parser.parse_args()

idx_pointing = args.idx_pointing


# --------------
# read default parameters
# --------------

with open(os.environ['GUITARRA_AUX'] + '../python_wrapper/src/default_params.pkl', 'r') as f:
    run_params = hickle.load(f)


# update param file

run_params['zodifile'] = os.environ['GUITARRA_AUX'] + 'jwst_bkg/goods_s_2019_12_21.txt'


# --------------
# read pointing and source file
# --------------

path_wkdir = '/Users/sandrotacchella/ASTRO/JWST/img_simulator/stuff/test_cluster/'

input_catalog = path_wkdir + 'mock_2018_03_13.cat'

t_source = Table.read(input_catalog, format='ascii')

filters_in_cat = []
for key in t_source.keys():
    if ('F' == key[0]):
        filters_in_cat = np.append(filters_in_cat, key)


t_pointing = Table.read(path_wkdir + '1180_stsci_v5_2018_02_15_deep_guitarra.input', names=('ra', 'dec', 'pa', 'texp', 'naming', 'counter', 'apername', 'ra_hms', 'dec_hms', 'filter', 'readout_pattern', 'ngroups', 'primary', 'subpixel_position', 'subpixel_total'), format='ascii')


# get sca list for given aperture name

sca_list = map_sca.map_sca(t_pointing[idx_pointing]['apername'], t_pointing[idx_pointing]['filter'])


# loop over sca list

for ii_sca in sca_list:
    print ii_sca
    # introduce unique naming
    identifier = t_pointing[idx_pointing]['filter'] + '_' + str(ii_sca) + '_' + str(t_pointing[idx_pointing]['counter'])
    galaxy_catalog = input_catalog.split('.')[0] + '_' + identifier + '.cat'
    # run proselytism to make sub catalog
    file_batch = open(path_wkdir + 'proselytism_' + identifier + '.input', 'w')
    file_batch.write(str(len(filters_in_cat)) + '\n')
    file_batch.write(str(t_pointing[idx_pointing]['ra']) + ' ' + str(t_pointing[idx_pointing]['dec']) + ' ' + str(t_pointing[idx_pointing]['pa']) + '\n')
    file_batch.write(str(ii_sca) + '\n')
    file_batch.write('none\n')
    file_batch.write('none.cat\n')
    file_batch.write(input_catalog + '\n')
    file_batch.write(galaxy_catalog + '\n')
    file_batch.close()
    command = '/Users/sandrotacchella/bin/proselytism < ' + path_wkdir + 'proselytism_' + identifier + '.input'
    os.system(command)
    # update params
    run_params['filename_param'] = path_wkdir + 'params_batch_' + identifier + '.input'
    run_params['cube_name'] = path_wkdir + 'sim_cube_' + identifier + '.fits'
    run_params['ra0'] = t_pointing[idx_pointing]['ra']
    run_params['dec0'] = t_pointing[idx_pointing]['dec']
    run_params['sca_id'] = ii_sca
    run_params['galaxy_catalogue'] = galaxy_catalog
    run_params['filter_in_cat'] = len(filters_in_cat)
    run_params['use_filter'] = np.where(t_pointing[idx_pointing]['filter'] == filters_in_cat)[0][0] + 1  # fortran starts counting at 1 (and not 0 as python)
    run_params['filter_path'] = os.environ['GUITARRA_AUX'] + 'nircam_filters/calib_nircam_' + t_pointing[idx_pointing]['filter'].lower() + '.dat'
    run_params['apername'] = t_pointing[idx_pointing]['apername']
    run_params['readpatt'] = t_pointing[idx_pointing]['readout_pattern']
    run_params['ngroups'] = t_pointing[idx_pointing]['ngroups']
    run_params['pa_degrees'] = t_pointing[idx_pointing]['pa']
    # run guitarra
    guipytarra.run_guitarra(run_params)


'''
# --------------
# set parameters according to pointing index
# --------------

run_params_in = {'filename_param': 'params_batch.input',           # filename of input via batch
                 'cube_name': 'sim_cube_filter_sca_idither.fits',  # output file name
                 'noise_name': None,           # noise map of one over f noise
                 # image RA and DEC information
                 # detector, filter and catalog input
                 'ra0': 53.157129000,          # RA of pointing
                 'dec0': -27.812939000,        # DEC of pointing
                 'sca_id': 481,                # ID of SCA to use  (f.e. 481)
                 'star_catalogue': 'star_cat_filename.cat',        # catalog of stars, see below (f.e. none_487_090.cat)
                 'galaxy_catalogue': 'galaxy_cat_filename.cat',    # catalog of galaxies, see below (f.e. mock_2017_11_03_487_090.cat)
                 'filter_in_cat': 10,          # number of filters contained in source catalogues
                 'use_filter': 5,              # index of filter to use from the list in the source catalogue
                 'filter_path': 'calib_nircam_filter.dat',    # filter file
                 'zodifile': 'bkg_file.txt',   # name of file containing background SED for observation date
                 'verbose': 0,                 # verbose (f.e. 1)
                 'noiseless': False,           # run without adding noise
                 'brain_dead_test': False,     # brain_dead_test (1=yes)
                 # aperture
                 'apername': 'NRCALL_FULL',   # aperture name
                 'readpatt': 'DEEP8',         # read out pattern
                 'ngroups': 7,                # number of groups per ramp  (f.e. 7)
                 'subarray': 'FULL',          # subarray mode (f.e. FULL)
                 'substrt1': 0,               # lower right corner X coordinate (f.e. 0)
                 'substrt2': 0,               # lower right corner Y coordinate (f.e. 0)
                 'subsize1': 2048,            # number of X pixels (f.e. 2048)
                 'subsize2': 2048,            # number of Y pixels (f.e. 2048)
                 'pa_degrees': 26.000,        # Position angle (degrees) of NIRCam short axis, N to E (f.e. 295.0264750)
                 # noise to include
                 'include_ktc': True,         # include ktc
                 'include_dark': True,        # include dark
                 'include_readnoise': True,   # include readnoise
                 'include_reference': True,   # include reference
                 'include_non_linear': True,  # include non-linearity
                 'include_latents': False,    # include latents
                 'include_1_over_f': False,   # include 1/f noise
                 'include_cr': False,         # include cosmic rays
                 'cr_mode': 1,                # cosmic ray mode: (0) ACS; (1) quiet Sun (2); active Sun; (3) flare
                 'include_bg': True,          # include zodiacal background
                 'include_galaxies': True,    # include galaxies
                 'include_cloned_galaxies': False,  # include cloned galaxies
                 # about dither
                 'primary': 'NONE',           # keyword for primary dither type
                 'primary_position': 1,       # keyword for dither
                 'primary_total': 1,          # keyword for dither
                 'subpixel_position': 1,      # keyword for dither
                 'subpixel_total': 9,         # keyword for dither
                 }

'''
