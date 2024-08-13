#!/usr/bin/env bash

set -euo pipefail
#set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
AG_ROOT=$(realpath "${SCRIPT_DIR}/..")
AG_SOURCE="${SCRIPT_DIR}"

export CARGO_HOME=/opt/rust
export RUSTUP_HOME=/opt/rust
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/opt/rust/bin


#source ${AG_SOURCE}/globals.sh

source ${AG_SOURCE}/common.sh

main()
{
    submission=""
    command=""
    results_file=""

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
		command="$2"
		shift
		shift
		;;
	    --results-file)
		results_file="$2"
		shift
		shift
		;;
	    *)
		POSITIONAL+=("$1")
		shift
	esac
    done
    set -- "${POSITIONAL[@]}"


    case $command in
	proj1)
	    echo "This is where you could run autograder for ${command}"
	    echo "Instead, this example will create a generic result file as an"
	    echo "example for adding Gradescope results from a bash script, if you need it"
	    cp -v ${AG_SOURCE}/results_template.json ${results_file}

	    add_test --results-file ${results_file} \
		     --name "Example status check" \
		     --status ${STATUS_PASS} \
		     "This is a test without a point value, used for pass/fail checks"

	    add_test --results-file ${results_file} \
		     --name "Example test" \
		     --score 1 --max-score 1 \
		     "This is another example test"
	    ;;
	proj2)
	    # Example makefile-based project
	    # This one just runs a script designed for
	    ${AG_SOURCE}/run_check_makefile.sh \
			--command $command \
			--submission ${submission} \
			--results-file ${results_file} \
		expected_proj_binary || true

	    ${AG_SOURCE}/proj1/autograde.py \
			--results-file ${results_file} \
			${submission}
	    ;;
	passwords)
	    chmod +x ${submission}/passwords/create_database
	    chmod +x ${submission}/passwords/login
	    chmod +x ${submission}/passwords/pwfind
	    chmod +x ${submission}/passwords/check_login

	    ${AG_SOURCE}/autograde.sh \
			--submission ${submission} \
			--results-file ${results_file} \
			--work-path "passwords" \
			login pwfind
	    ${AG_SOURCE}/passwords/passwords_autograder.sh \
			--results-file ${results_file} \
			--submission ${submission}/passwords
	    ;;
	*)
	    echo "Unrecognized command $command"
	    exit 1
	    ;;
    esac


}


main $@
