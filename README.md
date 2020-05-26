# guitarra
Image simulator for the Near Infrared Camera (NIRCam) of the James Webb Space Telescope.

Requires the CFITSIO library

Calibration files need to be retrieved using this script: 

https://fenrir.as.arizona.edu/cal/guitarra_calib.sh

These files are a subset of the UofA ncdhas calibration files:

https://fenrir.as.arizona.edu/cal/dhas_calib.sh

and if you will be using the ncdhas all that is needed is create a symbolic
link from the ./guitarra/data directory to the ndhas calibration directory, e.g.,
ln -s /usr/local/ncdhas/cal /home/user/guitarra/data/cal

Additional file (PSFs, raw darks) have to be copied over to
the $GUITARRA_AUX diretory using this script:

wget_psf_darks_script.sh
