# CONSTRUCT

CONSTRUCT is a software tool designed to identify functional and structurally important sites in proteins by searching amino acid sites evolving under strong purifying selection that cluster together in 3D structure.

# Prerequisites
- Linux Ubuntu 20.04 LTS (or higher)
- Python 3.10.12 (or higher)
- R 4.1.2 (or higher)
```
sudo apt install r-base-core
sudo apt install python3-pip
sudo apt install git
```


# Installation
To make the program easier to use and install, once you have downloaded all the files from the repository, you will need to run the `install_packages.sh` script. It will check and, if necessary, install the various packages/software the program needs to function correctly.

You can easily download CONSTRUCT and install all dependencies with the following commands:
Via HTTPS link :
```
git clone https://github.com/Rcoppee/CONSTRUCT
```

```
cd CONSTRUCT/
bash install_packages.sh
```

# Usage
Once installed, you can easily run the program with the following command:

```
python CONSTRUCT.py
```
A graphical interface will open (see the figure below), where you only need to fill in the required information and start the execution.

<div align="center">
  <img src="https://i.imgur.com/NZetcyL.png" alt="Description de l'image" width="360" height="auto">
  
</div>

# Outputs
CONSTRUCT generates three result files:

- **spatial_rates.txt**: a file containing the spatially correlated site-specific substitution rates of amino acid sites, ranked by their level of conservation.
- **log_files.txt**: indicates whether a patch of conserved amino acid sites was detected in the protein structure (with the best window size and corresponding correlation strength).
- **color_conserved.pml**: a file highlighting the top 10% of conserved amino acid sites (for use with PyMOL).
# Examples
## KEAP1 

### Analyzing the KEAP1 propeller domain

To analyze the KEAP1 propeller domain, two files must be submitted:

1. **A fasta file**: This file should contain an alignment of orthologous sequences with the reference sequence listed first.
2. **A PDB file**: This file should contain the Cartesian coordinates of the protein structure (in this example we hase used the PDB ID: 2FLU).

<div align="center">
  <img src="https://i.imgur.com/oO1zRb0.png" width="360" height="auto">
</div>

Once you have submitted these files, you can proceed by running the post-processing tool. When the process is complete, you'll see a score representing the strength of the correlation in site-specific substitution rates (a value > 8 indicates the presence of a patch of conserved amino acid sites). In this example, using the side-chain orientation option as Cartesian coordinates, you might observe a log score of 74.63, which is > 8, indicating the presence of a patch of conserved amino acid sites (corresponding to the surface interface with Nrf2, the substrate of KEAP1).

To visualize this patch, you can use PyMOL:

1. Open PyMOL.
2. Go to "File" and select "Open."
3. Load the generated `color_conserved.pml` file.
   
<div align="center">
  <img src="https://i.imgur.com/Ec7KpZ6.png" alt="Description de l'image" width="360" height="auto">
</div>
 


/!\ If you move the PDB file after running CONSTRUCT, you'll have to change the first line of color_conserved.pml, because the first line is: load {pdb_file_path}/my_pdb.pdb (where my_pdb.pdb is your PDB file).
You can also manually open the PDB file in PyMOL then open color_conserved.pml. 

## Domain-specific analysis 
Let’s take DHPS as an example.

<div align="center">
  <img src="https://i.imgur.com/0bPguCR.png" alt="Description de l'image" width="360" height="auto">
</div>

In the initial analysis, no specific boundaries were set, and the following patch was identified:

<div align="center">
  <img src="https://i.imgur.com/qAAQLSg.png" alt="Description de l'image" width="360" height="auto">
</div>

This patch is located on the **DHPS domain** of the protein.

If you want to focus on a specific part of the protein, such as the **PPPK domain**, you can define the boundaries for that domain, which in this case would be from position 1 to 386.

<div align="center">
  <img src="https://i.imgur.com/8ZNqLpv.png" alt="Description de l'image" width="360" height="auto">
</div>


After specifying these boundaries, a patch of conserved amino acid sites was specifically detected in the PPPK domain:

<div align="center">
  <img src="https://i.imgur.com/GTs9EPf.png" alt="Description de l'image" width="360" height="auto">
</div>




# Tutorial
A video tutorial has been created for easy installation and execution of CONSTRUCT: https://www.youtube.com/watch?v=bf-VYReZIeM&t=10s

# Citation
**CONSTRUCT: an algorithmic tool for identifying functional or structurally important regions in protein tertiary structure**

Lucas Chivot, Noé Mathieux, Anna Cosson, Antoine Bridier-Nahmias, Loic Favennec, Jean-Christophe Gelly, Jérôme Clain, Romain Coppée
