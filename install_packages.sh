
#!/bin/bash

read -p "In order to use this automated analysis pipeline, several (python and R) software packages are required. The purpose of this script is to facilitate the use of the pipeline by automatically installing packages/software. Would you like to proceed with this installation? (Y/n) " choix_installation

if [ "$choix_installation" != "Y" ]; then 
    echo "You have chosen not to install packages."
    exit 1
else
    # Vérification et installation de rate4site
    if echo "0" | rate4site -h &> /dev/null; then
        echo "rate4site is already installed."
    else
        echo "rate4site is not installed."
        echo "Installing..."
        sudo apt update
        sudo apt install rate4site
        echo "rate4site is installed."
    fi
 
    # Vérification et installation des packages Python
    if python3 -c "import tkinter" &> /dev/null; then
        echo "tkinter is already installed."
    else
        echo "tkinter is not installed."
        echo "Installation in progress..."
        sudo apt update
        sudo apt install python3-tk
        echo "tkinter is installed."
    fi

    if python3 -c "import customtkinter" &> /dev/null; then
        echo "customtkinter is already installed."
    else
        echo "customtkinter is not installed."
        echo "Installation in progress..."
        pip3 install customtkinter
        echo "customtkinter is installed."
    fi

    # Vérification et installation des packages R
    if Rscript -e "if (!requireNamespace('tidyverse', quietly = TRUE)) {quit(status = 1)}" &> /dev/null; then
        echo "tidyverse is already installed."
    else
        echo "tidyverse is not installed."
        echo "Installation in progress..."
        sudo Rscript -e 'install.packages("tidyverse", repos="http://cran.rstudio.com/")'
        echo "tidyverse is installed."
    fi

    if Rscript -e "if (!requireNamespace('BiocManager', quietly = TRUE)) {quit(status = 1)}" &> /dev/null; then
        echo "BiocManager is already installed."
    else
        echo "BiocManager is not installed."
        echo "Installation in progress..."
        sudo Rscript -e 'install.packages("BiocManager", repos="http://cran.rstudio.com/")'
        echo "BiocManager is installed."
    fi

    if Rscript -e "if (!requireNamespace('bio3d', quietly = TRUE)) {quit(status = 1)}" &> /dev/null; then
        echo "bio3d is already installed."
    else
        echo "bio3d is not installed."
        echo "Installation in progress..."
        sudo Rscript -e 'install.packages("bio3d", repos="http://cran.rstudio.com/")'
        echo "bio3d is installed."
    fi
    
    if Rscript -e "if (!requireNamespace('msa', quietly = TRUE)) {quit(status = 1)}" &> /dev/null; then
        echo "msa is already installed."
    else
        echo "msa is not installed."
        echo "Installation in progress..."
        sudo Rscript -e 'BiocManager::install("msa")'
        echo "msa is installed."
    fi
fi
