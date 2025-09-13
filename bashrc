# ================================
# 🌱 Git Bash Helper Aliases & Functions
# ================================

# --- Git Basics ---
alias gbs='echo Branch Status; git status'
alias ga='echo Staging files; git add'
alias gau='echo Unstaging files; git reset HEAD'
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
# 🌱 Git Commit Helpers
# ================================
alias gc='git commit -m'

gcp() {
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)
    if [ -z "$branch" ]; then
        echo "Not on a branch"
        return 1
    fi
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
# Branch Checkout Helpers
# ================================
gco() {
    pull_after_checkout=false
    if [ "$1" == "-p" ]; then
        pull_after_checkout=true
        shift
    fi

    if [ -z "$1" ]; then
        echo "Usage: gco [-p] <branch-name>"
        return 1
    fi

    target_branch="$1"
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

    if [ -z "$current_branch" ]; then
        echo "Not on a branch"
        return 1
    fi

    # Checkout target branch
    git checkout "$target_branch" || return 1

    # Pull if -p is specified
    if [ "$pull_after_checkout" = true ]; then
        git pull
        echo "Returning to original branch $current_branch..."
        git checkout "$current_branch"
    fi
}

gcb() {
    branches=($(git branch --all | sed 's/^[* ]*//'))
    if [ ${#branches[@]} -eq 0 ]; then
        echo "No branches found"
        return 1
    fi
    echo "Select a branch to checkout:"
    select b in "${branches[@]}"; do
        if [ -n "$b" ]; then
            git checkout "$b"
            break
        else
            echo "Invalid choice"
        fi
    done
}

# ================================
# Rebase current branch onto main
# ================================
grebase_main() {
    pull_main=false
    if [ "$1" == "-p" ]; then
        pull_main=true
    fi
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ -z "$current_branch" ]; then
        echo "Not on a branch"
        return 1
    fi
    echo "Current branch: $current_branch"
    git checkout main || { echo "Failed to checkout main"; return 1; }
    if [ "$pull_main" = true ]; then
        echo "Pulling latest main..."
        git pull || { echo "Failed to pull main"; return 1; }
    fi
    git checkout "$current_branch" || { echo "Failed to checkout $current_branch"; return 1; }
    echo "Rebasing $current_branch onto main..."
    git rebase main
}

# ================================
# Remote Helpers
# ================================
setremote() {
    if [ $# -ne 2 ]; then
        echo "Usage: setremote <remote_name> <url>"
        return 1
    fi
    local remote_name=$1
    local url=$2
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
    if [ -z "$branch" ]; then
        echo "Not on a branch"
        return 1
    fi
    echo "Pushing branch '$branch' to remote '$remote_name'"
    git push -u "$remote_name" "$branch"
}

ghcreate() {
    if ! command -v gh &>/dev/null; then
        echo "GitHub CLI (gh) not found. Install from https://cli.github.com/"
        return 1
    fi
    local repo_name=$1
    local visibility=${2:-private}
    echo "Creating GitHub repo '$repo_name' with visibility '$visibility'"
    gh repo create "$repo_name" --"$visibility" --source=. --push
}

remoteinfo() {
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)
    if [ -z "$branch" ]; then
        echo "Not on a branch"
        return 1
    fi
    echo -e "\n📌 Current branch: $branch"
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [ -n "$upstream" ]; then
        echo "Tracking upstream: $upstream"
    else
        echo "No upstream set for this branch"
    fi
    echo -e "\n🌐 Remote repositories:"
    git remote -v
    echo
}

# ================================
# Directory Menu Helper
# ================================
cdmenu() {
    dirs=(*/)
    if [ ${#dirs[@]} -eq 0 ]; then
        echo "No subdirectories found"
        return 1
    fi
    echo "Select a directory:"
    select d in "${dirs[@]}"; do
        if [ -n "$d" ]; then
            cd "$d" || return
            break
        else
            echo "Invalid choice"
        fi
    done
}

# ================================
# Git Helper Display
# ================================
ghelp() {
    echo -e "\n\e[1;32m🌱 Git Helper Commands\e[0m\n"
    echo -e "[ Status / Stage / Commit / Push ]"
    echo -e "  gbs → Branch Status"
    echo -e "  ga  → Stage files"
    echo -e "  gau → Unstage files"
    echo -e "  gc  → Commit plain"
    echo -e "  gcp → Commit with branch-aware prefix"
    echo -e "  gp  → Push branch"

    echo -e "\n[ Branch Checkout / Switch ]"
    echo -e "  gco          → Checkout branch"
    echo -e "  gco -p       → Checkout, pull, return"
    echo -e "  gcb          → Interactive branch select"
    echo -e "  grebase_main → Rebase onto main (-p pulls main first)"

    echo -e "\n[ Remote / Upstream ]"
    echo -e "  setremote  → Add or update remote URL"
    echo -e "  pushup     → Push and set upstream"
    echo -e "  ghcreate   → Create GitHub repo"
    echo -e "  remoteinfo → Show remotes and upstream"

    echo -e "\n[ Logs / Diffs / Show ]"
    echo -e "  gl  → Pretty log"
    echo -e "  gll → Detailed log"
    echo -e "  gsh → Show latest commit"
    echo -e "  gd  → Diff unstaged"
    echo -e "  gds → Diff staged"

    echo -e "\n[ Branch Management / Rebase / Reset ]"
    echo -e "  gbdl      → Delete branch locally"
    echo -e "  gbdr      → Delete branch remotely"
    echo -e "  gbll      → List local branches"
    echo -e "  gblr      → List remote branches"
    echo -e "  gbrl      → Rename branch"
    echo -e "  gcr       → Rebase last 5 commits interactively"
    echo -e "  gra       → Abort rebase"
    echo -e "  grc       → Continue rebase"
    echo -e "  gundo     → Undo last commit (keep staged)"
    echo -e "  gundoh    → Undo last commit (unstage)"
    echo -e "  gundoall  → Undo last commit (discard changes)"

    echo -e "\n[ Stash ]"
    echo -e "  gstash   → Save stash"
    echo -e "  gstashm  → Save stash with message"
    echo -e "  gstashl  → List stash"
    echo -e "  gstasha  → Apply latest stash"
    echo -e "  gstashp  → Pop latest stash"
    echo -e "  gstashd  → Drop stash by ID"

    echo -e "\n[ File / Directory ]"
    echo -e "  guntrack → Stop tracking file"
    echo -e "  cdmenu   → Interactive directory select"

    echo -e "\n💡 Tip: Run ghelp anytime to recall these shortcuts!\n"
}

# ================================
# Prompt
# ================================
parse_git_branch() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    status=$(git status --porcelain 2>/dev/null)
    if [ -n "$branch" ]; then
        if [ -n "$status" ]; then
            echo "($branch*)"
        else
            echo "($branch)"
        fi
    fi
}
export PS1="\[\e[1;32m\]\u@\h \[\e[1;34m\]\w\[\e[0m\]\[\e[1;33m\]\$(parse_git_branch)\[\e[0m\] \$ "

# ================================
# Startup: CD to Git Workspace
# ================================
echo "CD to your GIT workspace"
cd ~/Desktop/GIT/
cdmenu
echo "ghelp - for additional helper functions"

