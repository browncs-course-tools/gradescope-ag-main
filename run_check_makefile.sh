#!/bin/bash
#
# run_check_makefile.sh - Run a student's makefile and check for some expected binaries
#
# See main() for an explanation of arguments
#

set -euo pipefail
#set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

REPO_ROOT="${SCRIPT_DIR}"

RESULTS_TEMPLATE="${REPO_ROOT}/results_template.json"

# Set by args
RESULTS_FILE=""

source ${REPO_ROOT}/common.sh # This file requires RESULTS_FILE to be set

check_file()
{
    log="$1"
    target="$2"
    name="Binary check: $(basename "${target}")"

    if [[ -e "${target}" ]]; then
	add_test --name "${name}" --status ${STATUS_PASS} "Found target binary ${target}"
	echo "Found target binary ${target}" >> $log
	echo 1
    else
	add_test --name "${name}" --status ${STATUS_FAIL} "Did not find target binary ${target}"
	echo "Did not find binary ${target}" >> $log
	echo 0
    fi
}

do_compile()
{
    local used_makefile
    local work_dir
    local test_name

    used_makefile=0
    test_name="Files/compilation check"
    build_log=$(mktemp)
    bins=$@

    echo "****************** COMPILATION **********************"
    if [[ -e Makefile || -e makefile ]]; then
	used_makefile=1
	echo "Found makefile, executing"

	# Try to clean first (if target exists)
	rm -fv $bins
	make -q clean && rv=$?
	if [[ $rv != 2 ]]; then
	    (make clean | tee $build_log) || true
	fi

	# Now try to build
	echo "Exceuting make ..."
	rv=0
	(make 2>&1 | tee -a $build_log) || rv=$?
	echo "make exited with status ${rv}" >> $build_log
    else
	# Abort if no makefile found
	# (Optionally, remove this to also allow submissions in interpreted languages)
	add_test --name "${test_name}"  --score 0 --max-score 0 "No makefile found!  Aborting"
	exit 1

    fi

    echo "****************** BINARY CHECK **********************"
    ok=1

    for bin in $bins; do
	found=$(check_file $build_log "$bin" || true)
	if [[ $found == 0 ]]; then
	    ok = 0
	fi
    done

    if [[ $ok == 0 ]]; then
	if [[ $used_makefile == 1 ]]; then
	    add_test --name "${test_name}" --score 0 --max-score 0 "Missing one of required binaries: $bins\n  Here is the output of the compilation process:  \n\n$(cat ${build_log})"
	else
	    add_test --name "${test_name}" --score 0 --max-score 0 "Missing one of required scripts: $bins\n  Here is the autograder log:  \n\n$(cat ${build_log})"
	fi
    else
	echo "Compilation/files check passed!"
	add_test --name "${test_name}" --status ${STATUS_PASS}
    fi

}


main()
{
    rv=0
    submission=""   # Path to student submission
    run_command=""  # Optional subcommand to select assignment
    results_file="" # JSON results file for Gradescope
    work_path="."   # Optional subdirectory in student submission dir

    POSITIONAL=()
    while [[ $# -gt 0 ]]; do
	key=$1
	case $key in
	    --submission)
		submission="$2"
		shift
		shift
		;;
	    --command)
		run_command="$2"
		shift
		shift
		;;
	    --results-file)
		results_file="$2"
		shift
		shift
		;;
	    --work-path)
		work_path="$2"
		shift
		shift
		;;
	    *)
		POSITIONAL+=("$1")
		shift
	esac
    done
    set -- "${POSITIONAL[@]}"
    expected_binaries=$@

    RESULTS_FILE=${results_file} # Set global for use by other scripts

    echo 'Last executed: '
    TZ=America/New_York date

    src_dir=$(realpath ${submission}/${work_path})

    # Create results template
    rm -fv ${results_file}
    cp -v ${RESULTS_TEMPLATE} ${results_file}

    if [[ ! -e ${src_dir} ]]; then
	add_test --name "Files check" --status ${STATUS_FAIL} "Could not locate assignment directory ./$($w{ork_dir})"
	exit 1
    fi

    pushd ${src_dir} > /dev/null

    # Try to build the project
    do_compile $expected_binaries

    # #### Could also do other work here (eg. run tests, etc.) #####

    # Check readme
    readme_matches="$(find ${src_dir} -mindepth 1 -maxdepth 1 \
	    			   		  -iname README -or -iname README.txt -or -iname README.md || true)"

    if [[ -z "${readme_matches}" ]] ; then
	add_test --name "README check" --status ${STATUS_FAIL} "Warning:  Possible missing readme:  did not find readme with names README, README.txt, or README.md"
    else
	add_test --name "README check" --status ${STATUS_PASS} "Found README"
    fi

    popd > /dev/null
}


main $@
