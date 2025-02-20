import customtkinter as ctk
import tkinter as tk
from tkinter import filedialog, messagebox
import subprocess
import os
import shutil
import sys

def clean_r4s(input_file, output_file):
    """ Cleans rate4site output removing lines starting with # and empty lines. """
    try:
        with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
            lines = infile.readlines()
            filtered_lines = [line for line in lines if not line.startswith('#') and not line.isspace()]
            for line in filtered_lines:
                line_with_tabs = '\t'.join(line.split())
                outfile.write(line_with_tabs + '\n')
    except Exception as e:
        raise Exception(f"Failed to clean rate4site results: {e}")

def copy_pdb():
    """ Generates a copy of the pdb file provided by the user. """
    try:
        pdb_path = file_path_entry_pdb.get()
        user_path = os.path.dirname(__file__)
        if not pdb_path:
            raise ValueError("The PDB file was not found.")
        
        destination_path = user_path
        temp_copied_file_path = os.path.join(destination_path, "pdb_cleaned.pdb")
        
        # Generate the temporary file
        shutil.copy(pdb_path, temp_copied_file_path)
        
    except Exception as e:
        messagebox.showerror("Error", f"The PDB file has not been properly copied and/or renamed: {e}")

def min_max_bounds(min_bound, max_bound, chain_choice, output_file):
    """ Get the min and max coordinates provided by the user. """
    pdb_cleaned_path = os.path.join(os.getcwd(), "pdb_cleaned.pdb")
    try:
        with open(pdb_cleaned_path, 'r') as infile, open(output_file, 'w') as outfile:
            lines = infile.readlines()
            for line in lines:
                if line.startswith('ATOM'):
                    residue_number = int(line[22:26])
                    residue_chain = line[21]
                    if residue_chain == chain_choice and min_bound <= residue_number <= max_bound:
                        outfile.write(line)
    except Exception as e:
        raise Exception(f"Failed to apply min-max bounds to pdb_cleaned.pdb: {e}")

def execute_R():
    """ Executes the Rscript to compute spatially correlated site-specific substitution rates. """
    r_script_path = os.path.join(os.path.dirname(__file__), "R_script.R")
    proportion = slider_value
    if orientation_var.get() == "Side-chain orientation":
        subprocess.run(["Rscript", r_script_path, "lateral_chain", str(proportion)])
    elif orientation_var.get() == "Alpha-carbon":
         subprocess.run(["Rscript", r_script_path, "carbone_alpha", str(proportion)])

def pymol(chain):
    """ Produces a file to be read in PyMOL to show the conserved patch of amino acid sites. """
    def read_numbers_from_file(file_path):
        numbers = []
        with open(file_path, 'r') as file:
            lines = file.readlines()
            for line in lines[1:]:
                if line.strip().isdigit():
                    numbers.append(int(line.strip()))
        return numbers

    file_path = os.path.join(os.path.dirname(__file__), "top10percent.txt")
    pdb_path = file_path_entry_pdb.get()
    numbers = read_numbers_from_file(file_path)

    pymol_script = f"load {pdb_path}\n"
    for residue in numbers:
        pymol_script += f"select conserved_{residue}, chain {chain} and resi {residue}\n"
        pymol_script += f"color red, conserved_{residue}\n"

    pymol_script += f"hide everything, all\n"
    pymol_script += f"show cartoon, chain {chain}\n"
    pymol_script += f"show sticks, chain {chain} and (" + " or ".join([f"resi {residue}" for residue in numbers]) + ")\n"
    pymol_script += f"zoom chain {chain} and (" + " or ".join([f"resi {residue}" for residue in numbers]) + ")\n"

    pml_file_path = os.path.join(os.path.dirname(__file__), "color_conserved.pml")
    with open(pml_file_path, "w") as file:
        file.write(pymol_script)

    print(f"PyMOL script successfully generated: {os.path.abspath(pml_file_path)}")



def add_bounds_entry():
    """ Graphical interface parameters. """
    entry_frame = ctk.CTkFrame(bounds_frame)
    entry_frame.grid(row=len(bounds_entries) + 2, column=0, pady=5)  # Adjusted row position

    min_bound_label = ctk.CTkLabel(entry_frame, text="Min bound:")
    min_bound_label.grid(row=0, column=0, padx=5)

    min_bound_entry = ctk.CTkEntry(entry_frame, width=50)
    min_bound_entry.grid(row=0, column=1, padx=5)

    max_bound_label = ctk.CTkLabel(entry_frame, text="Max bound:")
    max_bound_label.grid(row=0, column=2, padx=5)

    max_bound_entry = ctk.CTkEntry(entry_frame, width=50)
    max_bound_entry.grid(row=0, column=3, padx=5)

    chain_choice_label = ctk.CTkLabel(entry_frame, text="Chain:")
    chain_choice_label.grid(row=0, column=4, padx=5)

    chain_choice_entry = ctk.CTkEntry(entry_frame, width=50)
    chain_choice_entry.grid(row=0, column=5, padx=5)

    bounds_entries.append((min_bound_entry, max_bound_entry, chain_choice_entry))


def run_rate4site():
    """ Executes the rate4site program to compute site-specific substitution rates. """
    filepath = file_path_entry_r4s.get()
    print(filepath)

    result_folderpath = os.path.join(os.path.dirname(__file__))
    print(result_folderpath)

    rate4site_command = f"/usr/bin/rate4site -s {filepath} -bn -o {result_folderpath}/results.txt"

    full_command = f"cd {result_folderpath} && {rate4site_command}"

    process = subprocess.Popen(full_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, bufsize=1)

    while True:
        line = process.stdout.readline()
        if not line:
            break
        print(line.strip())
        if "Computing the rates..." in line:
            print("Rate computation has started.")

    process.wait()


def move_result_i():
    """ Define the current repository. """
    os.chdir(os.path.dirname(__file__))


def get_unique_directory_name(base_name):
    """ If the repository Results already exists, give another name to the result repository. """
    counter = 1
    unique_name = base_name
    while os.path.exists(unique_name):
        unique_name = f"{base_name}{counter}"
        counter += 1
    return unique_name

def get_unique_directory_name2(base_name):
    counter = 0
    unique_name = f"{base_name}_{counter}"
    while os.path.exists(unique_name):
        counter += 1
        unique_name = f"{base_name}_{counter}"
    return unique_name


def show_value(value):
    label.configure(text=f"Selected: {int(float(value))}%")
    global slider_value
    slider_value = int(value)  # Stocker la valeur actuelle du slider
    
def execute():
    """ Executes the pipeline. """
    os.chdir(os.path.dirname(__file__))
    run_rate4site()
    clean_r4s("r4sOrig.res", "subrate.txt")
    copy_pdb()

    #Check if the min-max and/or chain were defined
    bounds_defined = any(entry[0].get() or entry[1].get() or entry[2].get() for entry in bounds_entries)
    
    if not bounds_defined:
        # If not specified, use the first chain and the complete sequence
        pdb_cleaned_path = os.path.join(os.getcwd(), "pdb_cleaned.pdb")
        try:
            with open(pdb_cleaned_path, 'r') as infile:
                for line in infile:
                    if line.startswith("ATOM"):
                        first_chain = line[21]
                        break
                        
        except IndexError:
            print("Error: Impossible to read column 4 of the PDB file.")
            return
        
        output_file = os.path.join(os.getcwd(), "pdb_cleaned_1_chaine.pdb")
        min_max_bounds(0, float("inf"), first_chain, output_file)
        os.remove("pdb_cleaned.pdb")
        
        os.rename(output_file, "pdb_cleaned.pdb")
          
        execute_R()
        if os.path.exists("top10percent.txt"):
            pymol(first_chain)
            if os.path.exists("color_conserved.pml"):
                root.quit()

            # Create a repository for the results
            result_dir = get_unique_directory_name("results")
            os.makedirs(result_dir)

            # Move the result files to the result repository
            os.rename("top10percent.txt", os.path.join(result_dir, "top10percent.txt"))
            os.rename("color_conserved.pml", os.path.join(result_dir, "color_conserved.pml"))
            os.rename("pdb_cleaned.pdb", os.path.join(result_dir, "pdb_cleaned.pdb"))
            os.rename("log_files.txt", os.path.join(result_dir, "log_files.txt"))
            os.rename("spatial_rates.txt", os.path.join(result_dir, "spatial_rates.txt"))
            os.rename("results.txt", os.path.join(result_dir, "results.txt"))
            os.rename("subrate.txt", os.path.join(result_dir, "subrate.txt"))
            os.rename("r4sOrig.res", os.path.join(result_dir, "r4sOrig.res"))
            os.rename("r4s.res", os.path.join(result_dir, "r4s.res"))
            os.rename("TheTree.txt", os.path.join(result_dir, "TheTree.txt"))

            file_to_move = result_dir
            user_file_path = os.path.normpath(file_path_entry_user.get())
            current_working_directory = os.path.normpath(os.getcwd())

            destination_path = os.path.join(user_file_path, file_to_move)
            destination_path = get_unique_directory_name(destination_path)

            shutil.move(file_to_move, destination_path)
            print(f"The file {file_to_move} has been moved to {destination_path}")

    else:  # if min-max and/or chain were specified
        for i, entry in enumerate(bounds_entries):
            min_bound = entry[0].get()
            max_bound = entry[1].get()
            chain_choice = entry[2].get()

            pdb_cleaned_path = os.path.join(os.getcwd(), "pdb_cleaned.pdb")
            available_chains = set()
            try:
                with open(pdb_cleaned_path, 'r') as infile:
                    for line in infile:
                        if line.startswith("ATOM"):
                            available_chains.add(line[21])
            except IndexError:
                print("Error: Impossible to read the column 4 of the PDB file.")
                return
            
            if not chain_choice:  # If the chain was not specified, use the first chain
                with open(pdb_cleaned_path, 'r') as infile:
                    for line in infile:
                        if line.startswith("ATOM"):
                            chain_choice = line[21]
                            break
                
                if not chain_choice:
                    print("Error: No atom found in the PDB file.")
                    return

            # Check if the chain exists
            if chain_choice not in available_chains:
                print(f"Error : The chain '{chain_choice}' does not exist in the PDB file.")
                return

            if not min_bound:  # If min_bound was not defined, use 0 as the start of the sequence
                min_bound = 0
            else:
                min_bound = int(min_bound)

            if not max_bound:  # If max_bound was not defined, use "inf" to consider the complete sequence
                max_bound = float("inf")
            else:
                max_bound = int(max_bound)

            output_file = os.path.join(os.getcwd(), f"pdb_cleaned_{i + 1}.pdb")
            min_max_bounds(min_bound, max_bound, chain_choice, output_file)

        os.remove("pdb_cleaned.pdb")
        for i in range(1, len(bounds_entries) + 1):
            temp_pdb_cleaned_file = f"pdb_cleaned_{i}.pdb"

            os.rename(temp_pdb_cleaned_file, "pdb_cleaned.pdb")

            # Execute the R script
            execute_R()
            if os.path.exists("top10percent.txt"):
                pymol(chain_choice)
                result_dir = get_unique_directory_name2("results")
                os.makedirs(result_dir)

                os.rename("top10percent.txt", os.path.join(result_dir, "top10percent.txt"))
                os.rename("color_conserved.pml", os.path.join(result_dir, "color_conserved.pml"))
                os.rename("pdb_cleaned.pdb", os.path.join(result_dir, "pdb_cleaned.pdb"))
                os.rename("log_files.txt", os.path.join(result_dir, "log_files.txt"))
                os.rename("spatial_rates.txt", os.path.join(result_dir, "spatial_rates.txt"))

                file_to_move = result_dir
                user_file_path = file_path_entry_user.get()

                destination_path = get_unique_directory_name2(os.path.join(user_file_path, "results"))

                shutil.move(file_to_move, destination_path)
                print(f"The file {file_to_move} has been moved to {destination_path}")
                
            

    messagebox.showinfo("Completed", "Program completed without error.")
    root.quit()



#########
###GUI###
#########
ctk.set_appearance_mode("light")
ctk.set_default_color_theme("blue")

root = ctk.CTk()
root.title("Construct")
bounds_entries = []

# Frame for the bounds
bounds_frame = ctk.CTkFrame(root)
bounds_frame.grid(row=1, column=0, padx=10, pady=10)

# Add a line button and info labels in a separate frame at the top
button_frame = ctk.CTkFrame(bounds_frame)
button_frame.grid(row=0, column=0, pady=5)

add_bounds_button = ctk.CTkButton(button_frame, text="Add a line", command=add_bounds_entry)
add_bounds_button.grid(row=0, column=1, padx=5, pady=10)

info_label_left = ctk.CTkLabel(button_frame, text="if not specified,\ntake all the sequence", text_color="grey", font=("Arial", 10, "italic"))
info_label_left.grid(row=0, column=0, padx=(0, 5), sticky='w')

info_label_right = ctk.CTkLabel(button_frame, text="if not specified,\ntake the first chain", text_color="grey", font=("Arial", 10, "italic"))
info_label_right.grid(row=0, column=2, padx=(0, 5), sticky='e')  # Align right of the button

add_bounds_entry()
# Initialize bounds_entries list empty (no initial call to add_bounds_entry)

# File path frame and widgets
file_path_frame = ctk.CTkFrame(root)
file_path_frame.grid(row=2, column=0, pady=10, padx=10)

file_path_label_user = ctk.CTkLabel(file_path_frame, text="Result file path:")
file_path_label_user.grid(row=0, column=0, pady=(10, 0))

file_path_entry_user = ctk.CTkEntry(file_path_frame, width=400, placeholder_text="No file selected")
file_path_entry_user.grid(row=1, column=0, padx=5, pady=5)

browse_button_user = ctk.CTkButton(file_path_frame, text="Browse", command=lambda: [file_path_entry_user.delete(0, tk.END), file_path_entry_user.insert(0, filedialog.askdirectory(title="Select the results folder"))])
browse_button_user.grid(row=2, column=0, padx=5, pady=5)

file_path_label_r4s = ctk.CTkLabel(file_path_frame, text="Fasta file path:")
file_path_label_r4s.grid(row=3, column=0, pady=(10, 0))

file_path_entry_r4s = ctk.CTkEntry(file_path_frame, width=400, placeholder_text="No file selected")
file_path_entry_r4s.grid(row=4, column=0, padx=5, pady=5)

browse_button_r4s = ctk.CTkButton(file_path_frame, text="Browse", command=lambda: [file_path_entry_r4s.delete(0, tk.END), file_path_entry_r4s.insert(0, filedialog.askopenfilename(title="Select the Fasta file", filetypes=[("Fasta files", "*.fa *.fasta"), ("All files", "*.*")]))])
browse_button_r4s.grid(row=5, column=0, padx=5, pady=5)

file_path_label_pdb = ctk.CTkLabel(file_path_frame, text="PDB file path:")
file_path_label_pdb.grid(row=6, column=0, pady=(10, 0))

file_path_entry_pdb = ctk.CTkEntry(file_path_frame, width=400, placeholder_text="No file selected")
file_path_entry_pdb.grid(row=7, column=0, padx=5, pady=5)

browse_button_pdb = ctk.CTkButton(file_path_frame, text="Browse", command=lambda: [file_path_entry_pdb.delete(0, tk.END), file_path_entry_pdb.insert(0, filedialog.askopenfilename(title="Select the PDB file", filetypes=[("PDB files", "*.pdb"), ("All files", "*.*")]))])
browse_button_pdb.grid(row=8, column=0, padx=5, pady=5)

# Frame for the radio buttons and run button
bottom_frame = ctk.CTkFrame(root)
bottom_frame.grid(row=6, column=0, pady=10, padx=10)

# Variable for radio button selection
orientation_var = tk.StringVar(value="Side-chain orientation")

# Frame for the radio buttons
radio_frame = ctk.CTkFrame(bottom_frame)
radio_frame.grid(row=1, column=0, pady=5)

# Ajouter une étiquette explicative au-dessus du slider
instruction_label1 = ctk.CTkLabel(radio_frame, text="Perform the search using:",  width=400,font=("Arial", 12, "bold"))
instruction_label1.grid(row=0, column=0, columnspan=2, pady=(0, 10), sticky="n")

# Radio buttons
radio_button1 = ctk.CTkRadioButton(radio_frame, text="Side-chain orientation", variable=orientation_var, value="Side-chain orientation")
radio_button1.grid(row=1, column=0, padx=5)

radio_button2 = ctk.CTkRadioButton(radio_frame, text="Alpha-carbon", variable=orientation_var, value="Alpha-carbon")
radio_button2.grid(row=1, column=1, padx=5)

# Ajouter une étiquette explicative au-dessus du slider
instruction_label = ctk.CTkLabel(radio_frame, text="Select the proportion of most \nconserved sites for searching patch", font=("Arial", 12, "bold"))
instruction_label.grid(row=3, column=0, columnspan=2, pady=(30, 0), sticky="n")

# Ajouter une étiquette pour afficher la valeur sélectionnée
label = ctk.CTkLabel(radio_frame, text="Selected: 10%", font=("Arial", 14))
label.grid(row=4, column=0, columnspan=2, pady=(10,0), sticky="n")

# Ajouter le slider
slider = ctk.CTkSlider(radio_frame, from_=5, to=20, command=show_value)
slider.set(10)  # Définir la valeur initiale
slider_value = 10
slider.grid(row=5, column=0, columnspan=2, sticky="ew", padx=10, pady=10)

# Frame for the run button
button_frame = ctk.CTkFrame(bottom_frame)
button_frame.grid(row=2, column=0, pady=10, padx=10)

# Run button
run_button = ctk.CTkButton(button_frame, text="Run post-processing", command=execute)
run_button.grid(row=0, column=0, pady=10, padx=10)

root.mainloop()
