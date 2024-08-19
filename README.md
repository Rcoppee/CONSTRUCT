# CONSTRUCT

CONSTRUCT is a software tool designed to identify functional and structurally important sites in proteins by analyzing PDB files and sequence alignments, focusing on conserved amino acids across orthologous sequences from different species. It facilitates the detection of spatially conserved amino acid patches in 3D protein structures to study evolutionary conservation and protein function.

# Prerequisites
- Linux Ubuntu 20.04 LTS (or higher)
- Python 3.10.12 (or higher)
- R 4.1.2 (or higher)

# Installation
To make the program easier to use and install, once you have downloaded all the files from the repository, you will need to run the `install_packages.sh` script. It will check and install, if necessary, the various packages/software the program needs to function correctly.

You can easily download Construct and install all dependencies with the following commands:
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
A graphical interface will open (see the image below), where you will only need to fill in the requested information and start the execution.

<div align="center">
  <img src="https://i.imgur.com/BhO6hyI.png" alt="Description de l'image" width="360" height="auto">
</div>

# Outputs
Construct will generate three results files:

- **spatial_rates.txt**: a file containing the spatial substitution rates of amino acids, ranked by their order.
- **log_files.txt**: indicates whether a patch is present or not.
- **color_conserved.pml**: a file that highlights the top 10% of conserved amino acids (for use with PyMOL).
# Examples
## Keap1 

### Analyzing Keap1 Protein with Conservation Patches

To analyze the Keap1 protein, you'll need two essential files:

1. **A FASTA File**: This file should contain all orthologous sequences aligned, with the reference sequence listed first.
2. **PDB Files**: These files should be downloaded from the Protein Data Bank for the structure of Keap1.

<div align="center">
  <img src="https://i.imgur.com/cGATiCe.png" width="360" height="auto">
</div>

Once you have these files, you can proceed by running the post-processing tool. After the process completes, you'll see a score representing the conservation patch, which indicates regions of the protein that are highly conserved across species. For example, you might observe a log score of 248.44, which highlights the significance of the patch detected.

To visualize this patch, you can use PyMOL:

1. Open PyMOL.
2. Go to "File" and select "Open."
3. Load the `color_conserved.pml` file that was generated.
   
<div align="center">
  <img src="https://i.imgur.com/Ec7KpZ6.png" alt="Description de l'image" width="360" height="auto">
</div>
 


/!\ If you move the pdb files after running Construct, you'll have to change the first line of color_conserved.pml since the first line look line this : load {pdb_file_path}/XXXX.pdb
You can also open manually the pdb in pymol, then open color_conserved. 

## Domain-Specific Analysis 
Let’s take DHPS as an example.

<div align="center">
  <img src="https://i.imgur.com/9YJpB4F.png" alt="Description de l'image" width="360" height="auto">
</div>

In the initial analysis, no specific boundaries were set, and the following patch was identified:

<div align="center">
  <img src="https://i.imgur.com/qAAQLSg.png" alt="Description de l'image" width="360" height="auto">
</div>

This patch is located on the **PPPK domain** of the protein.

If you want to focus on a specific part of the protein, such as the **DHPS domain**, you can define the boundaries for that domain, which in this case would be from positions 1 to 476.

<div align="center">
  <img src="https://i.imgur.com/KMQP8Dj.png" alt="Description de l'image" width="360" height="auto">
</div>


After specifying these boundaries, the resulting patch looks like this:

<div align="center">
  <img src="https://i.imgur.com/GTs9EPf.png" alt="Description de l'image" width="360" height="auto">
</div>




# Tutorial
A video tutorial has been created for easy installation and execution of Construct:  **LIEN VIDEO**

# Citation
**CONSTRUCT: an algorithmic tool for identifying functional or structurally important regions in protein tertiary structure**

Lucas Chivot, Antoine Bridier-Nahmias, Jérôme Clain, Romain Coppée
