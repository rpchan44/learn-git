# ================================
# 🌱 Git Bash Helper Aliases & Functions
# ================================

# --- Git Basics ---
alias gbs='echo Branch Status; git status'
alias ga='echo Staging files; git add'
alias gau='echo Unstaging files; git reset HEAD'
alias gc='echo Snapshot the branch; git commit -m'
alias gcp='echo Commit with branch prefix; gc'
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

    dirty=""
    [ "$staged" -gt 0 ] && dirty+="●"
    [ "$unstaged" -gt 0 ] && dirty+="✗"
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
# 📖 Simplified Colored ghelp
# ================================
ghelp() {
    echo -e "\n\e[1;32m🌱 Git Helper Commands\e[0m\n"

    echo -e "\e[1;32m[ Status / Stage / Commit / Push ]\e[0m"
    echo -e "  \e[1;36mgbs\e[0m      → Branch Status"
    echo -e "  \e[1;36mga\e[0m       → Stage files"
    echo -e "  \e[1;36mgau\e[0m      → Unstage files"
    echo -e "  \e[1;36mgc\e[0m       → Commit with message"
    echo -e "  \e[1;36mgcp\e[0m      → Branch Commit"
    echo -e "  \e[1;36mgp\e[0m       → Push branch to remote"

    echo -e "\n\e[1;32m[ Branch / Checkout / Rebase ]\e[0m"
    echo -e "  \e[1;36mgco\e[0m       → Checkout branch"
    echo -e "  \e[1;36mgco -p\e[0m    → Checkout and pull"
    echo -e "  \e[1;36mgcb\e[0m      → Interactive Checkout"
    echo -e "  \e[1;36mgrebase_main\e[0m → Rebase branch onto main"

    echo -e "\n\e[1;32m[ Remote / Upstream ]\e[0m"
    echo -e "  \e[1;36msetremote\e[0m → Set remote URL"
    echo -e "  \e[1;36mpushup\e[0m    → Push branch and set upstream"
    echo -e "  \e[1;36mghcreate\e[0m  → Create GitHub repo and push"
    echo -e "  \e[1;36mremoteinfo\e[0m → Show remotes and upstream info"

    echo -e "\n\e[1;32m[ Logs / Diff / Show ]\e[0m"
    echo -e "  \e[1;36mgl\e[0m       → Pretty log"
    echo -e "  \e[1;36mgll\e[0m      → Detailed log with colors"
    echo -e "  \e[1;36mgsh\e[0m      → Show latest commit"
    echo -e "  \e[1;36mgd\e[0m       → Diff unstaged changes"
    echo -e "  \e[1;36mgds\e[0m      → Diff staged changes"

    echo -e "\n\e[1;32m[ Branch Mgmt / Reset ]\e[0m"
    echo -e "  \e[1;36mgbdl\e[0m     → Delete branch locally"
    echo -e "  \e[1;36mgbdr\e[0m     → Delete branch remotely"
    echo -e "  \e[1;36mgbll\e[0m     → List local branches"
    echo -e "  \e[1;36mgblr\e[0m     → List remote branches"
    echo -e "  \e[1;36mgbrl\e[0m     → Rename branch locally"
    echo -e "  \e[1;36mgcr\e[0m      → Rebase last 5 commits"
    echo -e "  \e[1;36mgra\e[0m      → Abort rebase"
    echo -e "  \e[1;36mgrc\e[0m      → Continue rebase"
    echo -e "  \e[1;36mgundo\e[0m    → Undo last commit (soft)"
    echo -e "  \e[1;36mgundoh\e[0m   → Undo last commit (mixed)"
    echo -e "  \e[1;36mgundoall\e[0m → Undo last commit (hard)"

    echo -e "\n\e[1;32m[ Stash Helpers ]\e[0m"
    echo -e "  \e[1;36mgstash\e[0m   → Save changes to stash"
    echo -e "  \e[1;36mgstashm\e[0m  → Save stash with message"
    echo -e "  \e[1;36mgstashl\e[0m  → List stash entries"
    echo -e "  \e[1;36mgstasha\e[0m  → Apply latest stash"
    echo -e "  \e[1;36mgstashp\e[0m  → Pop latest stash"
    echo -e "  \e[1;36mgstashd\e[0m  → Drop stash by ID"

    echo -e "\n\e[1;32m[ File / Directory ]\e[0m"
    echo -e "  \e[1;36mguntrack\e[0m → Stop tracking file but keep locally"
    echo -e "  \e[1;36mcdmenu\e[0m   → Directory selector"
}

# Scrollable version
ghelp_p() {
    ghelp | less -R
}

