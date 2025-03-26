# CONSTRUCT

**CONSTRUCT** is a software tool designed to identify functional and structurally important sites in proteins by detecting amino acid sites evolving under strong purifying selection that cluster together in 3D structure.

---

## ✅ Prerequisites

> 🧪 Tested on macOS 15 (Sequoia, Apple Silicon - M3)

### 🖥️ Operating System
- **macOS** (Apple Silicon — M1/M2/M3)
  - Minimum macOS 11 (Big Sur)
  - Not compatible with Intel Macs at the moment
- **Linux**
  - Ubuntu 20.04 LTS or later (Debian-based systems supported)

### 🔢 Software Requirements
| Tool           | Minimum Version | Recommended | Notes |
|----------------|------------------|-------------|-------|
| **Python**     | 3.7              | 3.10+       | Required for GUI (`customtkinter`) |
| **R**          | 4.1.0            | 4.1.2+      | Ensures CRAN binary compatibility |
| **Homebrew**   | —                | Latest      | Required for macOS dependency handling |

#### Linux quick setup
```bash
sudo apt install r-base-core python3-pip git
```

---

## 📦 What gets installed

All of the following dependencies are installed **automatically** by the script:

### Python
- `customtkinter`

### R
- `tidyverse`
- `readr`
- `dplyr`
- `bio3d`
- `msa` (and its Bioconductor dependencies)

### System tools
- `rate4site` (compiled from source)
- Compilation tools (`gcc`, `make`, etc.)

---

## 🚀 Installation

After downloading the files from the repository, run the installer script. It will verify and install all dependencies.

### Download & Install
```bash
git clone https://github.com/Rcoppee/CONSTRUCT
cd CONSTRUCT/
bash install_packages.sh
```

---

## 🧪 Usage

To launch the program:
```bash
python CONSTRUCT.py
```

A graphical interface will open:

<div align="center">
  <img src="https://i.imgur.com/NZetcyL.png" alt="GUI preview" width="360" height="auto">
</div>

Just fill in the necessary fields and click **"Run post-processing"** to start the analysis.

---


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
