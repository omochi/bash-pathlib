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
	str_split "" / a
	assert_eq '${#a[@]}' '0'

	str_split "a" / a
	assert_eq '${#a[@]}' '1'
	assert_eq '${a[0]}' 'a'

	str_split "/" / a
	assert_eq '${#a[@]}' '2'
	assert_eq '${a[0]}' ''
	assert_eq '${a[1]}' ''

	str_split "  a/b//c  c/" / a
	assert_eq '${#a[@]}' '5'
	assert_eq '${a[0]}' '  a'
	assert_eq '${a[1]}' 'b'
	assert_eq '${a[2]}' ''
	assert_eq '${a[3]}' 'c  c'
	assert_eq '${a[4]}' ''

	str_split "/  a/b" / a
	assert_eq '${#a[@]}' '3'
	assert_eq '${a[0]}' ''
	assert_eq '${a[1]}' '  a'
	assert_eq '${a[2]}' 'b'
}

test_array_join(){
	local a
	a=()
	assert_eq '$(array_join a /)' ''
	a=("   ")
	assert_eq '$(array_join a /)' '   '
	a=("   " "  ab  ")
	assert_eq '$(array_join a /)' '   /  ab  '
	a=("   " "  ab  " " c ")
	assert_eq '$(array_join a /)' '   /  ab  / c '
}

test_path_is_absolute(){
	assert_eq '$(path_is_absolute "" && echo y || echo n)'           'n'
	assert_eq '$(path_is_absolute "abc" && echo y || echo n)'        'n'
	assert_eq '$(path_is_absolute "abc/def" && echo y || echo n)'    'n'
	assert_eq '$(path_is_absolute "./abc/def" && echo y || echo n)'  'n'
	assert_eq '$(path_is_absolute "../abc/def" && echo y || echo n)' 'n'
	assert_eq '$(path_is_absolute "/" && echo y || echo n)'          'y'
	assert_eq '$(path_is_absolute "/abc" && echo y || echo n)'       'y'
	assert_eq '$(path_is_absolute "/abc/def" && echo y || echo n)'   'y'
	assert_eq '$(path_is_absolute "/../" && echo y || echo n)'       'y'
}

test_path_append(){
	assert_eq '$(path_append "" "")'                         ''
	assert_eq '$(path_append "/" "")'                        '/'
	assert_eq '$(path_append "abc" "def")'                   'abc/def'
	assert_eq '$(path_append "abc/" "def")'                  'abc/def'
	assert_eq '$(path_append "./ab  c/def/" "../g  hi")'     './ab  c/def/../g  hi'
	assert_eq '$(path_append "/abc/def" "../ghi")'           '/abc/def/../ghi'
}

test_path_split(){
	local a
	path_split "" a
	assert_eq '${#a[@]}' '0'

	path_split "a" a
	assert_eq '${#a[@]}' '1'
	assert_eq '${a[0]}' 'a'

	path_split "  a  " a
	assert_eq '${#a[@]}' '1'
	assert_eq '${a[0]}' '  a  '

	path_split "a/b" a
	assert_eq '${#a[@]}' '2'
	assert_eq '${a[0]}' 'a'
	assert_eq '${a[1]}' 'b'

	path_split "./b/c" a
	assert_eq '${#a[@]}' '3'
	assert_eq '${a[0]}' '.'
	assert_eq '${a[1]}' 'b'
	assert_eq '${a[2]}' 'c'

	path_split "a/..//c/" a
	assert_eq '${#a[@]}' '5'
	assert_eq '${a[0]}' 'a'
	assert_eq '${a[1]}' '..'
	assert_eq '${a[2]}' ''
	assert_eq '${a[3]}' 'c'
	assert_eq '${a[4]}' ''

	path_split "/" a
	assert_eq '${#a[@]}' '1'
	assert_eq '${a[0]}' '/'

	path_split "/a" a
	assert_eq '${#a[@]}' '2'
	assert_eq '${a[0]}' '/'
	assert_eq '${a[1]}' 'a'

	path_split "/  a  " a
	assert_eq '${#a[@]}' '2'
	assert_eq '${a[0]}' '/'
	assert_eq '${a[1]}' '  a  '

	path_split "/a/b" a
	assert_eq '${#a[@]}' '3'
	assert_eq '${a[0]}' '/'
	assert_eq '${a[1]}' 'a'
	assert_eq '${a[2]}' 'b'

	path_split "//./b/c" a
	assert_eq '${#a[@]}' '5'
	assert_eq '${a[0]}' '/'
	assert_eq '${a[1]}' ''
	assert_eq '${a[2]}' '.'
	assert_eq '${a[3]}' 'b'
	assert_eq '${a[4]}' 'c'

	path_split "/a/..//  /" a
	assert_eq '${#a[@]}' '6'
	assert_eq '${a[0]}' '/'
	assert_eq '${a[1]}' 'a'
	assert_eq '${a[2]}' '..'
	assert_eq '${a[3]}' ''
	assert_eq '${a[4]}' '  '
	assert_eq '${a[5]}' ''
}

test_path_array_join(){
	local a
	a=()
	assert_eq '$(path_array_join a)'     ''
	a=("  ")
	assert_eq '$(path_array_join a)'     '  '
	a=("a" "b" ".." "c" "." "d")
	assert_eq '$(path_array_join a)'     'a/b/../c/./d'
	a=("/")
	assert_eq '$(path_array_join a)'     '/'
	a=("/" "  a  " ".." "  b  " "")
	assert_eq '$(path_array_join a)'     '/  a  /../  b  /'
	a=("/" "a" "b" ".." "c" "." "d" "")
	assert_eq '$(path_array_join a)'     '/a/b/../c/./d/'
}

test_path_standardize(){
	assert_eq '$(path_standardize "")'                      ''
	assert_eq '$(path_standardize ".")'                     ''
	assert_eq '$(path_standardize "./")'                    ''
	assert_eq '$(path_standardize "./a")'                   'a'
	assert_eq '$(path_standardize "./a/b/c/")'              'a/b/c'
	assert_eq '$(path_standardize "a/../b")'                'b'
	assert_eq '$(path_standardize "a/../../b")'             '../b'
	assert_eq '$(path_standardize "a/../b/../c/../d")'      'd'
	assert_eq '$(path_standardize ".././.././../")'         '../../..'
	assert_eq '$(path_standardize "/")'                     '/'
	assert_eq '$(path_standardize "/././a/./")'             '/a'
	assert_eq '$(path_standardize "/../..")'                '/'
	assert_eq '$(path_standardize "/../../a")'              '/a'
	assert_eq '$(path_standardize "/a/b/c/../d/../..")'     '/a'
}

test_path_get_relative(){
	assert_eq '$(path_get_relative "a/b" "a/b/d")'            'd'
	assert_eq '$(path_get_relative "a/b/c" "a/b/d")'          '../d'
	assert_eq '$(path_get_relative "a/b/c/d" "a/b/d/e")'      '../../d/e'
	assert_eq '$(path_get_relative "a/b/c/d/" "a/b/d/e")'     '../../d/e'
	assert_eq '$(path_get_relative "a/b/c/d" "a/b/d/e/")'     '../../d/e'
	assert_eq '$(path_get_relative "a/b/c/d/" "a/b/d/e/")'    '../../d/e'
	assert_eq '$(path_get_relative "a/b/../c" "a/c/d")'       'd'
	assert_eq '$(path_get_relative "a/b" "b/c/d")'            '../../b/c/d'
	assert_eq '$(path_get_relative "/" "/")'                  ''
	assert_eq '$(path_get_relative "/" "/a")'                 'a'
	assert_eq '$(path_get_relative "/a/b/" "/a/b/c/d")'       'c/d'
	assert_eq '$(path_get_relative "/a/b/c/d" "/e/f/g/h")'    '../../../../e/f/g/h'
}

main(){
	exec_test array_copy
	exec_test str_pos
	exec_test str_split
	exec_test array_join
	exec_test path_is_absolute
	exec_test path_append
	exec_test path_split
	exec_test path_array_join
	exec_test path_standardize
	exec_test path_get_relative
}

main
