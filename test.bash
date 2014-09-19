#!/bin/bash
set -ueo pipefail
script_dir=$(cd "$(dirname "$0")"; pwd)
PATH="$PATH:$script_dir"
source pathlib.bash

assert_num=0
assert_ok_num=0

# $1: assert name
# $2: actual exp
# $3: expect exp
assert_eq(){
	local actual=$(eval "echo \"$1\"")
	local expect=$(eval "echo \"$2\"")
	if [[ "$actual" == "$expect" ]] ; then
		assert_ok_num=$(( assert_ok_num + 1 ))
	else
		echo "assert [$assert_num] failed: "
		echo "  actual [$1] => [$actual]"
		echo "  expect [$2] => [$expect]"
	fi
	assert_num=$(( assert_num + 1 ))
}

exec_test(){
	echo "exec test [$1]"
	assert_num=0
	assert_ok_num=0

	eval "test_$1" || :
	
	echo -n "=> $assert_ok_num/$assert_num: "
	if [[ $assert_ok_num -eq $assert_num ]] ; then
		echo "ok"
	else
		echo "failed"
	fi
}

test_array_copy(){
	local a=(1 2 3)
	local b
	array_copy a b
	assert_eq '${#b[@]}' '3'
	assert_eq '${b[0]}'  '1'
	assert_eq '${b[1]}'  '2'
	assert_eq '${b[2]}'  '3'
	
	a=()
	array_copy a b
	assert_eq '${#b[@]}'  '0'

}

test_str_pos(){
	assert_eq '$(str_pos "abcde" "a")'   '0'
	assert_eq '$(str_pos "abcde" "bc")'  '1'
	assert_eq '$(str_pos "abcde" "cde")' '2'
	assert_eq '$(str_pos "abcde" "f")'   '-1'
	assert_eq '$(str_pos "ab cde" " ")'   '2'
}

test_str_split(){
	local a
	str_split "" "/" a
	assert_eq '${#a[@]}' '0'

	str_split "a" "/" a
	assert_eq '${#a[@]}' '1'
	assert_eq '${a[0]}' 'a'

	str_split "/" "/" a
	assert_eq '${#a[@]}' '2'
	assert_eq '${a[0]}' ''
	assert_eq '${a[1]}' ''
}

main(){
	exec_test array_copy
	exec_test str_pos
	exec_test str_split
}

main
