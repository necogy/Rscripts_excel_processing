#!/usr/bin/env Rscript
#
# Arguments parsing
#
args = commandArgs()
print(args)
#
#(input_file  <- strsplit(args[6],split="=",fixed=TRUE))
#(output_file <- strsplit(args[7],split="=",fixed=TRUE))

#
# Load libraries
library(stats4)
library(oro.nifti)
library(MASS)

#
# Load (Delta M) file
DeltaM <- readNIfTI("diffdata_mean.nii", reorient = FALSE)
# Enumerate the z-slices of the input file
Slices <- seq( 0, dim(DeltaM)[3] - 1, 1)

#
# Create the output image
# reset the img
#CBF <- rep( 0., length(CBF) )

#
# Compute Cerebral Blood Flow
K = 100 * 60 * 1000 # Per 100 gram * sec per min * msec per sec
Lambda = 0.90
alpha  = 0.95
TI1    = 700
TI2    = 1800
T1a    = 1684
tau    = 22.5
# Create a sequence acquisition delay after TI2
TI2_delay <- TI2 + tau * Slices
#
CBF <- DeltaM
CBF_data <- CBF@".Data"
for( n in Slices )
    {
        CBF_data[,,n+1]  <- K * DeltaM[,,n+1]  * Lambda * exp(TI2_delay[n+1]/T1a) / (2*alpha*TI1)
    }
CBF@".Data" <- CBF_data

#
# write CBF
Check_range <- ( range(CBF) == c(CBF@"cal_min",CBF@"cal_max") )
if( !Check_range[2] | !Check_range[2] )
    {
        CBF@"cal_min" <- range(CBF)[1]
        CBF@"cal_max" <- range(CBF)[2]
    }
#
writeNIfTI(CBF, "CBF")

