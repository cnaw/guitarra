# Guitarra

Image simulator for the Near Infrared Camera (NIRCam) of the
James Webb Space Telescope.


1. Requirements

gfortran (or some equivalent library; G77/F77 will not work)
CFITSIO library

In fedora:
sudo dnf install cfitsio cfitsio-devel

git clone https://github.com/cnaw/guitarra.git

which will create the  guitarra directory

cd guitarra
make




2. APT Output reading code

Guitarra has been designed to use the output from APT to create simulated
scenes. To allow this it is necessary to download the following perl library:
sudo dnf install  perl-XML-Parser.x86_64 perl-XML-LibXML.x86_64 
(all of these commands work for Fedora 34)

This is needed for file time-stamps:
sudo dnf install perl-Time.noarch


3. Optional Perl code

The following are optional - in case you want to use perl for the parallel
processing and/or ncdhas for the initial data reduction (ramps -> rates)

These perl libraries enable parallel processing where a CPU is assigned to
each simulated SCA:

sudo dnf install perl-Parallel-ForkManager.noarch
sudo dnf install perl-MCE\*

This is required by the wrapper script that reduces data using NCDHAS
(Nircam Data Handling System):

sudo dnf install perl-Astro-FITS-CFITSIO.x86_64


4. Environment variables

Set the following environment variables

export NCDHAS_PATH=/usr/local/nircamsuite/ncdhas
export GUITARRA_HOME=/home/xxx/guitarra/
export GUITARRA_AUX=/home/xxx/guitarra/data/

create the $GUITARRA_HOME and $GUITARRA_AUX directories
mkdir $GUITARRA_HOME
mkdir $GUITARRA_AUX


5. Distortion coefficients

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
   mkdir $GUITARRA_AUX/siaf/PRDOPSSOC-045-003
   and 
   scp -p /home/cnaw/anaconda3/envs/mirage/lib/python3.10/site-packages/pysiaf/prd_data/JWST/PRDOPSSOC-045-003/SIAFXML/Excel/* /home/cnaw/guitarra/siaf/PRDOPSSOC-045-003

4.  cd  $GUITARRA_AUX/siaf/PRDOPSSOC-045-003
    and convert the Excel files into csv using excel or libreoffice by reading them in and
    saving as text csv (Libreoffice)

5.  execute the following script which should use the latest /PRDOPSSOC version in $GUITARRA_HOME/siaf/
    read_siaf_csv.pl
    This will copy the SIAF coefficients to $GUITARRA_AUX in a format that guitarra can read them.


6. Data Reduction

Guitarra data can be reduced using the UofA developed ncdhas
(available at ??) or the STScI JWST pipeline.

If you will be using the ncdhas to reduce data all that is needed is create
a symbolic link from the ./guitarra/data directory to the ndhas calibration
directory, e.g.,
ln -s $NCDHAS/cal  $GUITARRA_AUX/cal

7. STScI JWST Pipeline

Otherwise the STScI JWST pipeline can be used to reduce guitarra data.
The level 1 reductions produced by ncdhas (*rate.fits files)  can be fed
into the JWST pipeline levels 2/3 reduction scripts.

8. Calibration Files

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

9. How to use


a. APT parameters
   i) fire APT and load the latest version of the APT file processed by STScI
      by going to the "File" tab on the upper left corner of APT and click to
      show the menu - select "Retrieve from STScI" ; if the simulation is
      for a submitted proposal just give it the proposal number ("propid") 
  ii) After the proposal is loaded if you want to set the configuration
      for a given date go to the Observations tab and go to the desired
      observation number; click on "Special Requirements" and add or edit
      to set a position angle
 iii) Run the visit planner to make sure there are no issues with the
      programme
  iv) Highlight the entire Observations tab
   v) go to the "File" Tab and go to the Export Menu to generate the inputs
      to Guitarra. These files should be stored in the $GUITARRA_AUX directory:
                   xml file          save as propid.xml
                   visit coverage    save as propid.csv
		   pointings file    save as propid.pointings
  vi) These files are processed by the perl from_apt_to_guitarra.pl script

b. Catalogue preparation
   The input to guitarra consists of an ASCII catalogue with object
   identification, RA, DEC, redshift, Sersic parameters  and a series of
   columns with the magnitudes per filter for each NIRCam filter that
   will be simulated. The first line of the catalogue will contain a header
   (starting with "#") followed by a series of columns with ID RA DEC etc:
   
   \# id ra dec v606_vega zz semi_a  semi_b  theta nsersic F070W F115W F150W F200W F277W F356W F444W F480M
   
          master_0001476 80.4813089543 -69.556572989  20.86490000   0.00000000   0.03100000   0.03100000   0.00000000   0.00100000 20.22491 19.44065 18.94958 18.75473 18.74298 18.69630 18.75067 18.81989


    If you want to simulate stars all that is needed is to set the semi-major
    and semi-minor axes to a small value and nsersic to some value like 0.5.
    These objects will be dominated by the PSF.
    The catalogue MUST be stored in the $GUITARRA_AUX directory

c. Prepare simulation batch 
   With the APT outputs and source catalogue in hand run the script
   $GUITARRA_HOME/perl/from_apt_to_guitarra.pl aptid catalogue_name -b 17 -f 30
   where -b is the bright magnitude limit (if desired) and -f the faint
   magnitude limit (if desired).
   The script will prepare simulation parameters for  all observations where
   NIRCam is prime or is parallel to NIRSpec or  MIRI. Since not all modes
   have been tested there may be cases where the script will break down,
   in which case an issue will need to be opened.
   Once the script completes there will be a file called "batch" on the
   $GUITARRA_HOME directory

d. Running the simulations
   If all is set, the simulations can be run as
   /bin/sh batch
   which will use a single CPU to process the entire set of images
   (for aptid 1180 this is 7440).
   Having more CPUs cranking through the batch can be done using the script 
   $GUITARRA_HOME/perl/paralell.pl batch
   This is currently setup to use a max of 20 CPU, though it can be changed
   to smaller or larger numbers, being limited by the number of CPU
   available on the computer being used. 

e. Reducing data

