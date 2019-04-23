"""
Helpher functions to run guitarra.

    convert_str:
        Function converts some input variable to a Fortran-like
        string.

    setup_input_file:
        Function converts input parameters to input file
        that is read by guitarra.

    run_guitarra:
        Main function that runs guitarra.

"""

# --------------
# import modules
# --------------

import os


# --------------
# define functions
# --------------

def convert_str(input_obj):
    """
    Function converts some input variable to a Fortran-like
    string.

    Parameters
    ----------
    input_obj : any type
        This variable is converted to a string that can be
        read by Fotran.

    """
    if isinstance(input_obj, str):
        return(input_obj)
    elif input_obj is True:
        return('1')
    elif (input_obj is None):
        return('none')
    elif input_obj is False:
        return('0')
    else:
        return(str(input_obj))


def setup_input_file(parameter_dictionary):
    """
    Function converts input parameters to two input files
    that are read by guitarra.

    Parameters
    ----------
    parameter_dictionary : dict
        Dictionary that contains all parameters needed to run
        guitarra.

    """
    # parameter file that is conveyed in batch mode
    list_parameters = ['cube_name', 'noise_name', 'ra0', 'dec0', 'sca_id', 'star_catalogue',
                       'galaxy_catalogue', 'filter_in_cat', 'use_filter', 'filter_path', 'psf_num',
                       'psf_path', 'zodifile', 'verbose', 'noiseless', 'brain_dead_test', 'apername',
                       'readpatt', 'ngroups', 'subarray', 'substrt1', 'substrt2',
                       'subsize1', 'subsize2', 'pa_degrees', 'include_ktc', 'include_dark',
                       'include_readnoise', 'include_reference', 'include_non_linear', 'include_latents',
                       'include_1_over_f', 'include_cr', 'cr_mode', 'include_bg', 'include_galaxies',
                       'include_cloned_galaxies', 'primary', 'primary_position', 'primary_total',
                       'subpixel_position', 'subpixel_total']
    file_batch = open(parameter_dictionary['filename_param'], 'w')
    for ii_key in list_parameters:
        if (ii_key == 'noiseless'):
            if parameter_dictionary[ii_key]:
                file_batch.write('.true.\n')
            else:
                file_batch.write('.false.\n')
        elif (ii_key == 'psf_path'):
            file_batch.write(', '.join(parameter_dictionary[ii_key]) + '\n')
        else:
            file_batch.write(convert_str(parameter_dictionary[ii_key]) + '\n')
    file_batch.close()


def run_guitarra(parameter_dictionary):
    """
    Main function that runs guitarra.

    Parameters
    ----------
    parameter_dictionary : dict
        Dictionary that contains all parameters needed to run
        guitarra.

    """
    # setup input files
    setup_input_file(parameter_dictionary)
    # run guitarra
    command = '/Users/sandrotacchella/bin/guitarra < ' + parameter_dictionary['filename_param']
    os.system(command)
