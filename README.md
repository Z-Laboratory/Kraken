## Kraken

# Overview 
This repository serves as an extension to Idaho National Lab's popular MOOSE simulaiton enviornment. 

Kraken has been developed to allow users to simulate hyperelastic materials using Finite-Element Analysis (FEA).

# Features

Current Features:
Neo-Hookean Hyperelastic Material Modeling 
Transient and Static loading analysis
Custom Selection of Simulaiton parameters such as preconditioner, solve type, parellelization,ect. 

Work in progress Features:
Contact mechanics
Multibody interaction 
Dynamics
Fluid Mechancis

# Installation

1. Install MOOSE according to the directions specified in https://mooseframework.inl.gov/getting_started/installation/
2. Clone this repository into the "moose_projects" directory containing your default MOOSE installation
3. Build your Kraken installation using "make -j" in the "moose_projects/Kraken" directory.
4. You may need to change the location of the default MOOSE directory and conda directories in the makefile depending on your system and installation. 
5. Kraken hyperelastic simulaitons can be run from the "Kraken/problems" directory like any normal MOOSE simulaiton. 
6. Several sample simulaitons have been included for reference.  
