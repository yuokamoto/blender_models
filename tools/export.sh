#!/bin/bash

# ヘルプメッセージを表示する関数
function show_help {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --help                Display this help message and exit"
    echo "  --blender_path PATH   Specify the path to Blender executable (relative or absolute)"
    echo "  --src_blender_file PATH   Specify the source Blender file path (relative or absolute)"
    echo "  --target_fbx PATH     Specify the target FBX file path (relative or absolute)"
    echo "  --python_script PATH  Specify the path to the Python script to be run in Blender (relative or absolute)"
    # 他のオプションやスクリプトの説明をここに追加できます
    echo "Export FBX file from given source blender file after applying all modifiers."
}

# デフォルトのBlenderパスを設定
default_blender_path=${BLENDER_PATH:-"blender"}

# デフォルトのソースBlenderファイルとターゲットFBXファイルを設定
default_src_blender_file="source.blend"
default_target_fbx="target.fbx"

# デフォルトのPythonスクリプトのパスを設定
default_python_script="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/export.py"

# 引数の解析
while getopts ":h-:" opt; do
    case "${opt}" in
        -)
            case "${OPTARG}" in
                help)
                    show_help
                    exit 0
                    ;;
                blender_path)
                    blender_path="${!OPTIND}"
                    ((OPTIND++))
                    ;;
                src_blender_file)
                    src_blender_file="${!OPTIND}"
                    ((OPTIND++))
                    ;;
                target_fbx)
                    target_fbx="${!OPTIND}"
                    ((OPTIND++))
                    ;;
                python_script)
                    python_script="${!OPTIND}"
                    ((OPTIND++))
                    ;;
                *)
                    echo "Invalid option: --$OPTARG" >&2
                    show_help
                    exit 1
                    ;;
            esac
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help
            exit 1
            ;;
    esac
done

# Blenderパスが指定されていない場合はデフォルト値を使用
blender_path=${blender_path:-$default_blender_path}

# ソースBlenderファイルパスが指定されていない場合はデフォルト値を使用
src_blender_file=${src_blender_file:-$default_src_blender_file}

# ターゲットFBXファイルパスが指定されていない場合はデフォルト値を使用
target_fbx=${target_fbx:-$default_target_fbx}

# Pythonスクリプトのパスが指定されていない場合はデフォルト値を使用
python_script=${python_script:-$default_python_script}

# 相対パスを絶対パスに変換する関数
function convert_to_absolute_path {
    local path="$1"
    if [[ ! $path == /* ]]; then
        # 相対パスを絶対パスに変換
        path="$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    fi
    echo "$path"
}

# パスを絶対パスに変換
blender_path=$(convert_to_absolute_path "$blender_path")
src_blender_file=$(convert_to_absolute_path "$src_blender_file")
target_fbx=$(convert_to_absolute_path "$target_fbx")
python_script=$(convert_to_absolute_path "$python_script")

# ここにスクリプトの本体を記述します
echo "Using Blender path: $blender_path"
echo "Source Blender file path: $src_blender_file"
echo "Target FBX file path: $target_fbx"
echo "Python script path: $python_script"

# Blenderを実行してPythonスクリプトを実行し、BlenderファイルをFBX形式でエクスポート
"$blender_path" "$src_blender_file" --background --python "$python_script" -- "$target_fbx"
