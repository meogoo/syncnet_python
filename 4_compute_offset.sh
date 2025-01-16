#!/bin/bash


##################
# 尝试使用 which 命令查找 conda 的路径
CONDA_EXE=$(which conda)
if [ -z "$CONDA_EXE" ]; then
    echo "Error: Conda installation not found in PATH."
    exit 1
fi
CONDA_ROOT=$(dirname $(dirname $CONDA_EXE))

# 手动初始化 Conda
eval "$($CONDA_ROOT/bin/conda shell.bash hook)"
if ! command -v conda >/dev/null 2>&1; then
    echo "Error: Failed to initialize Conda."
    exit 1
fi

# 激活所需的环境
ENV_NAME="sync_3_8"  # 替换为你的环境名称
conda activate $ENV_NAME
if [ $? -ne 0 ]; then
    echo "Failed to activate the conda environment: $ENV_NAME"
    exit 1
fi
echo "Conda environment '$ENV_NAME' activated successfully."
##################


# 检查是否提供了两个参数
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input_dir output_file"
    exit 1
fi

INPUT_DIR=$1
OUTPUT_FILE=$2

# 检查输入目录是否存在
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Directory '$INPUT_DIR' does not exist."
    exit 1
fi

# 创建或清空输出文件
> "$OUTPUT_FILE"

###################

absolute_path=$(realpath "$INPUT_DIR")
echo "absolute_path: $absolute_path"


# 遍历输入目录中的所有 .mp4 文件，并使用相对路径
find "$absolute_path" -type f -name "*.mp4" | while read -r file; do

    echo "get $file"

    # 获取文件相对于输入目录的相对路径
    rel_path=$(realpath --relative-to="$absolute_path" "$file")
    echo "get $rel_path"

    # 定义目标目录，并确保其存在
    target_dir="./tmp/"
    mkdir -p "$target_dir"
    
    # 提取文件名（不带路径，不带扩展名）
    pure_file_name="${file##*/}"
    pure_file_name="${pure_file_name%.*}"

    # 生成随机数后缀，创建新文件名（包含原始扩展名）
    random_suffix=$(date +%s%N | md5sum | head -c 8)
    new_tmp_path="${target_dir}${pure_file_name}_${random_suffix}"

    echo "New tmp path: $new_tmp_path"
    echo "To Process $file"

    # 调用 offset 并捕获其输出（同时捕获标准错误流）
    cmd="python3 demo_syncnet.py --videofile \"$file\" --tmp_dir \"$new_tmp_path\""
    echo "Executing command: $cmd"
    result=$(eval "$cmd")
    
    #result=$(python3 demo_syncnet.py --videofile "$file" --tmp_dir "$new_tmp_path" 2>&1) || { echo "Failed to process $file"; continue; }
    echo "Result: $result"

    # 将文件的相对路径和结果写入输出文件
    av_offset_line=$(echo "$result" | grep "^AV offset")
    echo "$rel_path : $av_offset_line" >> "$OUTPUT_FILE"

    # 删除临时文件
    rm -rf "$new_tmp_path"

done

echo "Processing completed. Results saved to $OUTPUT_FILE"