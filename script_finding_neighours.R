setwd("~/Documents/PROJET_FUNCPATCH")

#######################################
###### IMPORTATION OF LIBRAIRIES ######
#######################################

library(readr)
library(dplyr)
library(msa)
library(ggplot2)
library(ggprism)
library(scatterplot3d)


###############################
###### LIST OF FUNCTIONS ######
###############################

#convert 3-letter amino acid codes to 1-letter code
convertAminoAcids <- function(pdb_dataframe) {
  # Define a mapping of 3-letter to 1-letter amino acid codes
  amino_acid_mapping <- c("ALA" = "A", "ARG" = "R", "ASN" = "N", "ASP" = "D",
                          "CYS" = "C", "GLU" = "E", "GLN" = "Q", "GLY" = "G",
                          "HIS" = "H", "ILE" = "I", "LEU" = "L", "LYS" = "K",
                          "MET" = "M", "PHE" = "F", "PRO" = "P", "SER" = "S",
                          "THR" = "T", "TRP" = "W", "TYR" = "Y", "VAL" = "V")
  
  # Function to convert 3-letter code to 1-letter code
  convert_single_code <- function(code) {
    if (nchar(code) > 3) {
      # If length is greater than 3, remove the first character
      code <- substr(code, 2, nchar(code))
    }
    return(amino_acid_mapping[toupper(code)])
  }
  
  # Apply the conversion function to the entire column
  pdb_dataframe$amino_acid_1letter <- sapply(pdb_dataframe$resname, convert_single_code)
  
  # Return the updated dataframe
  return(pdb_dataframe)
}

#align the sequence from the pdb and rate4site data
align_protein_sequences <- function(seq1, seq2) {
  # Create a multiple sequence alignment object
  alignment <- msa(c(seq1, seq2), type = "protein")
  
  #Print the alignment result
  #cat("Aligned Sequences:\n")
  #print(alignment)
  
  aligned_sequences <- as.character(alignment)
  
  return(aligned_sequences)
}

#calculate the euclidian distance between two amino acids in 3D structure
calculate_distance <- function(x1, y1, z1, x2, y2, z2) {
  sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
}

#Calculate the distance for each pair of amino acids in 3D structure
calculate_distances <- function(data) {
  n <- nrow(data)
  distances <- matrix(0, n, n) #initialization of the matrix
  
  #for each pair of amino acids, we applied the the function to calculate
  #the euclidian distance
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      distances[i, j] <- calculate_distance(
        data$center_x[i], data$center_y[i], data$center_z[i],
        data$center_x[j], data$center_y[j], data$center_z[j]
      )
      #we add the distance in the matrix
      distances[j, i] <- distances[i, j]
    }
  }
  
  #we rename the columns and rows based on the amino acid number
  rownames(distances) <- data$resno
  colnames(distances) <- data$resno
  
  return(distances)
}

#calculate a substitution rate considering the rates in neighbouring amino acids
calculate_subrate <- function(my_table) {
  #the site-specific substitution rates are divided by the distance between the amino acids
  #and the amino acid investigated
  my_table$val_dist = my_table$sub_rate / my_table$euclidian_distance
  #we correct the value for the current amino acid investigated
  for(i in 1:nrow(my_table)){
    if(my_table$val_dist[i] == "Inf"){
      my_table$val_dist[i] = my_table$sub_rate[i]
    }
  }
  #we calculate and return the site-specific spatial substitution rate
  my_new_val = mean(my_table$val_dist)
  return(my_new_val)
}

#calculate the center of mass for the 10% most conserved amino acid sites
calculate_center_of_mass_10 <- function(df) {
  center_of_mass <- colMeans(df)
  return(center_of_mass)
}


########################
#### MAIN PROGRAM ######
########################

#importation of the PDB file
pdb_data <- read_tsv("keap1.txt", col_names = c("ATOM", "record", "atom",
                                  "resname", "chain", "resno",
                                  "x", "y", "z", "occupancy",
                                  "bfactor", "element"))

#keep only amino acids with complete data
pdb_data <- as.data.frame(pdb_data)
pdb_data <- pdb_data[pdb_data$resno>=1,]
pdb_data <- pdb_data[complete.cases(pdb_data), ] 

pdb_data <- convertAminoAcids(pdb_data)

#importation of the rate4site data
r4s_data <- read_tsv("subrate.txt", col_names = c("Position", "amino_acid_1letter",
                                                  "sub_rate", "confidence", "std", "MSA"))


#####
#pdb_data$occupancy = 1
####


#Calculating the center of mass for each amino acid
center_of_mass <- pdb_data %>%
  group_by(resno, amino_acid_1letter) %>%
  summarize(
    center_x = sum(x * occupancy) / sum(occupancy),
    center_y = sum(y * occupancy) / sum(occupancy),
    center_z = sum(z * occupancy) / sum(occupancy)
  )

#plot the protein based amino acid center of mass
#scatterplot3d(center_of_mass[,2:4])

#generate the sequences
sequence_pdb = paste(center_of_mass$amino_acid_1letter, collapse = "")
sequence_r4s = paste(r4s_data$amino_acid_1letter, collapse = "")

#produce the alignment
my_alignment = align_protein_sequences(sequence_pdb, sequence_r4s)
align_seq_pdb = my_alignment[1]
#align_seq_pdb = strsplit(align_seq_pdb, '')[[1]]
align_seq_r4s <- my_alignment[2]
#align_seq_r4s = strsplit(align_seq_r4s, '')[[1]]

update_pdb = data.frame(
  AA = strsplit(align_seq_pdb, NULL)[[1]])
update_pdb$center_x = NA
update_pdb$center_y = NA
update_pdb$center_z = NA

start_com = 1
for (i in 1:nrow(update_pdb)){
  if(update_pdb$AA[i] != "-"){
    update_pdb$center_x[i] = center_of_mass$center_x[start_com]
    update_pdb$center_y[i] = center_of_mass$center_y[start_com]
    update_pdb$center_z[i] = center_of_mass$center_z[start_com]
    start_com = start_com + 1
  }
}

update_r4s = data.frame(
  AA = strsplit(align_seq_r4s, NULL)[[1]])
update_r4s$sub_rate = NA

start_r4s = 1
for (i in 1:nrow(update_r4s)){
  if(update_r4s$AA[i] != "-"){
    update_r4s$sub_rate[i] = r4s_data$sub_rate[start_r4s]
    start_r4s = start_r4s + 1
  }
}

#combine and keep only complete data
all_data = data.frame(update_pdb, update_r4s$sub_rate)
all_data <- merge(all_data, center_of_mass, by = c("center_x", "center_y", "center_z"))
names(all_data)[5] = "sub_rate"
all_data <- all_data[, c("resno", "amino_acid_1letter", "center_x",
                         "center_y", "center_z", "sub_rate")]
all_data <- all_data[order(all_data$resno), ]
all_data <- all_data[complete.cases(all_data), ] 

#get all coordinates and calculate pairwise euclidian distances
all_coordinates = all_data[,3:5]
distance_matrix <- as.data.frame(calculate_distances(all_data))

#defining a list of p-values (one pval for each distance investigated)
log_pval=c()  

spatial_rate_all = data.frame(matrix(NA, nrow = nrow(all_data), ncol = 20))

#we calculate spatial correlation of site-specific substitution rates in 3D
#structure using a distance from 1 to 20. The most relevant distance will be
#kept
for(my_distance in 1:20){
  
  all_data_update = all_data
  all_data_update$spatial_rate = 0
  
  for(i in 1:ncol(distance_matrix)){
  #keep the column
  current_AA = distance_matrix[,i]
  current_AA = data.frame(euclidian_distance = current_AA, num_AA = all_data_update$resno,
                          sub_rate = all_data_update$sub_rate)
  
  #for replicate study
  #test3$sub_rate <- sample(test3$sub_rate)
  
  #retain only the neighbouring amino acids within the defined distance
  current_AA_interest = current_AA[current_AA$euclidian_distance <= my_distance,]

  #calculate the spatial substitution rate and add in the general dataframe
  AA_spatial_rate = calculate_subrate(current_AA_interest)
  
  all_data_update$spatial_rate[i] = AA_spatial_rate
  }
  
  spatial_rate_all[,my_distance] = all_data_update$spatial_rate
  
  #we order the data based on the spatial rate, and add a rank in percentages
  all_data_update <- all_data_update[order(all_data_update$spatial_rate), ]
  all_data_update$rank = 0
  for(pos in 1:nrow(all_data_update)){
    all_data_update$rank[pos] = pos/nrow(all_data_update)*100
  }
  
  top10percent = all_data_update[all_data_update$rank<=10,]

  #get coordinates of the 10% most conserved sites
  for_center_of_mass = top10percent[,3:5]
  
  #Calculate center of mass of the 10% most conserved sites
  center_mass_10p <- as.vector(calculate_center_of_mass_10(for_center_of_mass))
  
  #initialization. The variable will calculate the distance between the
  #amino acid and the center of mass based on the 10% most conserved sites
  all_data_update$distance_com_10p = 0
  
  for(ii in 1:nrow(all_data_update)){
    all_data_update$distance_com_10p[ii] = sqrt(rowSums((all_data_update[ii,c("center_x","center_y","center_z")] - center_mass_10p)^2))
  }

  #generate two vectors of distance, consisting of the 10% most conserved sites
  #and the other sites
  distance_10percent = all_data_update[all_data_update$rank<=10,]
  distance_10percent = c(distance_10percent$distance_com)
  distance_90percent = all_data_update[all_data_update$rank>10,]
  distance_90percent = c(distance_90percent$distance_com)
  
  #mann_whitney = wilcox.test(distance_10percent,distance_90percent) 
  #we perform a t-test
  statistical_test = t.test(distance_10percent,distance_90percent,var.equal=F,alternative="less")
  
  #we retrieve the pvalue and add in the list of pvalues
  new_pval = statistical_test$p.value
  log_npval = -log(new_pval)
  log_pval = c(log_pval, log_npval)
}

#identify the length with the most significant spatial correlation
log_pval_data = as.data.frame(log_pval)
best_length <- which.max(log_pval_data$log_pval)

#update the general dataframe
all_data$spatial_rate = spatial_rate_all[,best_length]
#order and rank the values based on the spatial rates
all_data <- all_data[order(all_data$spatial_rate), ]
all_data$rank = 0
for(pos in 1:nrow(all_data)){
  all_data$rank[pos] = pos/nrow(all_data)*100
}

#keep only important columns and save in a file
saving_data = all_data[,c(1,2,7,8)]
write.table(saving_data, "spatial_rates.txt", sep = "\t", col.names = T,
            row.names = F, quote = F)






















log_pval_data = as.data.frame(log_pval_data)
names(log_pval_data)[1] = "pval"

base = ggplot(log_pval_data, aes(x = pval))+
  geom_histogram(binwidth=1)+
  geom_vline(aes(xintercept = 10), color="blue", linetype="dashed", size=1)

 base + 
   scale_color_prism("floral") + 
   scale_fill_prism("floral") + 
   guides(y = "prism_offset_minor") + 
   theme_prism(base_size = 14) 

 
 
 
 
 
 pval_data2 = as.data.frame(pval_data[pval_data$pval<=0.001,])
 names(pval_data2)[1] = "pval"
 
 base = ggplot(pval_data2, aes(x = pval))+
   geom_histogram(binwidth=0.000000001)+
   geom_vline(aes(xintercept = 0.00001), color="blue", linetype="dashed", size=1)
 
 base + 
   scale_color_prism("floral") + 
   scale_fill_prism("floral") + 
   guides(y = "prism_offset_minor") + 
   theme_prism(base_size = 14) 
 
 
 
 
 
 ####old version
 
 # for (dash_index in dash_indices) {
 #   new_row <- setNames(rep(NA, ncol(r4s_data)), names(r4s_data))
 #   
 #   #if a new line is added at index 1, do not duplicate
 #   if (dash_index != length(align_seq_r4s)) {
 #     r4s_data <- rbind(r4s_data[1:(dash_index - 1), , drop=FALSE],
 #                       new_row,
 #                       r4s_data[dash_index:nrow(r4s_data), , drop=FALSE])
 #   } else if (dash_index == 1) {
 #     r4s_data <- rbind(new_row, r4s_data)
 #   }
 # }
 
 
 
 
 
 # 
 # 
 # #we must update the table to check for lacking amino acids in 3D structure
 # #Expected sequence from resno
 # if(min(center_of_mass$resno)<min(r4s_data$Position) && max(center_of_mass$resno)>max(r4s_data$Position)){
 #   expected_sequence <- seq(min(center_of_mass$resno), max(center_of_mass$resno))
 # }else if(min(center_of_mass$resno)>min(r4s_data$Position) && max(center_of_mass$resno)>max(r4s_data$Position)){
 #   expected_sequence <- seq(min(r4s_data$Position), max(center_of_mass$resno))
 # }else if(min(center_of_mass$resno)<min(r4s_data$Position) && max(center_of_mass$resno)<max(r4s_data$Position)){
 #   expected_sequence <- seq(min(center_of_mass$resno), max(r4s_data$Position))
 # }else if(min(center_of_mass$resno)>min(r4s_data$Position) && max(center_of_mass$resno)<max(r4s_data$Position)){
 #   expected_sequence <- seq(min(r4s_data$Position), max(r4s_data$Position))
 # }
 #    
 # 
 # #find the lacking amino acids
 # missing_values <- setdiff(expected_sequence, center_of_mass$resno)
 # 
 # #add rows with NA for lacking amino acids
 # for (missing_value in missing_values) {
 #   new_row <- setNames(rep(NA, ncol(center_of_mass)), names(center_of_mass))
 #   new_row$resno <- missing_value
 #   center_of_mass <- rbind(center_of_mass, new_row)
 # }
 # 
 # #update the table
 # center_of_mass <- center_of_mass[order(center_of_mass$resno), ]
 # 
 # #Find lacking data in the rate4site data, compared to the 3D structure
 # dash_indices <- which(align_seq_r4s == "-")
 # 
 # #add a row when lacking data
 # for (dash_index in dash_indices){
 #   r4s_data[nrow(r4s_data)+1,] = list(dash_index, NA, NA, NA, NA, NA)
 # }
 # 
 # #update the table
 # r4s_data <- r4s_data[order(r4s_data$Position), ]
 # 
 # #reinitialize the index of the dataframe
 # rownames(r4s_data) <- NULL
 
 
 