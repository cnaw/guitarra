
# import modules

import numpy as np


# define lists of short and long wavelength filters

sw_filer_list = np.array(['F070W', 'F090W', 'F115W', 'F140M', 'F150W', 'F162M', 'F164N', 'F182M', 'F187N', 'F200W', 'F210M', 'F212N'])
lw_filer_list = np.array(['F250M', 'F277W', 'F300M', 'F323N', 'F335M', 'F356W', 'F360M', 'F405N', 'F410M', 'F430M', 'F444W', 'F460M', 'F466N', 'F470N', 'F480M'])


# define function

def map_sca(apername, filter_in):
    '''
    This function maps the aperture name and filter
    to sca number list.
    '''
    if filter_in in sw_filer_list:
        sca_list = np.array([481, 482, 483, 484, 486, 487, 488, 489])
    elif filter_in in lw_filer_list:
        sca_list = np.array([485, 490])
    if(apername == 'NRCALL_FULL'):
        sca = np.array([485, 490, 481, 482, 483, 484, 486, 487, 488, 489])
    elif(apername == 'NRCAALL'):
        sca = np.array([481, 482, 483, 484, 485])
    elif(apername == 'ASHORT'):
        sca = np.array([481, 482, 483, 484])
    elif(apername == 'ALONG'):
        sca = np.array([485])
    elif(apername == 'NRCBALL'):
        sca = np.array([486, 487, 488, 489, 490])
    elif(apername == 'BSHORT'):
        sca = np.array([486, 487, 488, 489])
    elif(apername == 'BLONG'):
        sca = np.array([490])
    sca_return = []
    for ii_sca in sca:
        if ii_sca in sca_list:
            sca_return = np.append(sca_return, ii_sca)
    return(sca_return.astype('int'))





