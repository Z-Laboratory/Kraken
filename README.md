## Kraken

# Overview 
This repository serves as an extension to Idaho National Lab's popular MOOSE simulaiton enviornment. 

Kraken has been developed to allow users to simulate hyperelastic materials and soft robotsusing Finite-Element Analysis (FEA).

# Features

Current Features:
*Neo-Hookean Hyperelastic Material Modeling 
*Transient and Static loading analysis
*Dynamic loading analysis and Damping
*Contact Mechanics and Multibody Interatcion
*Reduced density mesh contact modeling
*Custom Selection of Simulaiton parameters such as preconditioner, solve type, parellelization,ect. 

Work in progress Features:
*Fluid Mechancis and Fluid-Structure Interatction (FSI)
*Uncertainty Quantification (UQ)
*Computational Acceleration via proxy Models

# Installation

1. Install MOOSE according to the directions specified in https://mooseframework.inl.gov/getting_started/installation/
2. Clone this repository into the "moose_projects" directory containing your default MOOSE installation
3. Activate your moose conda enviornment and build your Kraken installation using "make -j" in the "moose_projects/Kraken" directory.
4. You will need to change the location of the default MOOSE directory in the makefile (lines 17-18). 
5. Kraken hyperelastic simulaitons can be run from the "Kraken/problems" directory like any normal MOOSE simulaiton. 
6. Several sample simulaitons have been included for reference.  
