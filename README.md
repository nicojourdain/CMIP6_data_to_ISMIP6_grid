# CMIP6_data_to_ISMIP6_grid

Tools to interpolate and extrapolate CMIP6 ocean data to the ISMIP6 stereographic grid in the PROTECT project.

Tested for: MPI-ESM1-2-HR, IPSL-CM6-LR.

## The scripts and what they do

* **all_files_to_stereo.sh** : 
	- calling **all_files_to_stereo.py** to interpolate CMIP6 data to the ISMIP6 stereographic grid (linear triangular interpolation).

* **extrapolate_ALL.sh** :
	- calling **extrapolate_everywhere_horizontally.f90** to fill missing data via (i) horizontal Gaussian extrapolation (sigma=24km) into ice shelf cavities and into ice shelves from contiguous ocean points (not across bathymetry/bedrock), (ii) horizontal Gaussian extrapolation into the IMBIE2-ISMIP6 basins from contiguous ocean points (not across bathymetry/bedrock), (iii) horizontal Gaussian extrapolation over 40km to account for the diversity of bedrocks used by modelling groups but to avoid extrapolation across ridges and the continental shelf, (iv) horizontal Gaussian extrapolation to entirely fill level 2 (Z=-90m) to enable vertical extrapolation everywhere (level 1 is to much affected by summer surface warming).
	- calling **extrapolate_remaining_vertically.f90** to extrapolate downward from above where there are still missing values (e.g., behind ridges, in the bedrock).

* **extract_yearly_values_and_TF_ALL.sh** :
	- calling **extract_yearly_values_and_TF.f90** to calculate the annual mean salinity, temperature and thermal forcing. Monthly temperatures below the freezing point are set to the freezing temperature before averaging. Two types of thermal forcing are calculated: the mean (TFavg) and the root mean square (TFrms) that better accounts for the effect of the seasonal cycle in quadratic melt formulations.

## How to use

First, run **all_files_to_stereo.sh** for a number of model outputs (starting from the _historical_ period), then run **extrapolate_ALL.sh** for years covering 1995-2014, then calculate the climatology over 1995-2014 using NCO tools (ncks, ncrcat, ncra). Then re-run **extrapolate_ALL.sh** for a number of model outputs. Then run **extract_yearly_values_and_TF_ALL.sh**.

## Main differences with the standard ISMIP6 method

* The bathymetry/bedrock used for the extrapolation of ocean properties is BedMachine-v2 instead of BEDMAP2.

* The ocean extension of the IMBIE2 basins has been extended further offshore for Filchner-Ronne and Amery (using ```modify_IMBIE2_basins.py```):

![New Basins](new_basins.png)
