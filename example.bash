#!/bin/bash
set -ueo pipefail

# このようにして、sourceコマンドでロードするか、
# もしくは全文コピペすると良い。
script_dir=$(cd "$(dirname "$0")"; pwd)
PATH="$PATH:$script_dir"
source pathlib.bash

read -p "起点のパスを入力してください。: " from
read -p "宛先のパスを入力してください。: " to

echo "起点パス:"
echo "    $(path_get_absolute "$from")"
echo "宛先パス:"
echo "    $(path_get_absolute "$to")"

relat=$(path_get_relative "$from" "$to")
echo "起点からの相対宛先:"
echo "    $relat"

fromrelat=$(path_append "$from" "$relat")
echo "起点と相対の結合:"
echo "    $fromrelat"

stn=$(path_standardize "$fromrelat")
echo "その正規化:"
echo "    $stn"
