#!/usr/bin/sh
#   Script to copy :
# 1. Lists of files used to identify calibration and raw darks.
#    reside on $GUITARRA_AUX
# 2. PSF fits files (4.1 GB)
#    reside on $GUITARRA_AUX
# 3. Massimo Robberto's CR library (205 Mb)
#    reside on $GUITARRA_AUX
# 4. NIRCam and selection of HST/ACS and HST/WFC3 throughputs (2 Mb)
#    reside on $GUITARRA_AUX
# 5. Calibration files used to provide the detector footprints,
#    which are files used by the ncdhas image reduction code (7GB)
#    reside on $GUITARRA_AUX/cal
# 6. Raw dark ramps for all 10 detectors (173 GB)
#    reside on $GUITARRA_AUX
#
echo " If you will be using NCDHAS for data reduction you should create"
echo " a symbolic link from the \$GUITARRA_AUX/cal subdirectory to "
echo " wherever the NCDHAS calibrations live, e.g.,"
echo " ln -s /usr/local/nircamsuite/cal \$GUITARRA_AUX/cal"
echo " ln -s /usr/local/nircamsuite/cal $GUITARRA_AUX/cal"
echo " ln -s /usr/local/nircamsuite/cal $GUITARRA_AUX/cal"
echo "  "
read -p "****** Press [Enter] to continue or cntr-c to exit"

#
# This should point to the ./guitarra/data/ directory
cd $GUITARRA_AUX ;
#
# Lists of files used in the reduction
# ls 4*.list | gawk '{print("wget https://fenrir.as.arizona.edu/guitarra/"$0)} '
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/481_calib.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/481_dark.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/482_calib.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/482_dark.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/483_calib.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/483_dark.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/484_calib.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/484_dark.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/485_calib.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/485_dark.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/486_calib.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/486_dark.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/487_calib.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/487_dark.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/488_calib.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/488_dark.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/489_calib.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/489_dark.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/490_calib.list
wget https://fenrir.as.arizona.edu/guitarra/calib_lists/490_dark.list
#
#
mkdir WebbPSF_NIRCam_PSFs
cd WebbPSF_NIRCam_PSFs
echo "Copying PSFs"
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F070W_fov_386_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F090W_fov_386_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F115W_fov_508_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F140M_fov_671_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F150W2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F150W_fov_671_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F162M_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F164N_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F182M_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F200W_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F210M_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F212N_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F250M_fov_596_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F277W_fov_595_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F300M_fov_698_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F322W2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F323N_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F335M_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F356W_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F360M_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F405N_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F410M_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F430M_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F444W_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F460M_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F466N_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F470N_fov_1536_os_2.fits
wget https://fenrir.as.arizona.edu/guitarra/WebbPSF_NIRCam_PSFs/PSF_NIRCam_F480M_fov_1536_os_2.fits
cd ..
#
cd $GUITARRA_AUX ;
mkdir cr_robberto
cd cr_robberto
echo "copying cosmic ray library by Massimo Robberto (STScI)"
# ls cr_robberto/*fits | gawk '{print("wget https://fenrir.as.arizona.edu/guitarra"$0)} '
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_00.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_00_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_01.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_01_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_02.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_02_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_03.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_03_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_04.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_04_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_05.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_05_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_06.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_06_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_07.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_07_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_08.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_08_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_09.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_FLARES_09_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_00.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_00_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_01.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_01_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_02.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_02_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_03.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_03_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_04.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_04_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_05.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_05_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_06.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_06_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_07.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_07_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_08.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_08_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_09.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMAX_09_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_00.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_00_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_01.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_01_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_02.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_02_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_03.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_03_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_04.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_04_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_05.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_05_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_06.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_06_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_07.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_07_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_08.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_08_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_09.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD1.7_SUNMIN_09_IPC.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_FLARES_00.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_FLARES_01.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_FLARES_02.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_FLARES_03.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_FLARES_04.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_FLARES_05.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_FLARES_06.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_FLARES_07.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_FLARES_08.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_FLARES_09.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMAX_00.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMAX_01.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMAX_02.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMAX_03.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMAX_04.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMAX_05.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMAX_06.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMAX_07.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMAX_08.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMAX_09.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMIN_00.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMIN_01.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMIN_02.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMIN_03.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMIN_04.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMIN_05.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMIN_06.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMIN_07.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMIN_08.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD2.5_SUNMIN_09.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_FLARES_00.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_FLARES_01.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_FLARES_02.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_FLARES_03.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_FLARES_04.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_FLARES_05.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_FLARES_06.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_FLARES_07.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_FLARES_08.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_FLARES_09.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMAX_00.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMAX_01.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMAX_02.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMAX_03.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMAX_04.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMAX_05.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMAX_06.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMAX_07.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMAX_08.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMAX_09.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMIN_00.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMIN_01.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMIN_02.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMIN_03.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMIN_04.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMIN_05.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMIN_06.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMIN_07.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMIN_08.fits
wget https://fenrir.as.arizona.edu/guitarra/cr_robberto/CRs_MCD5.5_SUNMIN_09.fits
cd ..
#
cd $GUITARRA_AUX ;
mkdir nircam_filters
cd nircam_filters
echo "copying NIRCam filter throughputs"
wget https://fenrir.as.arizona.edu/guitarra/calib_acs_f435w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_acs_f606w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_acs_f775w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_acs_f814w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_acs_f850lp.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_wfc3_f105w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_wfc3_f125w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_wfc3_f140w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_wfc3_f160w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f070w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f090w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f090w_org.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f115w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f140m.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f150w2.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f150w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f162m.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f164n.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f182m.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f187n.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f200w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f210m.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f212n.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f250m.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f277w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f300m.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f322w2.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f323n.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f335m.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f356w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f360m.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f405n.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f410m.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f430m.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f444w.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f460m.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f466n.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f470n.dat
wget https://fenrir.as.arizona.edu/guitarra/calib_nircam_f480m.dat
cd ..
#
mkdir cal
mkdir cal/Bias
cd cal/Bias
echo "Copying Bias"
wget https://fenrir.as.arizona.edu/cal/Bias/NRCA1_17004_Bias_ISIMCV3_2016-02-09.fits
wget https://fenrir.as.arizona.edu/cal/Bias/NRCA2_17006_Bias_ISIMCV3_2016-02-09.fits
wget https://fenrir.as.arizona.edu/cal/Bias/NRCA3_17012_Bias_ISIMCV3_2016-02-09.fits
wget https://fenrir.as.arizona.edu/cal/Bias/NRCA4_17048_Bias_ISIMCV3_2016-02-09.fits
wget https://fenrir.as.arizona.edu/cal/Bias/NRCA5_17158_Bias_ISIMCV3_2016-02-09.fits
wget https://fenrir.as.arizona.edu/cal/Bias/NRCB1_16991_Bias_ISIMCV3_2016-02-09.fits
wget https://fenrir.as.arizona.edu/cal/Bias/NRCB2_17005_Bias_ISIMCV3_2016-02-09.fits
wget https://fenrir.as.arizona.edu/cal/Bias/NRCB3_17011_Bias_ISIMCV3_2016-02-09.fits
wget https://fenrir.as.arizona.edu/cal/Bias/NRCB4_17047_Bias_ISIMCV3_2016-02-09.fits
wget https://fenrir.as.arizona.edu/cal/Bias/NRCB5_17161_Bias_ISIMCV3_2016-02-09.fits
cd ../
mkdir BPM
cd BPM
echo "Copying Bad Pixel Maps"
wget https://fenrir.as.arizona.edu/cal/BPM/NRCA1_17004_BPM_ISIMCV3_2016-01-21.fits
wget https://fenrir.as.arizona.edu/cal/BPM/NRCA2_17006_BPM_ISIMCV3_2016-01-21.fits
wget https://fenrir.as.arizona.edu/cal/BPM/NRCA3_17012_BPM_ISIMCV3_2016-01-21.fits
wget https://fenrir.as.arizona.edu/cal/BPM/NRCA4_17048_BPM_ISIMCV3_2016-01-21.fits
wget https://fenrir.as.arizona.edu/cal/BPM/NRCA5_17158_BPM_ISIMCV3_2016-01-21.fits
wget https://fenrir.as.arizona.edu/cal/BPM/NRCB1_16991_BPM_ISIMCV3_2016-01-21.fits
wget https://fenrir.as.arizona.edu/cal/BPM/NRCB2_17005_BPM_ISIMCV3_2016-01-21.fits
wget https://fenrir.as.arizona.edu/cal/BPM/NRCB3_17011_BPM_ISIMCV3_2016-01-21.fits
wget https://fenrir.as.arizona.edu/cal/BPM/NRCB4_17047_BPM_ISIMCV3_2016-01-21.fits
wget https://fenrir.as.arizona.edu/cal/BPM/NRCB5_17161_BPM_ISIMCV3_2016-01-21.fits
cd ../
mkdir Dark
cd Dark
echo "Copying average darks and sigmas"
wget https://fenrir.as.arizona.edu/cal/Dark/NRCA1_17004_AvgDark_slope_ISIMCV3_2016_07_21_err.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCA1_17004_AvgDark_slope_ISIMCV3_2016_07_21.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCA2_17006_AvgDark_slope_ISIMCV3_2016_07_21_err.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCA2_17006_AvgDark_slope_ISIMCV3_2016_07_21.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCA4_17048_AvgDark_slope_ISIMCV3_2016_07_21_err.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCA4_17048_AvgDark_slope_ISIMCV3_2016_07_21.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCA5_17158_AvgDark_slope_ISIMCV3_2016_07_21_err.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCA5_17158_AvgDark_slope_ISIMCV3_2016_07_21.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCB1_16991_AvgDark_slope_ISIMCV3_2016_07_21_err.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCB1_16991_AvgDark_slope_ISIMCV3_2016_07_21.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCB2_17005_AvgDark_slope_ISIMCV3_2016_07_21_err.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCB2_17005_AvgDark_slope_ISIMCV3_2016_07_21.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCB3_17011_AvgDark_slope_ISIMCV3_2016_07_21_err.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCB3_17011_AvgDark_slope_ISIMCV3_2016_07_21.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCB4_17047_AvgDark_slope_ISIMCV3_2016_07_21_err.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCB4_17047_AvgDark_slope_ISIMCV3_2016_07_21.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCB5_17161_AvgDark_slope_ISIMCV3_2016_07_21_err.fits
wget https://fenrir.as.arizona.edu/cal/Dark/NRCB5_17161_AvgDark_slope_ISIMCV3_2016_07_21.fits
cd ../
mkdir Gain
cd Gain
echo "Copying Gain"
wget https://fenrir.as.arizona.edu/cal/Gain/NRCA1_17004_Gain_ISIMCV3_2016-01-23.fits
wget https://fenrir.as.arizona.edu/cal/Gain/NRCA2_17006_Gain_ISIMCV3_2016-01-23.fits
wget https://fenrir.as.arizona.edu/cal/Gain/NRCA3_17012_Gain_ISIMCV3_2016-01-23.fits
wget https://fenrir.as.arizona.edu/cal/Gain/NRCA4_17048_Gain_ISIMCV3_2016-01-23.fits
wget https://fenrir.as.arizona.edu/cal/Gain/NRCA5_17158_Gain_ISIMCV3_2016-01-23.fits
wget https://fenrir.as.arizona.edu/cal/Gain/NRCB1_16991_Gain_ISIMCV3_2016-01-23.fits
wget https://fenrir.as.arizona.edu/cal/Gain/NRCB2_17005_Gain_ISIMCV3_2016-02-25.fits
wget https://fenrir.as.arizona.edu/cal/Gain/NRCB3_17011_Gain_ISIMCV3_2016-01-23.fits
wget https://fenrir.as.arizona.edu/cal/Gain/NRCB4_17047_Gain_ISIMCV3_2016-02-25.fits
wget https://fenrir.as.arizona.edu/cal/Gain/NRCB5_17161_Gain_ISIMCV3_2016-02-25.fits
cd ../
mkdir Linearity
cd Linearity
echo "Copying Linearity Tables"
wget https://fenrir.as.arizona.edu/cal/Linearity/NRCA1_17004_LinearityCoeff_2016-03-02.fits
wget https://fenrir.as.arizona.edu/cal/Linearity/NRCA2_17006_LinearityCoeff_2016-03-02.fits
wget https://fenrir.as.arizona.edu/cal/Linearity/NRCA3_17012_LinearityCoeff_2016-03-02.fits
wget https://fenrir.as.arizona.edu/cal/Linearity/NRCA4_17048_LinearityCoeff_2016-03-02.fits
wget https://fenrir.as.arizona.edu/cal/Linearity/NRCALONG_17158_LinearityCoeff_2016-03-02.fits
wget https://fenrir.as.arizona.edu/cal/Linearity/NRCB1_16991_LinearityCoeff_2016-02-24.fits
wget https://fenrir.as.arizona.edu/cal/Linearity/NRCB2_17005_LinearityCoeff_2016-02-26.fits
wget https://fenrir.as.arizona.edu/cal/Linearity/NRCB3_17011_LinearityCoeff_2016-02-24.fits
wget https://fenrir.as.arizona.edu/cal/Linearity/NRCB4_17047_LinearityCoeff_2016-02-26.fits
wget https://fenrir.as.arizona.edu/cal/Linearity/NRCBLONG_17161_LinearityCoeff_2016-02-26.fits
cd ../
mkdir WellDepth
cd WellDepth
echo "Copying WellDepths"
wget https://fenrir.as.arizona.edu/cal/WellDepth/NRCA1_17004_WellDepthADU_2016-03-10.fits
wget https://fenrir.as.arizona.edu/cal/WellDepth/NRCA2_17006_WellDepthADU_2016-03-10.fits
wget https://fenrir.as.arizona.edu/cal/WellDepth/NRCA3_17012_WellDepthADU_2016-03-10.fits
wget https://fenrir.as.arizona.edu/cal/WellDepth/NRCA4_17048_WellDepthADU_2016-03-10.fits
wget https://fenrir.as.arizona.edu/cal/WellDepth/NRCA5_17158_WellDepthADU_2016-03-10.fits
wget https://fenrir.as.arizona.edu/cal/WellDepth/NRCB1_16991_WellDepthADU_2016-03-10.fits
wget https://fenrir.as.arizona.edu/cal/WellDepth/NRCB2_17005_WellDepthADU_2016-03-10.fits
wget https://fenrir.as.arizona.edu/cal/WellDepth/NRCB3_17011_WellDepthADU_2016-03-10.fits
wget https://fenrir.as.arizona.edu/cal/WellDepth/NRCB4_17047_WellDepthADU_2016-03-10.fits
wget https://fenrir.as.arizona.edu/cal/WellDepth/NRCB5_17161_WellDepthADU_2016-03-10.fits
cd ../
mkdir SCAConfig
cd SCAConfig
echo "Copying SCA configuration files for ISIMCV3"
wget https://fenrir.as.arizona.edu/cal/SCAConfig/NRCA1_17004_SW_ISIMCV3.cfg
wget https://fenrir.as.arizona.edu/cal/SCAConfig/NRCA2_17006_SW_ISIMCV3.cfg
wget https://fenrir.as.arizona.edu/cal/SCAConfig/NRCA3_17012_SW_ISIMCV3.cfg
wget https://fenrir.as.arizona.edu/cal/SCAConfig/NRCA4_17048_SW_ISIMCV3.cfg
wget https://fenrir.as.arizona.edu/cal/SCAConfig/NRCB1_16991_SW_ISIMCV3.cfg
wget https://fenrir.as.arizona.edu/cal/SCAConfig/NRCB3_17011_SW_ISIMCV3.cfg
wget https://fenrir.as.arizona.edu/cal/SCAConfig/NRCB4_17047_SW_ISIMCV3.cfg
wget https://fenrir.as.arizona.edu/cal/SCAConfig/NRCB5_17161_LW_ISIMCV3.cfg
wget https://fenrir.as.arizona.edu/cal/SCAConfig/NRCB2_17005_SW_ISIMCV3.cfg
wget https://fenrir.as.arizona.edu/cal/SCAConfig/NRCA5_17158_LW_ISIMCV3.cfg
cd ..
#
mkdir IPC
cd IPC
echo "Copying IPC deconvolution Kernels"
wget https://fenrir.as.arizona.edu/cal/IPC/NRCA1_17004_IPCDeconvolutionKernel_2016-03-18.fits
wget https://fenrir.as.arizona.edu/cal/IPC/NRCA2_17006_IPCDeconvolutionKernel_2016-03-18.fits
wget https://fenrir.as.arizona.edu/cal/IPC/NRCA3_17012_IPCDeconvolutionKernel_2016-03-18.fits
wget https://fenrir.as.arizona.edu/cal/IPC/NRCA4_17048_IPCDeconvolutionKernel_2016-03-18.fits
wget https://fenrir.as.arizona.edu/cal/IPC/NRCA5_17158_IPCDeconvolutionKernel_2016-03-18.fits
wget https://fenrir.as.arizona.edu/cal/IPC/NRCB1_16991_IPCDeconvolutionKernel_2016-03-18.fits
wget https://fenrir.as.arizona.edu/cal/IPC/NRCB2_17005_IPCDeconvolutionKernel_2016-03-18.fits
wget https://fenrir.as.arizona.edu/cal/IPC/NRCB3_17011_IPCDeconvolutionKernel_2016-03-18.fits
wget https://fenrir.as.arizona.edu/cal/IPC/NRCB4_17047_IPCDeconvolutionKernel_2016-03-18.fits
wget https://fenrir.as.arizona.edu/cal/IPC/NRCB5_17161_IPCDeconvolutionKernel_2016-03-18.fits
cd ..
#
mkdir Flat
mkdir Flat/ISIMCV3
cd Flat/ISIMCV3
echo "Copying flatfields"
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA1_17004_PFlat_F115W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA1_17004_PFlat_F140M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA1_17004_PFlat_F150W2_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA1_17004_PFlat_F150W2_F162M_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA1_17004_PFlat_F150W2_F164N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA1_17004_PFlat_F150W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA1_17004_PFlat_F182M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA1_17004_PFlat_F187N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA1_17004_PFlat_F200W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA1_17004_PFlat_F210M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA1_17004_PFlat_F212N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA2_17006_PFlat_F115W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA2_17006_PFlat_F140M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA2_17006_PFlat_F150W2_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA2_17006_PFlat_F150W2_F162M_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA2_17006_PFlat_F150W2_F164N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA2_17006_PFlat_F150W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA2_17006_PFlat_F182M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA2_17006_PFlat_F187N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA2_17006_PFlat_F200W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA2_17006_PFlat_F210M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA2_17006_PFlat_F212N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA3_17012_PFlat_F115W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA3_17012_PFlat_F140M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA3_17012_PFlat_F150W2_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA3_17012_PFlat_F150W2_F162M_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA3_17012_PFlat_F150W2_F164N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA3_17012_PFlat_F150W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA3_17012_PFlat_F182M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA3_17012_PFlat_F187N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA3_17012_PFlat_F200W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA3_17012_PFlat_F210M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA3_17012_PFlat_F212N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA4_17048_PFlat_F115W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA4_17048_PFlat_F140M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA4_17048_PFlat_F150W2_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA4_17048_PFlat_F150W2_F162M_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA4_17048_PFlat_F150W2_F164N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA4_17048_PFlat_F150W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA4_17048_PFlat_F182M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA4_17048_PFlat_F187N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA4_17048_PFlat_F200W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA4_17048_PFlat_F210M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA4_17048_PFlat_F212N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F250M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F277W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F300M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F322W2_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F322W2_F323N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F335M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F356W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F360M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F410M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F430M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F444W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F444W_F405N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F444W_F466N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F444W_F470N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F460M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCA5_17158_PFlat_F480M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB1_16991_PFlat_F115W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB1_16991_PFlat_F140M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB1_16991_PFlat_F150W2_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB1_16991_PFlat_F150W2_F162M_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB1_16991_PFlat_F150W2_F164N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB1_16991_PFlat_F150W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB1_16991_PFlat_F182M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB1_16991_PFlat_F187N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB1_16991_PFlat_F200W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB1_16991_PFlat_F210M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB1_16991_PFlat_F212N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB2_17005_PFlat_F115W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB2_17005_PFlat_F140M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB2_17005_PFlat_F150W2_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB2_17005_PFlat_F150W2_F162M_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB2_17005_PFlat_F150W2_F164N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB2_17005_PFlat_F150W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB2_17005_PFlat_F182M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB2_17005_PFlat_F187N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB2_17005_PFlat_F200W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB2_17005_PFlat_F210M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB2_17005_PFlat_F212N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB3_17011_PFlat_F115W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB3_17011_PFlat_F140M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB3_17011_PFlat_F150W2_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB3_17011_PFlat_F150W2_F162M_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB3_17011_PFlat_F150W2_F164N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB3_17011_PFlat_F150W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB3_17011_PFlat_F182M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB3_17011_PFlat_F187N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB3_17011_PFlat_F200W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB3_17011_PFlat_F210M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB3_17011_PFlat_F212N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB4_17047_PFlat_F115W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB4_17047_PFlat_F140M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB4_17047_PFlat_F150W2_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB4_17047_PFlat_F150W2_F162M_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB4_17047_PFlat_F150W2_F164N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB4_17047_PFlat_F150W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB4_17047_PFlat_F182M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB4_17047_PFlat_F187N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB4_17047_PFlat_F200W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB4_17047_PFlat_F210M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB4_17047_PFlat_F212N_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F250M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F277W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F300M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F322W2_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F322W2_F323N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F335M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F356W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F360M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F410M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F430M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F444W_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F444W_F405N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F444W_F466N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F444W_F470N_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F460M_CLEAR_2016-04-05.fits
wget https://fenrir.as.arizona.edu/cal/Flat/ISIMCV3/NRCB5_17161_PFlat_F480M_CLEAR_2016-04-05.fits
cd ../../
#
mkdir dark_ramps
cd dark_ramps
#
mkdir 481
cd 481
echo "Copying dark ramps for SCA 481"
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60011933591_1_481_SE_2016-01-01T20h04m44.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60012216201_1_481_SE_2016-01-02T02h34m28.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60020354361_1_481_SE_2016-01-02T07h09m09.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60072207471_1_481_SE_2016-01-07T22h47m32.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60072315111_1_481_SE_2016-01-08T00h32m07.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60080024141_1_481_SE_2016-01-08T01h23m14.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60080135521_1_481_SE_2016-01-08T02h11m09.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60080247511_1_481_SE_2016-01-08T04h09m24.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60080415241_1_481_SE_2016-01-08T04h48m48.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60080531531_1_481_SE_2016-01-08T06h12m02.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60080652491_1_481_SE_2016-01-08T07h37m29.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60080803361_1_481_SE_2016-01-08T08h35m00.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60080916161_1_481_SE_2016-01-08T10h00m12.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60081328291_1_481_SE_2016-01-08T14h34m50.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60082202011_1_481_SE_2016-01-09T00h03m58.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60090213141_1_481_SE_2016-01-09T02h53m12.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60090604481_1_481_SE_2016-01-09T06h52m47.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60091005411_1_481_SE_2016-01-09T10h56m36.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60091434481_1_481_SE_2016-01-09T15h50m45.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60200714121_1_481_SE_2016-01-20T11h19m06.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60201317151_1_481_SE_2016-01-20T13h42m45.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60201803591_1_481_SE_2016-01-20T19h11m49.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60250918101_1_481_SE_2016-01-25T09h49m07.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60260948151_1_481_SE_2016-01-26T10h20m00.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60261443401_1_481_SE_2016-01-26T16h54m45.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/481/NRCNRCA1-DARK-60271123501_1_481_SE_2016-01-27T13h04m09.fits
cd  ..
#
mkdir 482
cd 482
echo "Copying dark ramps for SCA 482"
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60011904121_1_482_SE_2016-01-01T20h00m15.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60012240481_1_482_SE_2016-01-02T02h34m54.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60020427521_1_482_SE_2016-01-02T07h03m41.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60072231211_1_482_SE_2016-01-07T23h01m34.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60072336521_1_482_SE_2016-01-08T00h33m06.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60080046271_1_482_SE_2016-01-08T01h21m16.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60080158591_1_482_SE_2016-01-08T02h26m30.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60080309181_1_482_SE_2016-01-08T04h09m48.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60080441521_1_482_SE_2016-01-08T05h30m20.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60080600301_1_482_SE_2016-01-08T06h39m51.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60080717291_1_482_SE_2016-01-08T07h48m52.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60080826041_1_482_SE_2016-01-08T09h06m52.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60080937511_1_482_SE_2016-01-08T10h14m14.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60081354481_1_482_SE_2016-01-08T14h47m23.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60082224241_1_482_SE_2016-01-09T00h10m36.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60090235001_1_482_SE_2016-01-09T04h17m03.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60090635511_1_482_SE_2016-01-09T07h05m19.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60091030561_1_482_SE_2016-01-09T11h03m17.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60091457131_1_482_SE_2016-01-09T15h50m45.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60200740231_1_482_SE_2016-01-20T11h19m14.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60201340471_1_482_SE_2016-01-20T14h16m44.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60220551451_1_482_SE_2016-02-04T14h24m21.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60252053581_1_482_SE_2016-01-26T00h47m29.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60260039521_1_482_SE_2016-01-26T01h41m39.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60261013161_1_482_SE_2016-01-26T10h50m25.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60261507111_1_482_SE_2016-01-26T16h54m44.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/482/NRCNRCA2-DARK-60271148511_1_482_SE_2016-01-27T13h04m21.fits
cd ..
#
mkdir 483
cd 483
echo "Copying dark ramps for SCA 483"
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCN826-DARK1-6025093754_1_483_SE_2016-01-25T09h59m01.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCN826-DARK2-6025094803_1_483_SE_2016-01-25T10h38m52.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60011839121_1_483_SE_2016-01-01T20h02m12.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60012303531_1_483_SE_2016-01-02T02h29m44.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60020452431_1_483_SE_2016-01-02T07h03m30.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60081001201_1_483_SE_2016-01-08T10h33m11.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60081429521_1_483_SE_2016-01-08T15h08m27.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60082245481_1_483_SE_2016-01-09T00h04m26.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60090321241_1_483_SE_2016-01-09T04h17m10.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60090656591_1_483_SE_2016-01-09T07h31m27.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60091052561_1_483_SE_2016-01-09T11h28m06.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60091522581_1_483_SE_2016-01-09T16h30m34.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60152117301_1_483_SE_2016-01-15T21h57m55.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60200807481_1_483_SE_2016-01-20T11h18m56.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60201407241_1_483_SE_2016-01-20T14h58m56.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60220806121_1_483_SE_2016-01-22T10h48m53.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60260105181_1_483_SE_2016-01-26T01h42m00.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60261043031_1_483_SE_2016-01-26T11h27m02.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60262147451_1_483_SE_2016-01-26T22h15m08.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/483/NRCNRCA3-DARK-60271212411_1_483_SE_2016-01-27T13h04m31.fits
cd ..
#
mkdir 484
cd 484
echo "Copying dark ramps for SCA 484"
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60011815231_1_484_SE_2016-01-01T19h59m42.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60012343491_1_484_SE_2016-01-02T02h30m09.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60020520401_1_484_SE_2016-01-02T07h09m19.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60072253511_1_484_SE_2016-01-07T23h34m54.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60072358161_1_484_SE_2016-01-08T00h33m15.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60080109421_1_484_SE_2016-01-08T01h42m55.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60080223481_1_484_SE_2016-01-08T02h50m22.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60080351001_1_484_SE_2016-01-08T04h45m16.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60080508231_1_484_SE_2016-01-08T05h53m11.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60080625031_1_484_SE_2016-01-08T07h01m51.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60080740321_1_484_SE_2016-01-08T08h14m02.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60080848561_1_484_SE_2016-01-08T09h18m38.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60081022451_1_484_SE_2016-01-08T10h59m25.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60081451091_1_484_SE_2016-01-08T17h02m44.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60082307391_1_484_SE_2016-01-09T00h04m08.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60090259591_1_484_SE_2016-01-09T04h16m50.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60090720041_1_484_SE_2016-01-09T07h58m26.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60091117441_1_484_SE_2016-01-09T11h52m23.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60091548131_1_484_SE_2016-01-09T16h30m50.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60200832491_1_484_SE_2016-01-20T11h27m40.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60201435291_1_484_SE_2016-01-20T15h12m28.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60221013111_1_484_SE_2016-01-22T11h43m22.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60260640061_1_484_SE_2016-01-26T07h15m05.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60260640061_1_484_SE_2016-01-26T07h21m16.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60260640061_1_484_SE_2016-02-04T16h07m12.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60261111301_1_484_SE_2016-01-26T11h52m27.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60262342141_1_484_SE_2016-01-27T00h03m34.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60262342141_1_484_SE_2016-01-27T00h36m44.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60262342141_1_484_SE_2016-02-04T16h19m12.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/484/NRCNRCA4-DARK-60271236321_1_484_SE_2016-01-27T13h37m49.fits
cd ..
#
mkdir 485
cd 485
echo "Copying dark ramps for SCA 485"
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60011752461_1_485_SE_2016-01-01T19h59m45.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60020011461_1_485_SE_2016-01-02T02h29m40.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60020545311_1_485_SE_2016-01-02T07h09m10.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60081050261_1_485_SE_2016-01-08T11h47m53.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60081524241_1_485_SE_2016-01-08T17h03m29.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60082329041_1_485_SE_2016-01-09T00h04m16.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60090344021_1_485_SE_2016-01-09T04h16m42.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60090746381_1_485_SE_2016-01-09T08h21m48.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60091140151_1_485_SE_2016-01-09T14h23m49.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60091611271_1_485_SE_2016-01-09T17h16m35.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60200857491_1_485_SE_2016-01-20T11h19m16.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60201458561_1_485_SE_2016-01-20T15h29m07.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60221036191_1_485_SE_2016-01-22T11h43m24.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60260722581_1_485_SE_2016-01-26T08h04m32.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60261145131_1_485_SE_2016-01-26T12h12m51.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/485/NRCNRCALONG-DARK-60270008251_1_485_SE_2016-01-27T01h00m17.fits
cd ..
#
mkdir 486
cd 486
echo "Copying dark ramps for SCA 486"
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60011722561_1_486_SE_2016-01-01T20h04m35.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60020132591_1_486_SE_2016-01-02T02h38m41.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60020633531_1_486_SE_2016-01-02T09h07m15.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60081114281_1_486_SE_2016-01-08T11h44m55.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60081549111_1_486_SE_2016-01-08T17h02m49.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60082356471_1_486_SE_2016-01-09T02h47m00.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60090405201_1_486_SE_2016-01-09T05h33m56.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60090807581_1_486_SE_2016-01-09T08h48m11.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60091205311_1_486_SE_2016-01-09T14h30m08.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60091636021_1_486_SE_2016-01-09T17h16m13.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60200924511_1_486_SE_2016-01-20T11h14m25.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60201526011_1_486_SE_2016-01-20T15h56m57.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60250516011_1_486_SE_2016-01-25T07h04m06.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60261213111_1_486_SE_2016-01-26T13h23m34.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/486/NRCNRCB1-DARK-60270034151_1_486_SE_2016-01-27T01h00m18.fits
cd ..
#
mkdir 487
cd 487
echo "Copying dark ramps for SCA 487"
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60011656451_1_487_SE_2016-01-01T17h24m32.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60020101281_1_487_SE_2016-01-02T02h33m32.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60020707291_1_487_SE_2016-01-02T09h06m36.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60081143341_1_487_SE_2016-01-08T14h34m19.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60081613001_1_487_SE_2016-01-08T17h03m19.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60090021181_1_487_SE_2016-01-09T02h51m54.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60090427541_1_487_SE_2016-01-09T05h33m14.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60090830131_1_487_SE_2016-01-09T08h59m50.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60091230011_1_487_SE_2016-01-09T14h23m47.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60091735131_1_487_SE_2016-01-09T18h09m45.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60200949521_1_487_SE_2016-01-20T11h13m55.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60201554521_1_487_SE_2016-01-20T16h45m16.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60250552571_1_487_SE_2016-01-25T07h04m25.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60261238121_1_487_SE_2016-01-26T13h23m44.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/487/NRCNRCB2-DARK-60270104011_1_487_SE_2016-01-27T01h36m20.fits
cd ..
#
mkdir 488
cd 488
echo "Copying dark ramps for SCA 488"
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60011634061_1_488_SE_2016-01-01T17h24m22.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60020156291_1_488_SE_2016-01-02T02h34m53.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60020730151_1_488_SE_2016-01-02T09h07m00.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60081209331_1_488_SE_2016-01-08T14h34m30.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60081636161_1_488_SE_2016-01-08T18h33m14.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60090043151_1_488_SE_2016-01-09T02h53m21.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60090451471_1_488_SE_2016-01-09T05h33m25.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60090852451_1_488_SE_2016-01-09T09h35m03.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60091254111_1_488_SE_2016-01-09T14h23m58.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60091757401_1_488_SE_2016-01-09T18h40m55.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60201014531_1_488_SE_2016-01-20T11h13m55.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60201632341_1_488_SE_2016-01-20T17h01m57.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60250617571_1_488_SE_2016-01-25T07h04m25.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60261303201_1_488_SE_2016-01-26T14h23m05.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/488/NRCNRCB3-DARK-60270127501_1_488_SE_2016-01-27T02h06m09.fits
cd ..
#
mkdir 489
cd 489
echo "Copying dark ramps for SCA 489"
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60011548521_1_489_SE_2016-01-01T17h24m42.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60020234391_1_489_SE_2016-01-02T07h03m09.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60020801231_1_489_SE_2016-01-02T09h06m57.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60081235301_1_489_SE_2016-01-08T14h34m41.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60081728531_1_489_SE_2016-01-08T18h39m41.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60090118261_1_489_SE_2016-01-09T02h46m53.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60090513431_1_489_SE_2016-01-09T05h57m50.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60090914351_1_489_SE_2016-01-09T09h52m02.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60091316411_1_489_SE_2016-01-09T14h23m38.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60091822061_1_489_SE_2016-01-09T18h53m02.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60201044391_1_489_SE_2016-01-20T11h14m16.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60201657541_1_489_SE_2016-01-20T17h41m27.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60250642581_1_489_SE_2016-01-25T07h23m55.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60261328221_1_489_SE_2016-01-26T14h23m04.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/489/NRCNRCB4-DARK-60270202231_1_489_SE_2016-01-27T02h31m07.fits
cd ..
#
mkdir 490
cd 490
echo "Copying dark ramps for SCA 490"
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60011525031_1_490_SE_2016-01-01T17h24m42.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60020302411_1_490_SE_2016-01-02T07h03m03.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60020827071_1_490_SE_2016-01-02T09h11m46.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60081259261_1_490_SE_2016-01-08T14h44m14.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60081800081_1_490_SE_2016-01-08T18h34m21.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60090141241_1_490_SE_2016-01-09T02h46m50.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60090535381_1_490_SE_2016-01-09T06h17m51.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60090939281_1_490_SE_2016-01-09T10h22m25.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60091338491_1_490_SE_2016-01-09T15h46m43.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60101408431_1_490_SE_2016-01-10T15h01m09.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60201110511_1_490_SE_2016-01-20T12h00m15.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60201724291_1_490_SE_2016-01-20T17h57m47.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60251946551_1_490_SE_2016-01-25T20h32m29.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60261354331_1_490_SE_2016-01-26T14h23m24.fits
wget https://fenrir.as.arizona.edu/guitarra/dark_ramps/490/NRCNRCBLONG-DARK-60270226121_1_490_SE_2016-01-27T02h51m47.fits
cd ..
echo "file copying complete!"
