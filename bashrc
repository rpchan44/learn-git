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
# 📖 Helper: ghelp (colorized)
# ================================
ghelp() {
    echo -e "\n\e[1;32m🌱 Git Helper Commands\e[0m\n"

    echo -e "\e[1;32m[ Status / Stage / Commit / Push ]\e[0m"
    echo -e "  \e[1;36mgbs\e[0m      → Branch Status"
    echo -e "  \e[1;36mga\e[0m       → Stage files"
    echo -e "  \e[1;36mgau\e[0m      → Unstage files"
    echo -e "  \e[1;36mgc\e[0m       → Commit with plain message"
    echo -e "  \e[1;36mgcp\e[0m      → Commit with branch-aware prefix"
    echo -e "  \e[1;36mgp\e[0m       → Push branch to remote"
    
    echo -e "\n\e[1;32m[ Branch Checkout / Switch ]\e[0m"
    echo -e "  \e[1;36mgco\e[0m      → Checkout branch: gco [-p] <branch-name>"
    echo -e "  \e[1;36mgcb\e[0m      → Interactive branch selector"
    echo -e "  \e[1;36mgrebase_main\e[0m → Rebase current branch onto main (-p to pull main first)"

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

    echo -e "\n\e[1;32m[ Rebasing / Resetting ]\e[0m"
    echo -e "  \e[1;36mgcr\e[0m      → Rebase last 5 commits interactively"
    echo -e "  \e[1;36mgra\e[0m      → Abort rebase"
    echo -e "  \e[1;36mgrc\e[0m      → Continue rebase"
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

    echo -e "\n\e[1;32m[ Directory Helper ]\e[0m"
    echo -e "  \e[1;36mcdmenu\e[0m   → Interactive directory selector"

    echo -e "\n\e[1;32m[ Remote / Upstream Helper ]\e[0m"
    echo -e "  \e[1;36msetremote\e[0m → Add or update a remote URL"
    echo -e "  \e[1;36mpushup\e[0m    → Push current branch and set upstream"
    echo -e "  \e[1;36mghcreate\e[0m  → Create GitHub repo and push"
    echo -e "  \e[1;36mremoteinfo\e[0m → Show remotes and upstream info"

    echo -e "\n💡 Tip: Run \e[1;36mghelp\e[0m anytime to recall these shortcuts!\n"
}

# ================================
# 📂 Directory Menu Helper
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
# 🌱 Start-up: CD to Git Workspace
# ================================
echo "CD to your GIT workspace"
cd ~/Desktop/GIT/
cdmenu
echo "ghelp - for additional helper functions"

