#!/bin/bash

# 检查是否提供了正确的参数数量
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <directory path> <data type> <mode> <eb mode> <error bound>"
    exit 1
fi

DIRECTORY=$1
DATA_TYPE=$2
MODE=$3
ERROR_BOUND_TYPE=$4
ERROR_BOUND=$5

# 验证<data type>必须要是f32或f64
if [[ ! $DATA_TYPE =~ ^(f32|f64)$ ]]; then
    echo "Error: <data type> must be 'f32' or 'f64'."
    exit 1
fi

# 验证<mode>必须要是plain或outlier
if [[ ! $MODE =~ ^(plain|outlier)$ ]]; then
    echo "Error: <mode> must be 'plain' or 'outlier'."
    exit 1
fi

# 验证<rel or abs>必须要是rel或abs
if [[ ! $ERROR_BOUND_TYPE =~ ^(rel|abs)$ ]]; then
    echo "Error: <eb mode> must be 'rel' or 'abs'."
    exit 1
fi

# 初始化变量用于累加和计数
COMP_SPEED_SUM=0
DECOMP_SPEED_SUM=0
COMP_RATIO_SUM=0
FILE_COUNT=0

# 检查提供的目录路径是否存在且为目录
if [ ! -d "$DIRECTORY" ]; then
    echo "The provided path is not a valid directory: $DIRECTORY"
    exit 1
fi

# 遍历提供的目录中的所有文件
for FILE in "$DIRECTORY"/*; do
    if [ -f "$FILE" ]; then
        # 执行您的命令，并将输出捕获到变量中
        OUTPUT=$(../install/bin/hipSZ -i "$FILE" -t "$DATA_TYPE" -m "$MODE" -eb "$ERROR_BOUND_TYPE" "$ERROR_BOUND")
	echo $OUTPUT
        
        # 提取数值并验证是否为有效数字
        COMP_SPEED=$(echo "$OUTPUT" | grep "compression   end-to-end speed:" | awk '{print $5}')
        DECOMP_SPEED=$(echo "$OUTPUT" | grep "decompression end-to-end speed:" | awk '{print $5}')
        COMP_RATIO=$(echo "$OUTPUT" | grep "compression ratio:" | awk '{print $4}')

        # 检查提取的值是否为有效的数字
        if [[ $COMP_SPEED =~ ^[+-]?[0-9]+\.?[0-9]*$ ]] && [[ $DECOMP_SPEED =~ ^[+-]?[0-9]+\.?[0-9]*$ ]] && [[ $COMP_RATIO =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]; then
            # 累加数值
            COMP_SPEED_SUM=$(echo "$COMP_SPEED_SUM + $COMP_SPEED" | bc)
            DECOMP_SPEED_SUM=$(echo "$DECOMP_SPEED_SUM + $DECOMP_SPEED" | bc)
            COMP_RATIO_SUM=$(echo "$COMP_RATIO_SUM + $COMP_RATIO" | bc)

            # 文件计数器增加
            ((FILE_COUNT++))
        else
            echo "Warning: Invalid numeric value detected in file $FILE, skipping."
        fi
    fi
done

# 计算平均值
if [ $FILE_COUNT -gt 0 ]; then
    AVG_COMP_SPEED=$(echo "scale=2; $COMP_SPEED_SUM / $FILE_COUNT" | bc)
    AVG_DECOMP_SPEED=$(echo "scale=2; $DECOMP_SPEED_SUM / $FILE_COUNT" | bc)
    AVG_COMP_RATIO=$(echo "scale=2; $COMP_RATIO_SUM / $FILE_COUNT" | bc)

    # 输出平均值
    echo "hipSZ compression   end-to-end speed average: ${AVG_COMP_SPEED} GB/s"
    echo "hipSZ decompression end-to-end speed average: ${AVG_DECOMP_SPEED} GB/s"
    echo "hipSZ compression ratio average: ${AVG_COMP_RATIO}"
else
    echo "No files processed or all processed files had invalid numeric values."
fi
