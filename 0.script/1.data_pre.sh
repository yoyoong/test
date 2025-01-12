h5_list=$(find /sibcb1/bioinformatics/hongyuyang/dataset/Tres/2.tisch_data/0.raw_data -name "*.h5")
# h5_path=/sibcb1/bioinformatics/hongyuyang/dataset/Tres/2.tisch_data/0.raw_data/BRCA_GSE161529_expression.h5
for h5_path in ${h5_list[@]}
do
  h5_filename=$(basename "${h5_path}")
  h5_tag=$(echo "${h5_filename}" | sed 's/_expression.h5//g')
  echo "Processing file: ${h5_tag}"

  celltype_mapping_rules_file=/sibcb1/bioinformatics/hongyuyang/dataset/Tres/0.model_file/tisch_celltype_mapping_rule.txt
  output_file_directory=/sibcb1/bioinformatics/hongyuyang/dataset/Tres/2.tisch_data/1.gem_data

  log_path=/sibcb1/bioinformatics/hongyuyang/code/Tres/log/2.tisch_data/convert_mtx/${h5_tag}.log
  rm ${log_path}
  echo "python3 /sibcb1/bioinformatics/hongyuyang/code/Tres/1.data_pre/convert_mtx.py -I ${h5_path} -CTR ${celltype_mapping_rules_file} -D ${output_file_directory} -O ${h5_tag}" | \
    qsub -q b1.q@fnode004.sibcb.ac.cn -N ${h5_tag} -V -cwd -o ${log_path} -j y
  sleep 1m
done

# pre_train_data2: split the gem data by cell type
gem_list=$(find /sibcb1/bioinformatics/hongyuyang/dataset/Tres/2.tisch_data/1.gem_data -maxdepth 1 -name "*.csv")
# gem_list=("/sibcb1/bioinformatics/hongyuyang/dataset/Tres/2.tisch_data/1.gem_data/CHOL_GSE138709.csv" "/sibcb1/bioinformatics/hongyuyang/dataset/Tres/2.tisch_data/1.gem_data/NSCLC_GSE127465.csv")
for gem_path in ${gem_list[@]}
do
  gem_filename=$(basename "${gem_path}")
  gem_tag=$(echo "${gem_filename}" | cut -d "." -f1)
  echo "Processing file: ${gem_tag}"
  output_file_directory=/sibcb1/bioinformatics/hongyuyang/dataset/Tres/2.tisch_data/1.new_gem_data
  log_path=/sibcb1/bioinformatics/hongyuyang/code/Tres/log/2.tisch_data/pre_train_data2/${gem_tag}.log
  rm ${log_path}
  echo "python3 /sibcb1/bioinformatics/hongyuyang/code/Tres/1.data_pre/pre_train_data2.py -E ${gem_path} -D ${output_file_directory} -O ${gem_tag}" | \
    qsub -q g5.q@fnode003.sibcb.ac.cn -N ${gem_tag} -V -cwd -o ${log_path} -j y
  sleep 1m
done

# rds -> csv: convert shijiantao rds data to csv
rds_list=$(find /sibcb1/bioinformatics/shijiantao/rasc/RDS -maxdepth 1 -name "*.RDS")
for rds_path in ${rds_list[@]}
do
  filename=$(basename "${rds_path}")
  tag=$(echo "${filename}" | cut -d "." -f1)
  echo "Processing file: ${tag}"
  log_path=/sibcb1/bioinformatics/hongyuyang/code/Tres/log/2.tisch_data/rds2csv/${tag}.log
  rm -rf ${log_path}
  echo "/sibcb2/bioinformatics/software/Miniconda3/bin/Rscript /sibcb1/bioinformatics/hongyuyang/code/Tres/1.data_pre/rds2csv.R --tag ${tag}" | \
    qsub -q gpu.q@gpu004.sibcb.ac.cn -N ${tag} -V -cwd -o ${log_path} -j y
done

rds_list=("PAAD_CRA001160")
for tag in ${rds_list[@]}
do
  echo "Processing file: ${tag}"
  log_path=/sibcb1/bioinformatics/hongyuyang/code/Tres/log/2.tisch_data/rds2csv/${tag}.log
  rm -rf ${log_path}
  echo "/sibcb2/bioinformatics/software/Miniconda3/bin/Rscript /sibcb1/bioinformatics/hongyuyang/code/Tres/1.data_pre/rds2csv.R --tag ${tag}" | \
    qsub -q g5.q@fnode014.sibcb.ac.cn -N ${tag} -V -cwd -o ${log_path} -j y
done

# pre_train_data3: rename the rds2csv data's column name and split by cell type
gem_list=$(find /sibcb1/bioinformatics/hongyuyang/dataset/Tres/2.tisch_count_data -maxdepth 1 -name "*.csv")
for gem_path in ${gem_list[@]}
do
  gem_filename=$(basename "${gem_path}")
  gem_tag=$(echo "${gem_filename}" | cut -d "." -f1)
  echo "Processing file: ${gem_tag}"
  output_file_directory=/sibcb1/bioinformatics/hongyuyang/dataset/Tres/2.tisch_count_data2
  log_path=/sibcb1/bioinformatics/hongyuyang/code/Tres/log/2.tisch_data/pre_train_data3/${gem_tag}.log
  rm ${log_path}
  echo "python3 /sibcb1/bioinformatics/hongyuyang/code/Tres/1.data_pre/pre_train_data3.py -E ${gem_path} -D ${output_file_directory} -O ${gem_tag}" | \
    qsub -q g5.q@fnode013.sibcb.ac.cn -N ${gem_tag} -V -cwd -o ${log_path} -j y
  sleep 10s
done