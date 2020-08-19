# helper for path completion that saves the selections from fzf in a history file
# and it outputs the name as was given as well. Works using stdin.

_fzf_history_appender() {
        local p
        while read p; do
            echo "$p"
            local realpath="$(realpath "$p")"
            if ! grep -q "$realpath" ~/.zsh-fzf-path-completion-history; then
        done
}

# create a simpler & lighter directory fzf completion
_fzf_complete_path() {
    local lbuf="$1"
    local prefix="$2"
    # Mode of operation: See anonymouse fx in .zsh/zle/fzf
    local mode="$3"
    local path_prefix
    if [[ "${prefix}" =~ "/" ]]; then
        path_prefix="${prefix%/*}/"
        prefix="${prefix##*/}"
    else
        path_prefix="./"
    fi
    # substitute ~ to $HOME in path_prefix
    path_prefix="${path_prefix/#\~/$HOME}"
    # remove \ when it is intended to quote special chars
    path_prefix="${path_prefix//\\/}"
    local query="${prefix//*\//}"
    # setting default options which may change in the following case structure
	local real_opts=("$path_prefix")
	local preview="pistol {}"
                echo "$realpath" >> ~/.zsh-fzf-path-completion-history
            fi
                echo "$realpath" >> ~/.zsh-fzf-path-completion-history
            fi
                echo "$realpath" >> ~/.zsh-fzf-path-completion-history
            fi
                echo "$realpath" >> ~/.zsh-fzf-path-completion-history
            fi
	local header
	case "$mode" in
		"directories")
			local opts=("${path_prefix}"*(-/N))
			if [ ! -z "$opts" ]; then
				real_opts+=("${opts[@]/%//}")
			fi
			header="Only Directories in Current Directory"
			;;
		"files")
			local opts=("${path_prefix}"*(N))
			local opt
			for opt in "${opts[@]}"; do
				if [[ -d "${opt}" ]] && ! [[ -h ${opt} ]]; then
					real_opts+=("${opt}/")
				else
					real_opts+=("${opt}")
				fi
			done
			header="Files and Directories in Current Directory"
			;;
		"git"*)
			if ! git rev-parse --is-inside-work-tree 2>&1 > /dev/null; then
				echo "$prefix"
				return
			fi
			if [[ "$mode" == "git-changed-files" ]]; then
				real_opts=(${(f)"$(git status --short --no-renames | sed -n -e '/^D /d' -e 's/\(??\| [MD]\|[MA] \) \(.*\)/\2/p')"})
				preview='git diff --color=always -- {} | grep . || git diff --color=always -- /dev/null {} 2>/dev/null'
				header="All Files Git Modified"
			elif [[ "$mode" == "git-all-files" ]]; then
				if [[ "$lbuf" == "cd " ]]; then
					real_opts=(${(f)"$(dirname $(git ls) | uq)"})
					header="All directories of file tracked by Git"
				else
					real_opts=(${(f)"$(git ls)"})
					header="All Files Tracked by Git"
				fi
			fi
			;;
		"history-paths")
			local nvim_view_files=(~/.local/share/nvim/view/*)
			# remove the prefixing ~/.local/share/nvim/view
			local nvim_edited_files=(${nvim_view_files[@]#${HOME}/.local/share/nvim/view/})
			# replace the '=+' characters in these strings which replace /
			nvim_edited_files=(${nvim_edited_files[@]//\=+/\/})
			# remove the trailing '=' as well
			nvim_edited_files=(${nvim_edited_files[@]%\=})
			real_opts=(${nvim_edited_files[@]//\~/${HOME}})
			# Add files from our history file
			real_opts+=(${(f)"$(< ~/.zsh-fzf-path-completion-history)"})
			header="All Files Ever Edited or Matched by fzf"
			;;
	esac
	if [ -z "$real_opts" ]; then
		echo "$prefix"
		return 0
	fi
	local matches=(${(f)"$(printf '%s\n' "${real_opts[@]}" | \
		fzf --layout=reverse \
			--header="${header}" \
			--query="${query}" \
			-m --preview="${preview}" | \
			__fzf_history-appender)"} \
	)
	if [ -z "$matches" ]; then
		echo "$prefix"
		return 0
	fi
	echo ${(@q)matches}
	return 0
}

# hsub :  a sed -e helper for any command from history
_fzf_complete_hsub() {
	local selected num
	setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
	selected=($(fc -rl 1 | fzf +m \
		--height "40%" \
		-n2..,.. \
		--tiebreak=index \
		--bind=ctrl-r:toggle-sort \
		--query="${LBUFFER}" \
	))
	local ret=$?
	if [ -n "$selected" ]; then
		num=$selected[1]
		if [ -n "$num" ]; then
			echo $num
		fi
	fi
	return $ret
}

# gopass and pass passwords
_fzf_complete_gopass() {
	local prefix="$2"
	local match="$(gopass list --flat | fzf --query="${prefix}")"
	[ -z "$match" ] && return 1
	echo "${match}"
}
_fzf_complete_pass() {
	_fzf_complete_gopass "$@"
}

# export (zsh's built-in)
_fzf_complete_export() {
	local lbuf="$1"
	local prefix="$2"
	local matches=(${(f)"$(declare -x | fzf --query="${prefix}" --preview='eval echo \${}')"})
	[ -z "$matches" ] && return 1
	echo "${matches[@]//=*/}"
}

# unset (zsh's built-in)
_fzf_complete_unset() {
	_fzf_complete_export "$@"
}

# unalias (zsh's built-in)
_fzf_complete_unalias() {
	local lbuf="$1"
	local prefix="$2"
	local aliases=(${(f)"$(alias)"})
	local matches=($(printf '%s\n' ${aliases[@]//=*/} | fzf --query="${prefix}"))
	[ -z "$matches" ] && return 1
	echo "${matches[@]//=*/}"
}

# process completion
_fzf_complete_kill() {
	local lbuf="$1"
	local prefix="$2"
	local matches=(${(f)"$(command ps -ef | sed 1d | fzf -m -q "$prefix" --reverse --preview 'echo {}' --preview-window down:3:wrap)"})
	[ -z "$matches" ] && return 1
	local match_line line_parts pids
	for match_line in ${matches[@]}; do
		line_parts=(${(s: :)match_line})
		pids+=(${line_parts[2]})
	done
	echo "${pids[@]}"
}
_fzf_complete_grepenv() {
	_fzf_complete_kill
}

# juf and jsf shell functions
_fzf_complete_journal(){
	local lbuf="$1"
	local prefix="$2"
	local mode="$3"  # string - `user` or `system`
	local systemctl_cmd
	if [[ "$mode" == "user" ]]; then
		systemctl_cmd='systemctl --user'
	else
		systemctl_cmd='systemctl'
	fi
	local unit load active sub description
	local units
	local first_iteration=1 break_larger_loop=0
	eval $systemctl_cmd list-units --plain --all | while read unit load active sub description; do
		if (($first_iteration)); then
			first_iteration=0
			continue
		fi
		for field in "$unit" "$load" "$active" "$sub" "$description"; do
			if [[ ! -z "$field" ]]; then
				units+=("$unit")
				break
			else
				if [[ "$description" == "$field" ]]; then
					break_larger_loop=1
				fi
			fi
		done
		if (($break_larger_loop)); then
			break
		fi
	done
	local matches=($(printf '%s\n' "${units[@]}" | fzf -m --query="${prefix}" --preview="$systemctl_cmd status {}"))
	[ -z "$matches" ] && return 1
	echo "${matches[@]}"
}
_fzf_complete_juf(){
	_fzf_complete_journal "$@" user
}
_fzf_complete_jsf(){
	_fzf_complete_journal "$@" system
}
# completing systemctl {start|stop|disable|enable} aliases
function (){
	local _alias
	for _alias in syu{,s,p,t}; do
		eval "_fzf_complete_$_alias() { _fzf_complete_journal \"\$@\" user; }"
	done
	for _alias in sys{,s,p,t}; do
		eval "_fzf_complete_$_alias() { _fzf_complete_journal \"\$@\" system; }"
	done
}

# man pages
_fzf_complete_man(){
	local lbuf="$1"
	local prefix="$2"
	local name section dash description
	local matches=($(man -k . | fzf -m --query="${prefix}" | while read -r name section dash description; do
		echo "-s${${section#\(}%\)} $name"
	done))
	[ -z "$matches" ] && return 1
	echo "${matches[@]}"
}
# taskwarrior
_fzf_complete_task(){
	local lbuf="$1"
	local prefix="$2"
	if [[ "$prefix" =~ "^[-+]" ]]; then
		# complete tags
		local matches=($(command task _tags | fzf -m --query="${${prefix#+}#-}"))
		[ -z "$matches" ] && return 1
		local common_prefix="${prefix//[^-+]*/}"
		echo "${matches[@]/#/${common_prefix}}"
	elif [[ "$prefix" =~ "^project:" ]]; then
		# complete project
		local match=$(command task _project | fzf --query="${prefix#project:}")
		[ -z "$match" ] && return 1
		local common_prefix="project:"
		echo "${match/#/${common_prefix}}"
	else
		# complete task
		local matches=(${(f)"$(command task _zshids | fzf -m --query="${prefix}")"})
		[ -z "$matches" ] && return 1
		echo "${matches[@]//:*/}"
	fi
}
_fzf_complete_t(){
	_fzf_complete_task "$@"
}
# sms
_fzf_complete_sms(){
	local lbuf="$1"
	local prefix="$2"
	local phone_number phone_type
	local match=$(command khard phone --parsable | fzf --query="${prefix}" | while IFS=$'\t' read phone_number contact_name phone_type; do
		echo $phone_number
	done)
	echo "$match"
}
# vim:ft=zsh
}
