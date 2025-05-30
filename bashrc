#PS1='[\u@\h \W]\$ '

# ssh agent alias added
alias ssha='eval $(ssh-agent) && ssh-add'

# Git branch in prompt.
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Proper PS1 with color codes enclosed in non-printing character delimiters
export PS1="\[\e[38;5;47m\]\u\[\e[0m\]\[\e[38;5;156m\]@\[\e[0m\]\[\e[38;5;227m\]\h \[\e[0m\]\[\e[38;5;231m\]\w \[\e[0m\]$(parse_git_branch)\$ "

force_color_prompt=yes

EDITOR=vim

#export PATH="$HOME/.pyenv/bin:$PATH"
#eval "$(pyenv init --path)"
#eval "$(pyenv virtualenv-init -)"


alias cp="cp -i"
alias df="df -h"
alias free="free -m"
alias more="less"
alias uu="apt update -y && apt dist-upgrade -y"
alias uc="yum update -y"
alias ua="pacman -Syu"
alias pacmansearch="pkgfile"
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alFrt --color'
alias la='ls -A'
alias l='ls -CF'
alias treeacl='tree -A -C -L 2'
alias cl='clear'
alias ..='cd ..'
alias ...='cd ..;cd ..'
alias ip='ip -c'
alias mtr='mtr --order "LDRS NBAW JMXI" --ipinfo 1 --show-ips'
alias k='kubectl'
alias ta='tmux attach'
alias tm='tmux'

#date
#curl wttr.in/?0
#
#if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
#    tmux attach -t default || tmux new -s default
#fi

# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
} 

export GPG_TTY=$(tty)

# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# bash completion V2 for kubectl                              -*- shell-script -*-

__kubectl_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE-} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Macs have bash3 for which the bash-completion package doesn't include
# _init_completion. This is a minimal version of that function.
__kubectl_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

# This function calls the kubectl program to obtain the completion
# results and the directive.  It fills the 'out' and 'directive' vars.
__kubectl_get_completion_results() {
    local requestComp lastParam lastChar args

    # Prepare the command to request completions for the program.
    # Calling ${words[0]} instead of directly kubectl allows to handle aliases
    args=("${words[@]:1}")
    requestComp="${words[0]} __complete ${args[*]}"

    lastParam=${words[$((${#words[@]}-1))]}
    lastChar=${lastParam:$((${#lastParam}-1)):1}
    __kubectl_debug "lastParam ${lastParam}, lastChar ${lastChar}"

    if [[ -z ${cur} && ${lastChar} != = ]]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __kubectl_debug "Adding extra empty parameter"
        requestComp="${requestComp} ''"
    fi

    # When completing a flag with an = (e.g., kubectl -n=<TAB>)
    # bash focuses on the part after the =, so we need to remove
    # the flag part from $cur
    if [[ ${cur} == -*=* ]]; then
        cur="${cur#*=}"
    fi

    __kubectl_debug "Calling ${requestComp}"
    # Use eval to handle any environment variables and such
    out=$(eval "${requestComp}" 2>/dev/null)

    # Extract the directive integer at the very end of the output following a colon (:)
    directive=${out##*:}
    # Remove the directive
    out=${out%:*}
    if [[ ${directive} == "${out}" ]]; then
        # There is not directive specified
        directive=0
    fi
    __kubectl_debug "The completion directive is: ${directive}"
    __kubectl_debug "The completions are: ${out}"
}

__kubectl_process_completion_results() {
    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16
    local shellCompDirectiveKeepOrder=32

    if (((directive & shellCompDirectiveError) != 0)); then
        # Error code.  No completion.
        __kubectl_debug "Received error from custom completion go code"
        return
    else
        if (((directive & shellCompDirectiveNoSpace) != 0)); then
            if [[ $(type -t compopt) == builtin ]]; then
                __kubectl_debug "Activating no space"
                compopt -o nospace
            else
                __kubectl_debug "No space directive not supported in this version of bash"
            fi
        fi
        if (((directive & shellCompDirectiveKeepOrder) != 0)); then
            if [[ $(type -t compopt) == builtin ]]; then
                # no sort isn't supported for bash less than < 4.4
                if [[ ${BASH_VERSINFO[0]} -lt 4 || ( ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -lt 4 ) ]]; then
                    __kubectl_debug "No sort directive not supported in this version of bash"
                else
                    __kubectl_debug "Activating keep order"
                    compopt -o nosort
                fi
            else
                __kubectl_debug "No sort directive not supported in this version of bash"
            fi
        fi
        if (((directive & shellCompDirectiveNoFileComp) != 0)); then
            if [[ $(type -t compopt) == builtin ]]; then
                __kubectl_debug "Activating no file completion"
                compopt +o default
            else
                __kubectl_debug "No file completion directive not supported in this version of bash"
            fi
        fi
    fi

    # Separate activeHelp from normal completions
    local completions=()
    local activeHelp=()
    __kubectl_extract_activeHelp

    if (((directive & shellCompDirectiveFilterFileExt) != 0)); then
        # File extension filtering
        local fullFilter filter filteringCmd

        # Do not use quotes around the $completions variable or else newline
        # characters will be kept.
        for filter in ${completions[*]}; do
            fullFilter+="$filter|"
        done

        filteringCmd="_filedir $fullFilter"
        __kubectl_debug "File filtering command: $filteringCmd"
        $filteringCmd
    elif (((directive & shellCompDirectiveFilterDirs) != 0)); then
        # File completion for directories only

        local subdir
        subdir=${completions[0]}
        if [[ -n $subdir ]]; then
            __kubectl_debug "Listing directories in $subdir"
            pushd "$subdir" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1 || return
        else
            __kubectl_debug "Listing directories in ."
            _filedir -d
        fi
    else
        __kubectl_handle_completion_types
    fi

    __kubectl_handle_special_char "$cur" :
    __kubectl_handle_special_char "$cur" =

    # Print the activeHelp statements before we finish
    if ((${#activeHelp[*]} != 0)); then
        printf "\n";
        printf "%s\n" "${activeHelp[@]}"
        printf "\n"

        # The prompt format is only available from bash 4.4.
        # We test if it is available before using it.
        if (x=${PS1@P}) 2> /dev/null; then
            printf "%s" "${PS1@P}${COMP_LINE[@]}"
        else
            # Can't print the prompt.  Just print the
            # text the user had typed, it is workable enough.
            printf "%s" "${COMP_LINE[@]}"
        fi
    fi
}

# Separate activeHelp lines from real completions.
# Fills the $activeHelp and $completions arrays.
__kubectl_extract_activeHelp() {
    local activeHelpMarker="_activeHelp_ "
    local endIndex=${#activeHelpMarker}

    while IFS='' read -r comp; do
        if [[ ${comp:0:endIndex} == $activeHelpMarker ]]; then
            comp=${comp:endIndex}
            __kubectl_debug "ActiveHelp found: $comp"
            if [[ -n $comp ]]; then
                activeHelp+=("$comp")
            fi
        else
            # Not an activeHelp line but a normal completion
            completions+=("$comp")
        fi
    done <<<"${out}"
}

__kubectl_handle_completion_types() {
    __kubectl_debug "__kubectl_handle_completion_types: COMP_TYPE is $COMP_TYPE"

    case $COMP_TYPE in
    37|42)
        # Type: menu-complete/menu-complete-backward and insert-completions
        # If the user requested inserting one completion at a time, or all
        # completions at once on the command-line we must remove the descriptions.
        # https://github.com/spf13/cobra/issues/1508
        local tab=$'\t' comp
        while IFS='' read -r comp; do
            [[ -z $comp ]] && continue
            # Strip any description
            comp=${comp%%$tab*}
            # Only consider the completions that match
            if [[ $comp == "$cur"* ]]; then
                COMPREPLY+=("$comp")
            fi
        done < <(printf "%s\n" "${completions[@]}")
        ;;

    *)
        # Type: complete (normal completion)
        __kubectl_handle_standard_completion_case
        ;;
    esac
}

__kubectl_handle_standard_completion_case() {
    local tab=$'\t' comp

    # Short circuit to optimize if we don't have descriptions
    if [[ "${completions[*]}" != *$tab* ]]; then
        IFS=$'\n' read -ra COMPREPLY -d '' < <(compgen -W "${completions[*]}" -- "$cur")
        return 0
    fi

    local longest=0
    local compline
    # Look for the longest completion so that we can format things nicely
    while IFS='' read -r compline; do
        [[ -z $compline ]] && continue
        # Strip any description before checking the length
        comp=${compline%%$tab*}
        # Only consider the completions that match
        [[ $comp == "$cur"* ]] || continue
        COMPREPLY+=("$compline")
        if ((${#comp}>longest)); then
            longest=${#comp}
        fi
    done < <(printf "%s\n" "${completions[@]}")

    # If there is a single completion left, remove the description text
    if ((${#COMPREPLY[*]} == 1)); then
        __kubectl_debug "COMPREPLY[0]: ${COMPREPLY[0]}"
        comp="${COMPREPLY[0]%%$tab*}"
        __kubectl_debug "Removed description from single completion, which is now: ${comp}"
        COMPREPLY[0]=$comp
    else # Format the descriptions
        __kubectl_format_comp_descriptions $longest
    fi
}

__kubectl_handle_special_char()
{
    local comp="$1"
    local char=$2
    if [[ "$comp" == *${char}* && "$COMP_WORDBREAKS" == *${char}* ]]; then
        local word=${comp%"${comp##*${char}}"}
        local idx=${#COMPREPLY[*]}
        while ((--idx >= 0)); do
            COMPREPLY[idx]=${COMPREPLY[idx]#"$word"}
        done
    fi
}

__kubectl_format_comp_descriptions()
{
    local tab=$'\t'
    local comp desc maxdesclength
    local longest=$1

    local i ci
    for ci in ${!COMPREPLY[*]}; do
        comp=${COMPREPLY[ci]}
        # Properly format the description string which follows a tab character if there is one
        if [[ "$comp" == *$tab* ]]; then
            __kubectl_debug "Original comp: $comp"
            desc=${comp#*$tab}
            comp=${comp%%$tab*}

            # $COLUMNS stores the current shell width.
            # Remove an extra 4 because we add 2 spaces and 2 parentheses.
            maxdesclength=$(( COLUMNS - longest - 4 ))

            # Make sure we can fit a description of at least 8 characters
            # if we are to align the descriptions.
            if ((maxdesclength > 8)); then
                # Add the proper number of spaces to align the descriptions
                for ((i = ${#comp} ; i < longest ; i++)); do
                    comp+=" "
                done
            else
                # Don't pad the descriptions so we can fit more text after the completion
                maxdesclength=$(( COLUMNS - ${#comp} - 4 ))
            fi

            # If there is enough space for any description text,
            # truncate the descriptions that are too long for the shell width
            if ((maxdesclength > 0)); then
                if ((${#desc} > maxdesclength)); then
                    desc=${desc:0:$(( maxdesclength - 1 ))}
                    desc+="…"
                fi
                comp+="  ($desc)"
            fi
            COMPREPLY[ci]=$comp
            __kubectl_debug "Final comp: $comp"
        fi
    done
}

__start_kubectl()
{
    local cur prev words cword split

    COMPREPLY=()

    # Call _init_completion from the bash-completion package
    # to prepare the arguments properly
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -n =: || return
    else
        __kubectl_init_completion -n =: || return
    fi

    __kubectl_debug
    __kubectl_debug "========= starting completion logic =========="
    __kubectl_debug "cur is ${cur}, words[*] is ${words[*]}, #words[@] is ${#words[@]}, cword is $cword"

    # The user could have moved the cursor backwards on the command-line.
    # We need to trigger completion from the $cword location, so we need
    # to truncate the command-line ($words) up to the $cword location.
    words=("${words[@]:0:$cword+1}")
    __kubectl_debug "Truncated words[*]: ${words[*]},"

    local out directive
    __kubectl_get_completion_results
    __kubectl_process_completion_results
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_kubectl kubectl
else
    complete -o default -o nospace -F __start_kubectl kubectl
fi

# ex: ts=4 sw=4 et filetype=sh

# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# bash completion for kubeadm                              -*- shell-script -*-

__kubeadm_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE:-} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__kubeadm_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__kubeadm_index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__kubeadm_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__kubeadm_handle_go_custom_completion()
{
    __kubeadm_debug "${FUNCNAME[0]}: cur is ${cur}, words[*] is ${words[*]}, #words[@] is ${#words[@]}"

    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16

    local out requestComp lastParam lastChar comp directive args

    # Prepare the command to request completions for the program.
    # Calling ${words[0]} instead of directly kubeadm allows to handle aliases
    args=("${words[@]:1}")
    # Disable ActiveHelp which is not supported for bash completion v1
    requestComp="KUBEADM_ACTIVE_HELP=0 ${words[0]} __completeNoDesc ${args[*]}"

    lastParam=${words[$((${#words[@]}-1))]}
    lastChar=${lastParam:$((${#lastParam}-1)):1}
    __kubeadm_debug "${FUNCNAME[0]}: lastParam ${lastParam}, lastChar ${lastChar}"

    if [ -z "${cur}" ] && [ "${lastChar}" != "=" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __kubeadm_debug "${FUNCNAME[0]}: Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __kubeadm_debug "${FUNCNAME[0]}: calling ${requestComp}"
    # Use eval to handle any environment variables and such
    out=$(eval "${requestComp}" 2>/dev/null)

    # Extract the directive integer at the very end of the output following a colon (:)
    directive=${out##*:}
    # Remove the directive
    out=${out%:*}
    if [ "${directive}" = "${out}" ]; then
        # There is not directive specified
        directive=0
    fi
    __kubeadm_debug "${FUNCNAME[0]}: the completion directive is: ${directive}"
    __kubeadm_debug "${FUNCNAME[0]}: the completions are: ${out}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        # Error code.  No completion.
        __kubeadm_debug "${FUNCNAME[0]}: received error from custom completion go code"
        return
    else
        if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __kubeadm_debug "${FUNCNAME[0]}: activating no space"
                compopt -o nospace
            fi
        fi
        if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __kubeadm_debug "${FUNCNAME[0]}: activating no file completion"
                compopt +o default
            fi
        fi
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local fullFilter filter filteringCmd
        # Do not use quotes around the $out variable or else newline
        # characters will be kept.
        for filter in ${out}; do
            fullFilter+="$filter|"
        done

        filteringCmd="_filedir $fullFilter"
        __kubeadm_debug "File filtering command: $filteringCmd"
        $filteringCmd
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subdir
        # Use printf to strip any trailing newline
        subdir=$(printf "%s" "${out}")
        if [ -n "$subdir" ]; then
            __kubeadm_debug "Listing directories in $subdir"
            __kubeadm_handle_subdirs_in_dir_flag "$subdir"
        else
            __kubeadm_debug "Listing directories in ."
            _filedir -d
        fi
    else
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${out}" -- "$cur")
    fi
}

__kubeadm_handle_reply()
{
    __kubeadm_debug "${FUNCNAME[0]}"
    local comp
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            while IFS='' read -r comp; do
                COMPREPLY+=("$comp")
            done < <(compgen -W "${allflags[*]}" -- "$cur")
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%=*}"
                __kubeadm_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION:-}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi

            if [[ -z "${flag_parsing_disabled}" ]]; then
                # If flag parsing is enabled, we have completed the flags and can return.
                # If flag parsing is disabled, we may not know all (or any) of the flags, so we fallthrough
                # to possibly call handle_go_custom_completion.
                return 0;
            fi
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __kubeadm_index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions+=("${must_have_one_noun[@]}")
    elif [[ -n "${has_completion_function}" ]]; then
        # if a go completion function is provided, defer to that function
        __kubeadm_handle_go_custom_completion
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    while IFS='' read -r comp; do
        COMPREPLY+=("$comp")
    done < <(compgen -W "${completions[*]}" -- "$cur")

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${noun_aliases[*]}" -- "$cur")
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        if declare -F __kubeadm_custom_func >/dev/null; then
            # try command name qualified custom func
            __kubeadm_custom_func
        else
            # otherwise fall back to unqualified for compatibility
            declare -F __custom_func >/dev/null && __custom_func
        fi
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi

    # If there is only 1 completion and it is a flag with an = it will be completed
    # but we don't want a space after the =
    if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
       compopt -o nospace
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__kubeadm_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__kubeadm_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1 || return
}

__kubeadm_handle_flag()
{
    __kubeadm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue=""
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __kubeadm_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __kubeadm_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __kubeadm_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __kubeadm_contains_word "${words[c]}" "${two_word_flags[@]}"; then
        __kubeadm_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__kubeadm_handle_noun()
{
    __kubeadm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __kubeadm_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __kubeadm_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__kubeadm_handle_command()
{
    __kubeadm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_kubeadm_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __kubeadm_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__kubeadm_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __kubeadm_handle_reply
        return
    fi
    __kubeadm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __kubeadm_handle_flag
    elif __kubeadm_contains_word "${words[c]}" "${commands[@]}"; then
        __kubeadm_handle_command
    elif [[ $c -eq 0 ]]; then
        __kubeadm_handle_command
    elif __kubeadm_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __kubeadm_handle_command
        else
            __kubeadm_handle_noun
        fi
    else
        __kubeadm_handle_noun
    fi
    __kubeadm_handle_word
}

_kubeadm_certs_certificate-key()
{
    last_command="kubeadm_certs_certificate-key"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_check-expiration()
{
    last_command="kubeadm_certs_check-expiration"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--allow-missing-template-keys")
    local_nonpersistent_flags+=("--allow-missing-template-keys")
    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--experimental-output=")
    two_word_flags+=("--experimental-output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--experimental-output")
    local_nonpersistent_flags+=("--experimental-output=")
    local_nonpersistent_flags+=("-o")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--show-managed-fields")
    local_nonpersistent_flags+=("--show-managed-fields")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_generate-csr()
{
    last_command="kubeadm_certs_generate-csr"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--kubeconfig-dir=")
    two_word_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_renew_admin.conf()
{
    last_command="kubeadm_certs_renew_admin.conf"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_renew_all()
{
    last_command="kubeadm_certs_renew_all"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_renew_apiserver()
{
    last_command="kubeadm_certs_renew_apiserver"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_renew_apiserver-etcd-client()
{
    last_command="kubeadm_certs_renew_apiserver-etcd-client"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_renew_apiserver-kubelet-client()
{
    last_command="kubeadm_certs_renew_apiserver-kubelet-client"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_renew_controller-manager.conf()
{
    last_command="kubeadm_certs_renew_controller-manager.conf"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_renew_etcd-healthcheck-client()
{
    last_command="kubeadm_certs_renew_etcd-healthcheck-client"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_renew_etcd-peer()
{
    last_command="kubeadm_certs_renew_etcd-peer"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_renew_etcd-server()
{
    last_command="kubeadm_certs_renew_etcd-server"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_renew_front-proxy-client()
{
    last_command="kubeadm_certs_renew_front-proxy-client"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_renew_scheduler.conf()
{
    last_command="kubeadm_certs_renew_scheduler.conf"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_renew_super-admin.conf()
{
    last_command="kubeadm_certs_renew_super-admin.conf"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs_renew()
{
    last_command="kubeadm_certs_renew"

    command_aliases=()

    commands=()
    commands+=("admin.conf")
    commands+=("all")
    commands+=("apiserver")
    commands+=("apiserver-etcd-client")
    commands+=("apiserver-kubelet-client")
    commands+=("controller-manager.conf")
    commands+=("etcd-healthcheck-client")
    commands+=("etcd-peer")
    commands+=("etcd-server")
    commands+=("front-proxy-client")
    commands+=("scheduler.conf")
    commands+=("super-admin.conf")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_certs()
{
    last_command="kubeadm_certs"

    command_aliases=()

    commands=()
    commands+=("certificate-key")
    commands+=("check-expiration")
    commands+=("generate-csr")
    commands+=("renew")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_completion()
{
    last_command="kubeadm_completion"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    local_nonpersistent_flags+=("-h")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    must_have_one_noun+=("bash")
    must_have_one_noun+=("zsh")
    noun_aliases=()
}

_kubeadm_config_images_list()
{
    last_command="kubeadm_config_images_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--allow-missing-template-keys")
    local_nonpersistent_flags+=("--allow-missing-template-keys")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--experimental-output=")
    two_word_flags+=("--experimental-output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--experimental-output")
    local_nonpersistent_flags+=("--experimental-output=")
    local_nonpersistent_flags+=("-o")
    flags+=("--feature-gates=")
    two_word_flags+=("--feature-gates")
    flags+=("--image-repository=")
    two_word_flags+=("--image-repository")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    flags+=("--show-managed-fields")
    local_nonpersistent_flags+=("--show-managed-fields")
    flags+=("--add-dir-header")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_config_images_pull()
{
    last_command="kubeadm_config_images_pull"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--cri-socket=")
    two_word_flags+=("--cri-socket")
    flags+=("--feature-gates=")
    two_word_flags+=("--feature-gates")
    flags+=("--image-repository=")
    two_word_flags+=("--image-repository")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    flags+=("--add-dir-header")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_config_images()
{
    last_command="kubeadm_config_images"

    command_aliases=()

    commands=()
    commands+=("list")
    commands+=("pull")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_config_migrate()
{
    last_command="kubeadm_config_migrate"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--allow-experimental-api")
    local_nonpersistent_flags+=("--allow-experimental-api")
    flags+=("--new-config=")
    two_word_flags+=("--new-config")
    local_nonpersistent_flags+=("--new-config")
    local_nonpersistent_flags+=("--new-config=")
    flags+=("--old-config=")
    two_word_flags+=("--old-config")
    local_nonpersistent_flags+=("--old-config")
    local_nonpersistent_flags+=("--old-config=")
    flags+=("--add-dir-header")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_config_print_init-defaults()
{
    last_command="kubeadm_config_print_init-defaults"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--component-configs=")
    two_word_flags+=("--component-configs")
    local_nonpersistent_flags+=("--component-configs")
    local_nonpersistent_flags+=("--component-configs=")
    flags+=("--add-dir-header")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_config_print_join-defaults()
{
    last_command="kubeadm_config_print_join-defaults"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_config_print_reset-defaults()
{
    last_command="kubeadm_config_print_reset-defaults"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_config_print()
{
    last_command="kubeadm_config_print"

    command_aliases=()

    commands=()
    commands+=("init-defaults")
    commands+=("join-defaults")
    commands+=("reset-defaults")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_config_validate()
{
    last_command="kubeadm_config_validate"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--allow-experimental-api")
    local_nonpersistent_flags+=("--allow-experimental-api")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--add-dir-header")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_config()
{
    last_command="kubeadm_config"

    command_aliases=()

    commands=()
    commands+=("images")
    commands+=("migrate")
    commands+=("print")
    commands+=("validate")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_help()
{
    last_command="kubeadm_help"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_kubeadm_init_phase_addon_all()
{
    last_command="kubeadm_init_phase_addon_all"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane-endpoint=")
    two_word_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--feature-gates=")
    two_word_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates=")
    flags+=("--image-repository=")
    two_word_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--pod-network-cidr=")
    two_word_flags+=("--pod-network-cidr")
    local_nonpersistent_flags+=("--pod-network-cidr")
    local_nonpersistent_flags+=("--pod-network-cidr=")
    flags+=("--service-cidr=")
    two_word_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr=")
    flags+=("--service-dns-domain=")
    two_word_flags+=("--service-dns-domain")
    local_nonpersistent_flags+=("--service-dns-domain")
    local_nonpersistent_flags+=("--service-dns-domain=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_addon_coredns()
{
    last_command="kubeadm_init_phase_addon_coredns"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--feature-gates=")
    two_word_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates=")
    flags+=("--image-repository=")
    two_word_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--print-manifest")
    local_nonpersistent_flags+=("--print-manifest")
    flags+=("--service-cidr=")
    two_word_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr=")
    flags+=("--service-dns-domain=")
    two_word_flags+=("--service-dns-domain")
    local_nonpersistent_flags+=("--service-dns-domain")
    local_nonpersistent_flags+=("--service-dns-domain=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_addon_kube-proxy()
{
    last_command="kubeadm_init_phase_addon_kube-proxy"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane-endpoint=")
    two_word_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--image-repository=")
    two_word_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--pod-network-cidr=")
    two_word_flags+=("--pod-network-cidr")
    local_nonpersistent_flags+=("--pod-network-cidr")
    local_nonpersistent_flags+=("--pod-network-cidr=")
    flags+=("--print-manifest")
    local_nonpersistent_flags+=("--print-manifest")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_addon()
{
    last_command="kubeadm_init_phase_addon"

    command_aliases=()

    commands=()
    commands+=("all")
    commands+=("coredns")
    commands+=("kube-proxy")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_bootstrap-token()
{
    last_command="kubeadm_init_phase_bootstrap-token"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--skip-token-print")
    local_nonpersistent_flags+=("--skip-token-print")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_certs_all()
{
    last_command="kubeadm_init_phase_certs_all"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-cert-extra-sans=")
    two_word_flags+=("--apiserver-cert-extra-sans")
    local_nonpersistent_flags+=("--apiserver-cert-extra-sans")
    local_nonpersistent_flags+=("--apiserver-cert-extra-sans=")
    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane-endpoint=")
    two_word_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--service-cidr=")
    two_word_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr=")
    flags+=("--service-dns-domain=")
    two_word_flags+=("--service-dns-domain")
    local_nonpersistent_flags+=("--service-dns-domain")
    local_nonpersistent_flags+=("--service-dns-domain=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_certs_apiserver()
{
    last_command="kubeadm_init_phase_certs_apiserver"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-cert-extra-sans=")
    two_word_flags+=("--apiserver-cert-extra-sans")
    local_nonpersistent_flags+=("--apiserver-cert-extra-sans")
    local_nonpersistent_flags+=("--apiserver-cert-extra-sans=")
    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane-endpoint=")
    two_word_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--service-cidr=")
    two_word_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr=")
    flags+=("--service-dns-domain=")
    two_word_flags+=("--service-dns-domain")
    local_nonpersistent_flags+=("--service-dns-domain")
    local_nonpersistent_flags+=("--service-dns-domain=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_certs_apiserver-etcd-client()
{
    last_command="kubeadm_init_phase_certs_apiserver-etcd-client"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_certs_apiserver-kubelet-client()
{
    last_command="kubeadm_init_phase_certs_apiserver-kubelet-client"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_certs_ca()
{
    last_command="kubeadm_init_phase_certs_ca"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_certs_etcd-ca()
{
    last_command="kubeadm_init_phase_certs_etcd-ca"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_certs_etcd-healthcheck-client()
{
    last_command="kubeadm_init_phase_certs_etcd-healthcheck-client"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_certs_etcd-peer()
{
    last_command="kubeadm_init_phase_certs_etcd-peer"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_certs_etcd-server()
{
    last_command="kubeadm_init_phase_certs_etcd-server"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_certs_front-proxy-ca()
{
    last_command="kubeadm_init_phase_certs_front-proxy-ca"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_certs_front-proxy-client()
{
    last_command="kubeadm_init_phase_certs_front-proxy-client"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_certs_sa()
{
    last_command="kubeadm_init_phase_certs_sa"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_certs()
{
    last_command="kubeadm_init_phase_certs"

    command_aliases=()

    commands=()
    commands+=("all")
    commands+=("apiserver")
    commands+=("apiserver-etcd-client")
    commands+=("apiserver-kubelet-client")
    commands+=("ca")
    commands+=("etcd-ca")
    commands+=("etcd-healthcheck-client")
    commands+=("etcd-peer")
    commands+=("etcd-server")
    commands+=("front-proxy-ca")
    commands+=("front-proxy-client")
    commands+=("sa")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_control-plane_all()
{
    last_command="kubeadm_init_phase_control-plane_all"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--apiserver-extra-args=")
    two_word_flags+=("--apiserver-extra-args")
    local_nonpersistent_flags+=("--apiserver-extra-args")
    local_nonpersistent_flags+=("--apiserver-extra-args=")
    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane-endpoint=")
    two_word_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint=")
    flags+=("--controller-manager-extra-args=")
    two_word_flags+=("--controller-manager-extra-args")
    local_nonpersistent_flags+=("--controller-manager-extra-args")
    local_nonpersistent_flags+=("--controller-manager-extra-args=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--feature-gates=")
    two_word_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates=")
    flags+=("--image-repository=")
    two_word_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--pod-network-cidr=")
    two_word_flags+=("--pod-network-cidr")
    local_nonpersistent_flags+=("--pod-network-cidr")
    local_nonpersistent_flags+=("--pod-network-cidr=")
    flags+=("--scheduler-extra-args=")
    two_word_flags+=("--scheduler-extra-args")
    local_nonpersistent_flags+=("--scheduler-extra-args")
    local_nonpersistent_flags+=("--scheduler-extra-args=")
    flags+=("--service-cidr=")
    two_word_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_control-plane_apiserver()
{
    last_command="kubeadm_init_phase_control-plane_apiserver"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--apiserver-extra-args=")
    two_word_flags+=("--apiserver-extra-args")
    local_nonpersistent_flags+=("--apiserver-extra-args")
    local_nonpersistent_flags+=("--apiserver-extra-args=")
    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane-endpoint=")
    two_word_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--feature-gates=")
    two_word_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates=")
    flags+=("--image-repository=")
    two_word_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--service-cidr=")
    two_word_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_control-plane_controller-manager()
{
    last_command="kubeadm_init_phase_control-plane_controller-manager"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--controller-manager-extra-args=")
    two_word_flags+=("--controller-manager-extra-args")
    local_nonpersistent_flags+=("--controller-manager-extra-args")
    local_nonpersistent_flags+=("--controller-manager-extra-args=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--image-repository=")
    two_word_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--pod-network-cidr=")
    two_word_flags+=("--pod-network-cidr")
    local_nonpersistent_flags+=("--pod-network-cidr")
    local_nonpersistent_flags+=("--pod-network-cidr=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_control-plane_scheduler()
{
    last_command="kubeadm_init_phase_control-plane_scheduler"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--image-repository=")
    two_word_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--scheduler-extra-args=")
    two_word_flags+=("--scheduler-extra-args")
    local_nonpersistent_flags+=("--scheduler-extra-args")
    local_nonpersistent_flags+=("--scheduler-extra-args=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_control-plane()
{
    last_command="kubeadm_init_phase_control-plane"

    command_aliases=()

    commands=()
    commands+=("all")
    commands+=("apiserver")
    commands+=("controller-manager")
    commands+=("scheduler")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_etcd_local()
{
    last_command="kubeadm_init_phase_etcd_local"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--image-repository=")
    two_word_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_etcd()
{
    last_command="kubeadm_init_phase_etcd"

    command_aliases=()

    commands=()
    commands+=("local")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_kubeconfig_admin()
{
    last_command="kubeadm_init_phase_kubeconfig_admin"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane-endpoint=")
    two_word_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubeconfig-dir=")
    two_word_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_kubeconfig_all()
{
    last_command="kubeadm_init_phase_kubeconfig_all"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane-endpoint=")
    two_word_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubeconfig-dir=")
    two_word_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_kubeconfig_controller-manager()
{
    last_command="kubeadm_init_phase_kubeconfig_controller-manager"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane-endpoint=")
    two_word_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubeconfig-dir=")
    two_word_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_kubeconfig_kubelet()
{
    last_command="kubeadm_init_phase_kubeconfig_kubelet"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane-endpoint=")
    two_word_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubeconfig-dir=")
    two_word_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_kubeconfig_scheduler()
{
    last_command="kubeadm_init_phase_kubeconfig_scheduler"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane-endpoint=")
    two_word_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubeconfig-dir=")
    two_word_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_kubeconfig_super-admin()
{
    last_command="kubeadm_init_phase_kubeconfig_super-admin"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane-endpoint=")
    two_word_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubeconfig-dir=")
    two_word_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir")
    local_nonpersistent_flags+=("--kubeconfig-dir=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_kubeconfig()
{
    last_command="kubeadm_init_phase_kubeconfig"

    command_aliases=()

    commands=()
    commands+=("admin")
    commands+=("all")
    commands+=("controller-manager")
    commands+=("kubelet")
    commands+=("scheduler")
    commands+=("super-admin")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_kubelet-finalize_all()
{
    last_command="kubeadm_init_phase_kubelet-finalize_all"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_kubelet-finalize_experimental-cert-rotation()
{
    last_command="kubeadm_init_phase_kubelet-finalize_experimental-cert-rotation"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_kubelet-finalize()
{
    last_command="kubeadm_init_phase_kubelet-finalize"

    command_aliases=()

    commands=()
    commands+=("all")
    commands+=("experimental-cert-rotation")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_kubelet-start()
{
    last_command="kubeadm_init_phase_kubelet-start"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--cri-socket=")
    two_word_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--image-repository=")
    two_word_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository=")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_mark-control-plane()
{
    last_command="kubeadm_init_phase_mark-control-plane"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_preflight()
{
    last_command="kubeadm_init_phase_preflight"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--cri-socket=")
    two_word_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--ignore-preflight-errors=")
    two_word_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors=")
    flags+=("--image-repository=")
    two_word_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_show-join-command()
{
    last_command="kubeadm_init_phase_show-join-command"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_upload-certs()
{
    last_command="kubeadm_init_phase_upload-certs"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--certificate-key=")
    two_word_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--skip-certificate-key-print")
    local_nonpersistent_flags+=("--skip-certificate-key-print")
    flags+=("--upload-certs")
    local_nonpersistent_flags+=("--upload-certs")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_upload-config_all()
{
    last_command="kubeadm_init_phase_upload-config_all"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--cri-socket=")
    two_word_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_upload-config_kubeadm()
{
    last_command="kubeadm_init_phase_upload-config_kubeadm"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--cri-socket=")
    two_word_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_upload-config_kubelet()
{
    last_command="kubeadm_init_phase_upload-config_kubelet"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--cri-socket=")
    two_word_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase_upload-config()
{
    last_command="kubeadm_init_phase_upload-config"

    command_aliases=()

    commands=()
    commands+=("all")
    commands+=("kubeadm")
    commands+=("kubelet")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init_phase()
{
    last_command="kubeadm_init_phase"

    command_aliases=()

    commands=()
    commands+=("addon")
    commands+=("bootstrap-token")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("bootstraptoken")
        aliashash["bootstraptoken"]="bootstrap-token"
    fi
    commands+=("certs")
    commands+=("control-plane")
    commands+=("etcd")
    commands+=("kubeconfig")
    commands+=("kubelet-finalize")
    commands+=("kubelet-start")
    commands+=("mark-control-plane")
    commands+=("preflight")
    commands+=("show-join-command")
    commands+=("upload-certs")
    commands+=("upload-config")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("uploadconfig")
        aliashash["uploadconfig"]="upload-config"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_init()
{
    last_command="kubeadm_init"

    command_aliases=()

    commands=()
    commands+=("phase")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--apiserver-cert-extra-sans=")
    two_word_flags+=("--apiserver-cert-extra-sans")
    local_nonpersistent_flags+=("--apiserver-cert-extra-sans")
    local_nonpersistent_flags+=("--apiserver-cert-extra-sans=")
    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--certificate-key=")
    two_word_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane-endpoint=")
    two_word_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint")
    local_nonpersistent_flags+=("--control-plane-endpoint=")
    flags+=("--cri-socket=")
    two_word_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--feature-gates=")
    two_word_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates=")
    flags+=("--ignore-preflight-errors=")
    two_word_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors=")
    flags+=("--image-repository=")
    two_word_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository")
    local_nonpersistent_flags+=("--image-repository=")
    flags+=("--kubernetes-version=")
    two_word_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version")
    local_nonpersistent_flags+=("--kubernetes-version=")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--pod-network-cidr=")
    two_word_flags+=("--pod-network-cidr")
    local_nonpersistent_flags+=("--pod-network-cidr")
    local_nonpersistent_flags+=("--pod-network-cidr=")
    flags+=("--service-cidr=")
    two_word_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr")
    local_nonpersistent_flags+=("--service-cidr=")
    flags+=("--service-dns-domain=")
    two_word_flags+=("--service-dns-domain")
    local_nonpersistent_flags+=("--service-dns-domain")
    local_nonpersistent_flags+=("--service-dns-domain=")
    flags+=("--skip-certificate-key-print")
    local_nonpersistent_flags+=("--skip-certificate-key-print")
    flags+=("--skip-phases=")
    two_word_flags+=("--skip-phases")
    local_nonpersistent_flags+=("--skip-phases")
    local_nonpersistent_flags+=("--skip-phases=")
    flags+=("--skip-token-print")
    local_nonpersistent_flags+=("--skip-token-print")
    flags+=("--token=")
    two_word_flags+=("--token")
    local_nonpersistent_flags+=("--token")
    local_nonpersistent_flags+=("--token=")
    flags+=("--token-ttl=")
    two_word_flags+=("--token-ttl")
    local_nonpersistent_flags+=("--token-ttl")
    local_nonpersistent_flags+=("--token-ttl=")
    flags+=("--upload-certs")
    local_nonpersistent_flags+=("--upload-certs")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_control-plane-join_all()
{
    last_command="kubeadm_join_phase_control-plane-join_all"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane")
    local_nonpersistent_flags+=("--control-plane")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_control-plane-join_etcd()
{
    last_command="kubeadm_join_phase_control-plane-join_etcd"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane")
    local_nonpersistent_flags+=("--control-plane")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_control-plane-join_mark-control-plane()
{
    last_command="kubeadm_join_phase_control-plane-join_mark-control-plane"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane")
    local_nonpersistent_flags+=("--control-plane")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_control-plane-join_update-status()
{
    last_command="kubeadm_join_phase_control-plane-join_update-status"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane")
    local_nonpersistent_flags+=("--control-plane")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_control-plane-join()
{
    last_command="kubeadm_join_phase_control-plane-join"

    command_aliases=()

    commands=()
    commands+=("all")
    commands+=("etcd")
    commands+=("mark-control-plane")
    commands+=("update-status")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_control-plane-prepare_all()
{
    last_command="kubeadm_join_phase_control-plane-prepare_all"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--certificate-key=")
    two_word_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane")
    local_nonpersistent_flags+=("--control-plane")
    flags+=("--discovery-file=")
    two_word_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file=")
    flags+=("--discovery-token=")
    two_word_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token=")
    flags+=("--discovery-token-ca-cert-hash=")
    two_word_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash=")
    flags+=("--discovery-token-unsafe-skip-ca-verification")
    local_nonpersistent_flags+=("--discovery-token-unsafe-skip-ca-verification")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--tls-bootstrap-token=")
    two_word_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token=")
    flags+=("--token=")
    two_word_flags+=("--token")
    local_nonpersistent_flags+=("--token")
    local_nonpersistent_flags+=("--token=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_control-plane-prepare_certs()
{
    last_command="kubeadm_join_phase_control-plane-prepare_certs"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane")
    local_nonpersistent_flags+=("--control-plane")
    flags+=("--discovery-file=")
    two_word_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file=")
    flags+=("--discovery-token=")
    two_word_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token=")
    flags+=("--discovery-token-ca-cert-hash=")
    two_word_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash=")
    flags+=("--discovery-token-unsafe-skip-ca-verification")
    local_nonpersistent_flags+=("--discovery-token-unsafe-skip-ca-verification")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--tls-bootstrap-token=")
    two_word_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token=")
    flags+=("--token=")
    two_word_flags+=("--token")
    local_nonpersistent_flags+=("--token")
    local_nonpersistent_flags+=("--token=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_control-plane-prepare_control-plane()
{
    last_command="kubeadm_join_phase_control-plane-prepare_control-plane"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane")
    local_nonpersistent_flags+=("--control-plane")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_control-plane-prepare_download-certs()
{
    last_command="kubeadm_join_phase_control-plane-prepare_download-certs"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--certificate-key=")
    two_word_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane")
    local_nonpersistent_flags+=("--control-plane")
    flags+=("--discovery-file=")
    two_word_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file=")
    flags+=("--discovery-token=")
    two_word_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token=")
    flags+=("--discovery-token-ca-cert-hash=")
    two_word_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash=")
    flags+=("--discovery-token-unsafe-skip-ca-verification")
    local_nonpersistent_flags+=("--discovery-token-unsafe-skip-ca-verification")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--tls-bootstrap-token=")
    two_word_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token=")
    flags+=("--token=")
    two_word_flags+=("--token")
    local_nonpersistent_flags+=("--token")
    local_nonpersistent_flags+=("--token=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_control-plane-prepare_kubeconfig()
{
    last_command="kubeadm_join_phase_control-plane-prepare_kubeconfig"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--certificate-key=")
    two_word_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane")
    local_nonpersistent_flags+=("--control-plane")
    flags+=("--discovery-file=")
    two_word_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file=")
    flags+=("--discovery-token=")
    two_word_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token=")
    flags+=("--discovery-token-ca-cert-hash=")
    two_word_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash=")
    flags+=("--discovery-token-unsafe-skip-ca-verification")
    local_nonpersistent_flags+=("--discovery-token-unsafe-skip-ca-verification")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--tls-bootstrap-token=")
    two_word_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token=")
    flags+=("--token=")
    two_word_flags+=("--token")
    local_nonpersistent_flags+=("--token")
    local_nonpersistent_flags+=("--token=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_control-plane-prepare()
{
    last_command="kubeadm_join_phase_control-plane-prepare"

    command_aliases=()

    commands=()
    commands+=("all")
    commands+=("certs")
    commands+=("control-plane")
    commands+=("download-certs")
    commands+=("kubeconfig")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_kubelet-start()
{
    last_command="kubeadm_join_phase_kubelet-start"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--cri-socket=")
    two_word_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket=")
    flags+=("--discovery-file=")
    two_word_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file=")
    flags+=("--discovery-token=")
    two_word_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token=")
    flags+=("--discovery-token-ca-cert-hash=")
    two_word_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash=")
    flags+=("--discovery-token-unsafe-skip-ca-verification")
    local_nonpersistent_flags+=("--discovery-token-unsafe-skip-ca-verification")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--tls-bootstrap-token=")
    two_word_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token=")
    flags+=("--token=")
    two_word_flags+=("--token")
    local_nonpersistent_flags+=("--token")
    local_nonpersistent_flags+=("--token=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_preflight()
{
    last_command="kubeadm_join_phase_preflight"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--certificate-key=")
    two_word_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane")
    local_nonpersistent_flags+=("--control-plane")
    flags+=("--cri-socket=")
    two_word_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket=")
    flags+=("--discovery-file=")
    two_word_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file=")
    flags+=("--discovery-token=")
    two_word_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token=")
    flags+=("--discovery-token-ca-cert-hash=")
    two_word_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash=")
    flags+=("--discovery-token-unsafe-skip-ca-verification")
    local_nonpersistent_flags+=("--discovery-token-unsafe-skip-ca-verification")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--ignore-preflight-errors=")
    two_word_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors=")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--tls-bootstrap-token=")
    two_word_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token=")
    flags+=("--token=")
    two_word_flags+=("--token")
    local_nonpersistent_flags+=("--token")
    local_nonpersistent_flags+=("--token=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase_wait-control-plane()
{
    last_command="kubeadm_join_phase_wait-control-plane"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join_phase()
{
    last_command="kubeadm_join_phase"

    command_aliases=()

    commands=()
    commands+=("control-plane-join")
    commands+=("control-plane-prepare")
    commands+=("kubelet-start")
    commands+=("preflight")
    commands+=("wait-control-plane")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_join()
{
    last_command="kubeadm_join"

    command_aliases=()

    commands=()
    commands+=("phase")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--apiserver-advertise-address=")
    two_word_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address")
    local_nonpersistent_flags+=("--apiserver-advertise-address=")
    flags+=("--apiserver-bind-port=")
    two_word_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port")
    local_nonpersistent_flags+=("--apiserver-bind-port=")
    flags+=("--certificate-key=")
    two_word_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--control-plane")
    local_nonpersistent_flags+=("--control-plane")
    flags+=("--cri-socket=")
    two_word_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket=")
    flags+=("--discovery-file=")
    two_word_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file")
    local_nonpersistent_flags+=("--discovery-file=")
    flags+=("--discovery-token=")
    two_word_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token")
    local_nonpersistent_flags+=("--discovery-token=")
    flags+=("--discovery-token-ca-cert-hash=")
    two_word_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash")
    local_nonpersistent_flags+=("--discovery-token-ca-cert-hash=")
    flags+=("--discovery-token-unsafe-skip-ca-verification")
    local_nonpersistent_flags+=("--discovery-token-unsafe-skip-ca-verification")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--ignore-preflight-errors=")
    two_word_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors=")
    flags+=("--node-name=")
    two_word_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name")
    local_nonpersistent_flags+=("--node-name=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--skip-phases=")
    two_word_flags+=("--skip-phases")
    local_nonpersistent_flags+=("--skip-phases")
    local_nonpersistent_flags+=("--skip-phases=")
    flags+=("--tls-bootstrap-token=")
    two_word_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token")
    local_nonpersistent_flags+=("--tls-bootstrap-token=")
    flags+=("--token=")
    two_word_flags+=("--token")
    local_nonpersistent_flags+=("--token")
    local_nonpersistent_flags+=("--token=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_kubeconfig_user()
{
    last_command="kubeadm_kubeconfig_user"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--client-name=")
    two_word_flags+=("--client-name")
    local_nonpersistent_flags+=("--client-name")
    local_nonpersistent_flags+=("--client-name=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--org=")
    two_word_flags+=("--org")
    local_nonpersistent_flags+=("--org")
    local_nonpersistent_flags+=("--org=")
    flags+=("--token=")
    two_word_flags+=("--token")
    local_nonpersistent_flags+=("--token")
    local_nonpersistent_flags+=("--token=")
    flags+=("--validity-period=")
    two_word_flags+=("--validity-period")
    local_nonpersistent_flags+=("--validity-period")
    local_nonpersistent_flags+=("--validity-period=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_flag+=("--client-name=")
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_kubeconfig()
{
    last_command="kubeadm_kubeconfig"

    command_aliases=()

    commands=()
    commands+=("user")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_reset_phase_cleanup-node()
{
    last_command="kubeadm_reset_phase_cleanup-node"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--cleanup-tmp-dir")
    local_nonpersistent_flags+=("--cleanup-tmp-dir")
    flags+=("--cri-socket=")
    two_word_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_reset_phase_preflight()
{
    last_command="kubeadm_reset_phase_preflight"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")
    flags+=("--ignore-preflight-errors=")
    two_word_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_reset_phase_remove-etcd-member()
{
    last_command="kubeadm_reset_phase_remove-etcd-member"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_reset_phase()
{
    last_command="kubeadm_reset_phase"

    command_aliases=()

    commands=()
    commands+=("cleanup-node")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("cleanupnode")
        aliashash["cleanupnode"]="cleanup-node"
    fi
    commands+=("preflight")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("pre-flight")
        aliashash["pre-flight"]="preflight"
    fi
    commands+=("remove-etcd-member")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_reset()
{
    last_command="kubeadm_reset"

    command_aliases=()

    commands=()
    commands+=("phase")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert-dir=")
    two_word_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir")
    local_nonpersistent_flags+=("--cert-dir=")
    flags+=("--cleanup-tmp-dir")
    local_nonpersistent_flags+=("--cleanup-tmp-dir")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--cri-socket=")
    two_word_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket")
    local_nonpersistent_flags+=("--cri-socket=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")
    flags+=("--ignore-preflight-errors=")
    two_word_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--skip-phases=")
    two_word_flags+=("--skip-phases")
    local_nonpersistent_flags+=("--skip-phases")
    local_nonpersistent_flags+=("--skip-phases=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_token_create()
{
    last_command="kubeadm_token_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--certificate-key=")
    two_word_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key")
    local_nonpersistent_flags+=("--certificate-key=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--groups=")
    two_word_flags+=("--groups")
    local_nonpersistent_flags+=("--groups")
    local_nonpersistent_flags+=("--groups=")
    flags+=("--print-join-command")
    local_nonpersistent_flags+=("--print-join-command")
    flags+=("--ttl=")
    two_word_flags+=("--ttl")
    local_nonpersistent_flags+=("--ttl")
    local_nonpersistent_flags+=("--ttl=")
    flags+=("--usages=")
    two_word_flags+=("--usages")
    local_nonpersistent_flags+=("--usages")
    local_nonpersistent_flags+=("--usages=")
    flags+=("--add-dir-header")
    flags+=("--dry-run")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_token_delete()
{
    last_command="kubeadm_token_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--dry-run")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_token_generate()
{
    last_command="kubeadm_token_generate"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--dry-run")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_token_list()
{
    last_command="kubeadm_token_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--allow-missing-template-keys")
    local_nonpersistent_flags+=("--allow-missing-template-keys")
    flags+=("--experimental-output=")
    two_word_flags+=("--experimental-output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--experimental-output")
    local_nonpersistent_flags+=("--experimental-output=")
    local_nonpersistent_flags+=("-o")
    flags+=("--show-managed-fields")
    local_nonpersistent_flags+=("--show-managed-fields")
    flags+=("--add-dir-header")
    flags+=("--dry-run")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_token()
{
    last_command="kubeadm_token"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    commands+=("generate")
    commands+=("list")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--dry-run")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_upgrade_apply()
{
    last_command="kubeadm_upgrade_apply"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--allow-experimental-upgrades")
    local_nonpersistent_flags+=("--allow-experimental-upgrades")
    flags+=("--allow-release-candidate-upgrades")
    local_nonpersistent_flags+=("--allow-release-candidate-upgrades")
    flags+=("--certificate-renewal")
    local_nonpersistent_flags+=("--certificate-renewal")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--etcd-upgrade")
    local_nonpersistent_flags+=("--etcd-upgrade")
    flags+=("--feature-gates=")
    two_word_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates=")
    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")
    flags+=("--ignore-preflight-errors=")
    two_word_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--print-config")
    local_nonpersistent_flags+=("--print-config")
    flags+=("--yes")
    flags+=("-y")
    local_nonpersistent_flags+=("--yes")
    local_nonpersistent_flags+=("-y")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_upgrade_diff()
{
    last_command="kubeadm_upgrade_diff"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-server-manifest=")
    two_word_flags+=("--api-server-manifest")
    local_nonpersistent_flags+=("--api-server-manifest")
    local_nonpersistent_flags+=("--api-server-manifest=")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--context-lines=")
    two_word_flags+=("--context-lines")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--context-lines")
    local_nonpersistent_flags+=("--context-lines=")
    local_nonpersistent_flags+=("-c")
    flags+=("--controller-manager-manifest=")
    two_word_flags+=("--controller-manager-manifest")
    local_nonpersistent_flags+=("--controller-manager-manifest")
    local_nonpersistent_flags+=("--controller-manager-manifest=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--scheduler-manifest=")
    two_word_flags+=("--scheduler-manifest")
    local_nonpersistent_flags+=("--scheduler-manifest")
    local_nonpersistent_flags+=("--scheduler-manifest=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_upgrade_node_phase_control-plane()
{
    last_command="kubeadm_upgrade_node_phase_control-plane"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--certificate-renewal")
    local_nonpersistent_flags+=("--certificate-renewal")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--etcd-upgrade")
    local_nonpersistent_flags+=("--etcd-upgrade")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_upgrade_node_phase_kubelet-config()
{
    last_command="kubeadm_upgrade_node_phase_kubelet-config"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_upgrade_node_phase_preflight()
{
    last_command="kubeadm_upgrade_node_phase_preflight"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ignore-preflight-errors=")
    two_word_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_upgrade_node_phase()
{
    last_command="kubeadm_upgrade_node_phase"

    command_aliases=()

    commands=()
    commands+=("control-plane")
    commands+=("kubelet-config")
    commands+=("preflight")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_upgrade_node()
{
    last_command="kubeadm_upgrade_node"

    command_aliases=()

    commands=()
    commands+=("phase")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--certificate-renewal")
    local_nonpersistent_flags+=("--certificate-renewal")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--etcd-upgrade")
    local_nonpersistent_flags+=("--etcd-upgrade")
    flags+=("--ignore-preflight-errors=")
    two_word_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--patches=")
    two_word_flags+=("--patches")
    local_nonpersistent_flags+=("--patches")
    local_nonpersistent_flags+=("--patches=")
    flags+=("--skip-phases=")
    two_word_flags+=("--skip-phases")
    local_nonpersistent_flags+=("--skip-phases")
    local_nonpersistent_flags+=("--skip-phases=")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_upgrade_plan()
{
    last_command="kubeadm_upgrade_plan"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--allow-experimental-upgrades")
    local_nonpersistent_flags+=("--allow-experimental-upgrades")
    flags+=("--allow-missing-template-keys")
    local_nonpersistent_flags+=("--allow-missing-template-keys")
    flags+=("--allow-release-candidate-upgrades")
    local_nonpersistent_flags+=("--allow-release-candidate-upgrades")
    flags+=("--config=")
    two_word_flags+=("--config")
    local_nonpersistent_flags+=("--config")
    local_nonpersistent_flags+=("--config=")
    flags+=("--experimental-output=")
    two_word_flags+=("--experimental-output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--experimental-output")
    local_nonpersistent_flags+=("--experimental-output=")
    local_nonpersistent_flags+=("-o")
    flags+=("--feature-gates=")
    two_word_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates")
    local_nonpersistent_flags+=("--feature-gates=")
    flags+=("--ignore-preflight-errors=")
    two_word_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors")
    local_nonpersistent_flags+=("--ignore-preflight-errors=")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig")
    local_nonpersistent_flags+=("--kubeconfig=")
    flags+=("--print-config")
    local_nonpersistent_flags+=("--print-config")
    flags+=("--show-managed-fields")
    local_nonpersistent_flags+=("--show-managed-fields")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_upgrade()
{
    last_command="kubeadm_upgrade"

    command_aliases=()

    commands=()
    commands+=("apply")
    commands+=("diff")
    commands+=("node")
    commands+=("plan")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_version()
{
    last_command="kubeadm_version"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output")
    local_nonpersistent_flags+=("--output=")
    local_nonpersistent_flags+=("-o")
    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_kubeadm_root_command()
{
    last_command="kubeadm"

    command_aliases=()

    commands=()
    commands+=("certs")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("certificates")
        aliashash["certificates"]="certs"
    fi
    commands+=("completion")
    commands+=("config")
    commands+=("help")
    commands+=("init")
    commands+=("join")
    commands+=("kubeconfig")
    commands+=("reset")
    commands+=("token")
    commands+=("upgrade")
    commands+=("version")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--add-dir-header")
    flags+=("--rootfs=")
    two_word_flags+=("--rootfs")
    flags+=("--skip-headers")
    flags+=("--v=")
    two_word_flags+=("--v")
    two_word_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_kubeadm()
{
    local cur prev words cword split
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __kubeadm_init_completion -n "=" || return
    fi

    local c=0
    local flag_parsing_disabled=
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("kubeadm")
    local command_aliases=()
    local must_have_one_flag=()
    local must_have_one_noun=()
    local has_completion_function=""
    local last_command=""
    local nouns=()
    local noun_aliases=()

    __kubeadm_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_kubeadm kubeadm
else
    complete -o default -o nospace -F __start_kubeadm kubeadm
fi

# ex: ts=4 sw=4 et filetype=sh
