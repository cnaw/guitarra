# guitarra
Image simulator for the Near Infrared Camera (NIRCam) of the James Webb Space Telescope.
Set the following environment variables

export NCDHAS_PATH=/usr/local/nircamsuite/ncdhas
export GUITARRA_HOME=/home/cnaw/guitarra/
export GUITARRA_AUX=/home/cnaw/guitarra/data/

create the $GUITARRA_HOME and $GUITARRA_AUX directories

guitarra requires gfortran, the CFITSIO library

requires the following STScI tools available through the command line:
(this may require some fiddling with the python environment)

jwst-gtvt  https://pypi.org/project/jwst-gtvt/
pip install jwst-gtvt

jwst-backgrounds https://jwst-docs.stsci.edu/jwst-other-tools/backgrounds-tool#BackgroundsTool-Installation
pip install jwst-backgrounds

Finally pysiaf needs to be installed. This provides the coefficients describing the Focal Plane
distortion and are used to convert
(RA,DEC) -> SCA(x,y) -> (RA_inv, DEC_inv) 
Often the pysiaf coeffients can be a few versions behind those used by the scripts above and APT,
so it is always worthwhile checking for updates;
If you are a sudo'er:
updatedb
locate NIRCam_SIAF.xml
and use the latest (as of 2021-09-17):
/home/cnaw/anaconda3/lib/python3.8/site-packages/pysiaf/prd_data/JWST/PRDOPSSOC-039/SIAFXML/Excel/NIRCam_SIAF.xlsx
to convert into csv using libreoffice (or who knows, excel). There is a python script to read excel which merits
some investigation.
export as .csv to $GUITARRA_HOME/distortion/NIRCam_SIAF.csv
mkdir siaf_PRDOPSSOC-039 ; mv NIRCam_SIAF.csv  siaf_PRDOPSSOC-039
cd $GUITARRA_HOME/distortion
execute the following script feeding it the latest PRDOPSSOC version.
read_siaf_csv.pl

This will copy the SIAF coefficients to $GUITARRA_AUX in a way that guitarra can read them.






The following perl libraries are needed to recover data from the APT output:
(these commands work for Fedora 34)
sudo dnf install  perl-XML-Parser.x86_64 perl-XML-LibXML.x86_64 

This perl library enables parallel processing where a simulation for an SCA is assigned to a CPU
sudo dnf install perl-Parallel-ForkManager.noarch
sudo dnf install perl-MCE\*

This is required by the wrapper script that reduces data using NCDHAS
(Nircam Data Handling System)
sudo dnf install perl-Astro-FITS-CFITSIO.x86_64

This is needed for file time-stamps:
sudo dnf install perl-Time.noarch


Guitarra uses a subset of the UofA NCDHAS calibration files. 
If you will be using the ncdhas to reduce data all that is needed is create a symbolic
link from the ./guitarra/data directory to the ndhas calibration directory, e.g.,
ln -s $NCDHAS/cal  $GUITARRA_AUX/cal

Files used in the simulations (calibrations, PSFs, cosmic ray library, filter curves)
can be retrieved using the shell script
wget_calib_aux.sh

You may need to translate wget into curl if you are a mac user:
sed -e s/wget/curl/ < wget_calib_aux.sh > curl_calib_aux.sh

The calibrations take up 181 Gb and the script should copy files to the
appropriate directories. Note that writing to /usr/local/nircamsuite may
require sudo priviledges.

Please note that the calibration files ARE NOT IDENTICAL to STScI MIRAGE calibrations.
The UofA pipeline uses "detector" coordinates which are directly read out from the detectors.
The STScI "raw" data have already been converted into "science" coordinates, which are
are rotated and/or flipped relative to the detector data, so not really raw.

Guitarra has been designed to use the output from APT to create simulated scenes.
As an example, fire APT and load some proposal number from STScI. For example
load one of the commissioning tasks (1073) which checks dither patterns at the
South Ecliptic Pole (PI: Koekemoer)
Once the proposal is loaded you will need to export the files which will be input to
guitarra. To do this highlight the observations button and  go to 
file-> export 
export:
a) xml file  (save as 1073.xml)
b) visit coverage (save as 1073.csv) note: DO NOT use option "visit Positions/Coverage to MAST"
c) pointings (save as 1073.pointings)

copy these files to the $GUITARRA_AUX directory

go to $GUITARRA_HOME
make
(if all works out then)

./perl/from_apt_to_guitarra.pl 1073 catalogue_name -d 1 -bright 19.0 -faint 20 -date 2022-09-10

where 2022-09-10 will be the date of observation.
If all works out (never happens on the first try) the background plots should pop up
(the current version of the python code wants to make sure you see the plots);
press q (which will happen quite a few times) until it is done.

When a miracle happens and the script ends without crashing there will be a file called "batch"
on $GUITARRA_HOME. This contains the command that converts the (RA, DEC) -> SCA(x,y) ("proselytism"),
followed by the guitarra command and finally the script that will reduce data using the ncdhas.




