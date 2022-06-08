# Guitarra
===========
Image simulator for the Near Infrared Camera (NIRCam) of the
James Webb Space Telescope.


Requirements
============
gfortran (or some equivalent library; G77/F77 will not work)
CFITSIO library

In fedora:
sudo dnf install cfitsio cfitsio-devel

git clone https://github.com/cnaw/guitarra.git

cd guitarra
make



APT Output reading code
========================
Guitarra has been designed to use the output from APT to create simulated
scenes. To allow this it is necessary to download the following perl library:
sudo dnf install  perl-XML-Parser.x86_64 perl-XML-LibXML.x86_64 
(all of these commands work for Fedora 34)

This is needed for file time-stamps:
sudo dnf install perl-Time.noarch


Optional Perl code
==================
The following are optional - in case you want to use perl for the parallel
processing and/or ncdhas for the initial data reduction (ramps -> rates)

These perl libraries enable parallel processing where a CPU is assigned to
each simulated SCA:

sudo dnf install perl-Parallel-ForkManager.noarch
sudo dnf install perl-MCE\*

This is required by the wrapper script that reduces data using NCDHAS
(Nircam Data Handling System):

sudo dnf install perl-Astro-FITS-CFITSIO.x86_64


Environment variables
=====================
Set the following environment variables

export NCDHAS_PATH=/usr/local/nircamsuite/ncdhas
export GUITARRA_HOME=/home/xxx/guitarra/
export GUITARRA_AUX=/home/xxx/guitarra/data/

create the $GUITARRA_HOME and $GUITARRA_AUX directories
mkdir $GUITARRA_HOME
mkdir $GUITARRA_AUX


Distortion coefficients
=======================
These provide the coefficients that transform
(RA, DEC) <-> pixels 
and require having pysiaf being installed and up to date.

Note that frequently even the latest pysiaf coefficients can be
a few versions behind those used by APT.

procedure:
1. pip install update pysiaf

2. If you are a sudo'er:
   updatedb
   locate NIRCam_SIAF.xml
   and use the latest version of PRDOPSSOC.
   As of 2022-06-07 this was:
/home/cnaw/anaconda3/envs/mirage/lib/python3.10/site-packages/pysiaf/prd_data/JWST/PRDOPSSOC-045-003/SIAFXML/Excel/NIRCam_SIAF.xlsx

3. create a directory using the latest PRDOPSSOC number:
   mkdir $GUITARRA_HOME/siaf/PRDOPSSOC-045-003
   and 
   scp -p /home/cnaw/anaconda3/envs/mirage/lib/python3.10/site-packages/pysiaf/prd_data/JWST/PRDOPSSOC-045-003/SIAFXML/Excel/* /home/cnaw/guitarra/siaf/PRDOPSSOC-045-003

4.  cd  $GUITARRA_HOME/siaf/PRDOPSSOC-045-003
    and convert the Excel files into csv using excel or libreoffice by reading them in and
    saving as text csv (Libreoffice)

5.  execute the following script which should use the latest /PRDOPSSOC version in $GUITARRA_HOME/siaf/
    read_siaf_csv.pl
    This will copy the SIAF coefficients to $GUITARRA_AUX in a format that guitarra can read them.


Data Reduction
==============
Guitarra data can be reduced using the UofA developed ncdhas
(available at ??) or the STScI JWST pipeline.

If you will be using the ncdhas to reduce data all that is needed is create
a symbolic link from the ./guitarra/data directory to the ndhas calibration
directory, e.g.,
ln -s $NCDHAS/cal  $GUITARRA_AUX/cal



STScI JWST Pipeline
===================
Otherwise the STScI JWST pipeline can be used to reduce guitarra data.
The level 1 reductions produced by ncdhas (*rate.fits files)  can be fed
into the JWST pipeline level 2/3 reduction scripts.

Calibration Files
=================
Guitarra uses a subset of the UofA NCDHAS calibration files. As of 2022-06-07
only the ground-based engineering data are available for use. All Flight
imaging data (including calibrations) are under embargo until 2022-07-13.

Files used in the simulations (calibrations, PSFs, cosmic ray library,
filter curves) can be retrieved using the shell script

wget_calib_aux.sh

You may need to translate wget into curl if you are a mac user:
sed -e s/wget/curl/ < wget_calib_aux.sh > curl_calib_aux.sh

The calibrations take up 181 Gb and the script should copy files to the
appropriate directories. Note that writing to /usr/local/nircamsuite may
require sudo privileges.

Please note that the calibration files ARE NOT IDENTICAL to STScI MIRAGE
calibrations, though the eventually they may be the same (packaging differs).

