# ================================
# 🌱 Git Bash Helper Aliases & Functions
# ================================

# --- Git Basics ---
alias gbs='echo Branch Status; git status'
alias ga='echo Staging files; git add'
alias gau='echo Unstaging files; git reset HEAD'
alias gc='git commit -m'  # commit with branch prefix
alias gcp='gc_branch_prefix'
alias gp='echo Pushing branch to remote; git push'

# --- Logs & Diff ---
alias gl='echo Gitlog with decorated output; git log --oneline --graph --decorate --all'
alias gll='echo Detailed log with colors; git log --color=always --graph --abbrev-commit --decorate --all'
alias gsh='echo Show latest commit details; git show HEAD'
alias gd='echo Diff unstaged changes; git diff'
alias gds='echo Diff staged changes; git diff --staged'

# --- Branch Management ---
alias gbdl='echo Deleting branch locally; git branch -d'
alias gbdr='echo Deleting branch remotely; git push origin --delete'
alias gbll='echo Listing local branches; git branch'
alias gblr='echo Listing remote branches; git branch -r'
alias gbrl='echo Renaming branch locally; git branch -m'

# --- Rebasing / Resetting ---
alias gcr='echo Rebasing HEAD with last 5 commits; git rebase -i HEAD~5'
alias gra='echo Git rebase ABORT; git rebase --abort'
alias grc='echo Git rebase continue; git rebase --continue'
alias gundo='echo Undo last commit (keep changes staged); git reset --soft HEAD~1'
alias gundoh='echo Undo last commit (unstage changes, keep edits); git reset --mixed HEAD~1'
alias gundoall='echo Undo last commit and discard changes; git reset --hard HEAD~1'

# --- File Tracking ---
alias guntrack='echo Stop tracking file but keep locally; git rm --cached'

# --- Stash Helpers ---
alias gstash='echo Saving changes to stash; git stash push -u'
alias gstashm='echo Saving changes to stash with message; git stash push -u -m'
alias gstashl='echo Listing stash entries; git stash list'
alias gstasha='echo Applying latest stash; git stash apply'
alias gstashp='echo Popping latest stash; git stash pop'
alias gstashd='echo Dropping stash by ID; git stash drop'

# ================================
# 📂 Directory Menu Helper
# ================================
cdmenu() {
    dirs=(*/)
    [ ${#dirs[@]} -eq 0 ] && { echo "No subdirectories found"; return 1; }
    echo "Select a directory:"
    select d in "${dirs[@]}"; do
        [ -n "$d" ] && cd "$d" && break
        echo "Invalid choice"
    done
}

echo "CD to your GIT workspace"
cd ~/Desktop/GIT/ 2>/dev/null
cdmenu
echo "ghelp - for additional helper functions"

# ================================
# 🌐 Remote Repo Helpers
# ================================
setremote() {
    [ $# -ne 2 ] && { echo "Usage: setremote <remote_name> <url>"; return 1; }
    local remote_name=$1 url=$2
    if git remote get-url "$remote_name" &>/dev/null; then
        echo "Updating remote '$remote_name' to $url"
        git remote set-url "$remote_name" "$url"
    else
        echo "Adding new remote '$remote_name' -> $url"
        git remote add "$remote_name" "$url"
    fi
    git remote -v
}

pushup() {
    local remote_name=${1:-origin}
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)
    [ -z "$branch" ] && { echo "Not on a branch"; return 1; }
    echo "Pushing branch '$branch' to remote '$remote_name'"
    git push -u "$remote_name" "$branch"
}

ghcreate() {
    ! command -v gh &>/dev/null && { echo "GitHub CLI not found"; return 1; }
    local repo_name=$1 visibility=${2:-private}
    echo "Creating GitHub repo '$repo_name' with visibility '$visibility'"
    gh repo create "$repo_name" --"$visibility" --source=. --push
}

remoteinfo() {
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)
    [ -z "$branch" ] && { echo "Not on a branch"; return 1; }
    echo -e "\n📌 Current branch: $branch"
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    [ -n "$upstream" ] && echo "Tracking upstream: $upstream" || echo "No upstream set for this branch"
    echo -e "\n🌐 Remote repositories:"
    git remote -v
    echo
}

# ================================
# 🎨 Enhanced Git-Aware Prompt
# ================================
parse_git_status() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)
    staged=$(git diff --cached --name-only 2>/dev/null | wc -l)
    unstaged=$(git diff --name-only 2>/dev/null | wc -l)
    untracked=$(git ls-files --others --exclude-standard | wc -l)

    dirty=""
    [ "$staged" -gt 0 ] && dirty+="●"
    [ "$unstaged" -gt 0 ] && dirty+="✗"
    [ "$untracked" -gt 0 ] && dirty+="..."
    [ -z "$dirty" ] && dirty="✔"

    ahead=$(git rev-list --count --left-only @{u}...HEAD 2>/dev/null)
    behind=$(git rev-list --count --right-only @{u}...HEAD 2>/dev/null)
    ab=""
    [ "$ahead" -gt 0 ] && ab+="↑$ahead"
    [ "$behind" -gt 0 ] && ab+="↓$behind"
    [ -n "$ab" ] && ab=" $ab"

    tag=$(git describe --tags --exact-match 2>/dev/null)
    [ -n "$tag" ] && tag=" tag:$tag"

    echo " $branch$ab $dirty$tag"
}

GREEN="\[\e[1;32m\]"
YELLOW="\[\e[1;33m\]"
BLUE="\[\e[1;34m\]"
RESET="\[\e[0m\]"

export PS1="$GREEN\u@\h $BLUE\w $YELLOW\$(parse_git_status)$RESET ➜ "

# ================================
# 🛠 Branch Checkout Helpers
# ================================
gco() {
    local flag_p=0
    local branch=""

    # Parse options
    while [[ "$1" == -* ]]; do
        case "$1" in
            -p) flag_p=1 ;;
            *) echo "Unknown option $1"; return 1 ;;
        esac
        shift
    done

    branch="$1"
    [ -z "$branch" ] && { echo "Usage: gco [-p] <branch>"; return 1; }

    # Save current branch
    local current_branch
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

    if [[ "$branch" == "$current_branch" ]]; then
        echo "Already on branch '$branch'"
        return 0
    fi

    if [[ $flag_p -eq 1 ]]; then
        # Checkout target branch, pull, then return
        git checkout "$branch" || return 1
        git pull || return 1
        git checkout "$current_branch" || return 1
        echo "Pulled '$branch' and returned to '$current_branch'"
    else
        git checkout "$branch" || return 1
    fi
}

gcb() {
    if command -v fzf &>/dev/null; then
        local branch=$(git branch --all | sed 's/^[* ] //' | fzf --height 40% --reverse --border)
    else
        echo "fzf not found. Listing branches numerically:"
        mapfile -t branches < <(git branch --all | sed 's/^[* ] //')
        select branch in "${branches[@]}"; do
            [ -n "$branch" ] && break
        done
    fi
    [ -z "$branch" ] && { echo "No branch selected"; return 1; }
    gco "$branch"
}

# ================================
# 📝 Commit with branch prefix
# ================================
gc_branch_prefix() {

    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)
    if [ -z "$branch" ]; then
        echo "Not on a branch"
        return 1
    fi

    # Extract prefix and ticket
    if [[ "$branch" =~ ^([^/]+)/(.+)$ ]]; then
        prefix="${BASH_REMATCH[1]}"
        ticket="${BASH_REMATCH[2]}"
        commit_prefix="$prefix: $ticket - "
    else
        commit_prefix=""
    fi

    if [ $# -eq 0 ]; then
        echo "Usage: gcp <commit message>"
        return 1
    fi

    git commit -m "$commit_prefix$*"

}

# ================================
# 🔄 Rebase onto any branch
# ================================
grebase() {
    local target="${1:-main}"
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)

    [ -z "$branch" ] && { echo "Not on a branch"; return 1; }

    echo "You are on branch '$branch'."
    echo "Do you want to rebase '$branch' onto 'origin/$target'? [y/N]"
    read -r answer
    case "$answer" in
        [Yy]* )
            git fetch origin || { echo "Failed to fetch"; return 1; }
            git rebase "origin/$target" || { echo "Rebase failed"; return 1; }
            echo "Rebased '$branch' onto 'origin/$target'"
            ;;
        * )
            echo "Aborted"
            return 0
            ;;
    esac
}

# ================================
# 📖 Colored Git Helper Menu
# ================================
ghelp() {
    echo -e "\n\e[1;32m🌱 Git Helper Commands\e[0m\n"

    echo -e "\e[1;32m[ Status / Stage / Commit / Push ]\e[0m"
    echo -e "  \e[1;36mgbs\e[0m      → Branch Status"
    echo -e "  \e[1;36mga\e[0m       → Stage files"
    echo -e "  \e[1;36mgau\e[0m      → Unstage files"
    echo -e "  \e[1;36mgc\e[0m       → Commit with plain message (no branch prefix)"
    echo -e "  \e[1;36mgcp\e[0m      → Commit with branch-aware prefix (auto-prefixes branch type/ticket)"
    echo -e "                  e.g., branch 'feat/HELP-123', usage: gcp \"Fix login bug\" → commit message: feat: HELP-123 - Fix login bug"

    echo -e "  \e[1;36mgp\e[0m       → Push branch to remote"

    echo -e "\n\e[1;32m[ Logs / Diffs / Show ]\e[0m"
    echo -e "  \e[1;36mgl\e[0m       → Pretty log"
    echo -e "  \e[1;36mgll\e[0m      → Detailed log with colors"
    echo -e "  \e[1;36mgsh\e[0m      → Show latest commit details"
    echo -e "  \e[1;36mgd\e[0m       → Diff unstaged changes"
    echo -e "  \e[1;36mgds\e[0m      → Diff staged changes"

    echo -e "\n\e[1;32m[ Branch Management ]\e[0m"
    echo -e "  \e[1;36mgbdl\e[0m     → Delete branch locally"
    echo -e "  \e[1;36mgbdr\e[0m     → Delete branch remotely"
    echo -e "  \e[1;36mgbll\e[0m     → List local branches"
    echo -e "  \e[1;36mgblr\e[0m     → List remote branches"
    echo -e "  \e[1;36mgbrl\e[0m     → Rename branch locally"
    echo -e "  \e[1;36mgco\e[0m      → Checkout branch (with -p perform git pull and return to previous branch)"
    echo -e "  \e[1;36mgcb\e[0m      → Interactive checkout"

    echo -e "\n\e[1;32m[ Rebasing / Resetting ]\e[0m"
    echo -e "  \e[1;36mgcr\e[0m      → Rebase last 5 commits interactively"
    echo -e "  \e[1;36mgra\e[0m      → Abort rebase"
    echo -e "  \e[1;36mgrc\e[0m      → Continue rebase"
    echo -e "  \e[1;36mgrebase\e[0m  → Rebase current branch onto main (or specified)"

    echo -e "  \e[1;36mgundo\e[0m    → Undo last commit (keep staged)"
    echo -e "  \e[1;36mgundoh\e[0m   → Undo last commit (unstage changes)"
    echo -e "  \e[1;36mgundoall\e[0m → Undo last commit (discard changes)"

    echo -e "\n\e[1;32m[ Stash Helpers ]\e[0m"
    echo -e "  \e[1;36mgstash\e[0m   → Save stash (includes untracked)"
    echo -e "  \e[1;36mgstashm\e[0m  → Save stash with message"
    echo -e "  \e[1;36mgstashl\e[0m  → List stash entries"
    echo -e "  \e[1;36mgstasha\e[0m  → Apply latest stash"
    echo -e "  \e[1;36mgstashp\e[0m  → Pop latest stash"
    echo -e "  \e[1;36mgstashd\e[0m  → Drop stash by ID"

    echo -e "\n\e[1;32m[ File Tracking ]\e[0m"
    echo -e "  \e[1;36mguntrack\e[0m → Stop tracking file but keep locally"

    echo -e "\n\e[1;32m[ Remote / Upstream Helper ]\e[0m"
    echo -e "  \e[1;36msetremote\e[0m → Add or update a remote URL"
    echo -e "  \e[1;36mpushup\e[0m    → Push current branch and set upstream"
    echo -e "  \e[1;36mghcreate\e[0m  → Create GitHub repo and push"
    echo -e "  \e[1;36mremoteinfo\e[0m → Show remotes and upstream info"

    echo -e "\n💡 Tip: Run \e[1;36mghelp\e[0m anytime to recall these shortcuts!\n"
}

# ================================
# 🌟 Advanced Tab-Completion for Git Helpers
# ================================

# --- Smart branch completion for gco/gcb ---
_git_branch_smart_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local opts="-p"

    # If previous word is an option, skip completion
    if [[ "$prev" == -* ]]; then
        return 0
    fi

    # Complete option if it's the current word
    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
        return 0
    fi

    # List local branches first
    local local_branches remote_branches all_branches
    local_branches=$(git for-each-ref --format='%(refname:short)' refs/heads/ | sort)
    remote_branches=$(git for-each-ref --format='%(refname:short)' refs/remotes/ | sed 's|^origin/||' | sort)
    all_branches=$(echo -e "${local_branches}\n${remote_branches}" | sort -u)

    COMPREPLY=( $(compgen -W "${all_branches}" -- "$cur") )
}

# Attach smart branch completion
complete -F _git_branch_smart_completion gco
complete -F _git_branch_smart_completion gcb
complete -F _git_branch_smart_completion gbdl
complete -F _git_branch_smart_completion gbrl

# --- Remote name completion ---
_git_remote_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local remotes
    remotes=$(git remote)
    COMPREPLY=( $(compgen -W "${remotes}" -- "$cur") )
}
complete -F _git_remote_completion setremote
complete -F _git_remote_completion pushup
complete -F _git_remote_completion gbdr

# --- Stash ID completion ---
_git_stash_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local stashes
    stashes=$(git stash list | awk -F: '{print $1}')
    COMPREPLY=( $(compgen -W "${stashes}" -- "$cur") )
}
complete -F _git_stash_completion gstasha
complete -F _git_stash_completion gstashp
complete -F _git_stash_completion gstashd

# --- Commit message completion (gcp) ---
_git_commit_message_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    local prefix=""
    if [[ "$branch" =~ ^([^/]+)/(.+)$ ]]; then
        prefix="${BASH_REMATCH[2]}"
    fi
    COMPREPLY=( $(compgen -W "$prefix" -- "$cur") )
}
complete -F _git_commit_message_completion gcp

# --- GitHub repo completion (ghcreate) ---
_git_folder_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local dirs
    dirs=$(find . -maxdepth 1 -type d -printf "%f\n")
    COMPREPLY=( $(compgen -W "${dirs}" -- "$cur") )
}
complete -F _git_folder_completion ghcreate

# ================================
# ✅ Features
# - gco/gcb: handles -p option, local branches first, remote branches next
# - Branch deletion/rename/list: smart branch completion
# - Remote commands: setremote/pushup/gbdr
# - Stash commands: gstasha/gstashp/gstashd
# - Commit messages: gcp suggests ticket prefix
# - GitHub repo creation: ghcreate suggests local folders
# ================================


