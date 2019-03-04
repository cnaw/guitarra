'''
This script sets the default parameters for guipytarra.
'''

# import modules

import os
import hickle


# set up parameter dictionary

run_params = {'filename_param': 'params_batch.input',           # filename of input via batch
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

# save parameter dictionary

with open(os.environ['GUITARRA_AUX'] + '../python_wrapper/src/default_params.pkl', 'w') as f:
    hickle.dump(run_params, f)


