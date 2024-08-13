STATUS_PASS="passed"
STATUS_FAIL="failed"

# DEPENDS ON THE FOLLOWING VARS SET ELSEWHERE
# RESULTS_FILE

add_test()
{
    local key
    local name
    local score
    local max_score
    local output
    local status
    local results_file

    name=""
    score=0
    max_score=0
    output=""
    use_status=false
    status_message=""
    results_file="${RESULTS_FILE:-}"

    POSITIONAL=()
    while [[ $# -gt 0 ]]; do
	key=$1
	case $key in
	    --name)
		name=$2
		shift
		shift
		;;
	    --score)
		score=$2
		shift
		shift
		;;
	    --status)
		use_status=true
		status_message="$2"
		shift
		shift
		;;
	    --max-score)
		score=$2
		shift
		shift
		;;
	    --results-file)
		results=file="$2"
		shift
		shift
		;;
	    *)
		POSITIONAL+=("$1")
		shift
	esac
    done
    set -- "${POSITIONAL[@]}"
    output="$@"

    tmp_file=$(mktemp)
    if $use_status; then
	jq --arg status "$status_message" --arg output "$output" --arg name "$name" '.tests += [{ "name": $name, "status": $status, "output": $output}]' ${results_file} > ${tmp_file} && cp ${tmp_file} ${results_file}
    else
	jq --argjson score "$score" --argjson max_score "$max_score" --arg output "$output" --arg name "$name" '.tests += [{ "name": $name, "score": $score,"max_score": $max_score, "output": $output}]' ${results_file} > ${tmp_file} && cp ${tmp_file} ${results_file}

    fi
}
