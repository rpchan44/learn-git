# ================================
# 🌱 Git Bash Helper Aliases & Functions
# ================================

# --- Git Basics ---
alias gbs='echo Branch Status; git status'
alias ga='echo Staging files; git add'
alias gau='echo Unstaging files; git reset HEAD'
alias gc='echo Snapshot the branch; git commit -m'
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
alias gundo='echo Undo last commit [keep changes staged]; git reset --soft HEAD~1'
alias gundoh='echo Undo last commit [unstage changes, keep edits]; git reset --mixed HEAD~1'
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
# 📖 Helper: ghelp (colorized)
# ================================
ghelp() {
    echo -e "\n\e[1;32m🌱 Git Helper Commands\e[0m\n"

    echo -e "\e[1;32m[ Status / Stage / Commit / Push ]\e[0m"
    echo -e "  \e[1;36mgbs\e[0m      → Branch Status (git status)"
    echo -e "  \e[1;36mga\e[0m       → Stage files (git add)"
    echo -e "  \e[1;36mgau\e[0m      → Unstage files (git reset HEAD <file>)"
    echo -e "  \e[1;36mgc\e[0m       → Commit with message (git commit -m)"
    echo -e "  \e[1;36mgp\e[0m       → Push branch to remote (git push)"
    
    echo -e "\n\e[1;32m[ Logs / Diffs / Show ]\e[0m"
    echo -e "  \e[1;36mgl\e[0m       → Pretty log (oneline + graph)"
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
    echo -e "  \e[1;36mgstash\e[0m   → Save changes to stash (includes untracked)"
    echo -e "  \e[1;36mgstashm\e[0m  → Save stash with message"
    echo -e "  \e[1;36mgstashl\e[0m  → List stash entries"
    echo -e "  \e[1;36mgstasha\e[0m  → Apply latest stash"
    echo -e "  \e[1;36mgstashp\e[0m  → Pop latest stash (apply + remove)"
    echo -e "  \e[1;36mgstashd\e[0m  → Drop stash by ID"

    echo -e "\n\e[1;32m[ File Tracking ]\e[0m"
    echo -e "  \e[1;36mguntrack\e[0m → Stop tracking file but keep locally"

    echo -e "\n\e[1;32m[ Directory Helper ]\e[0m"
    echo -e "  \e[1;36mcdmenu\e[0m   → Interactive directory selector"

    echo -e "\n💡 Tip: Run \e[1;36mghelp\e[0m anytime to recall these shortcuts!\n"
}

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
ghelp

# ================================
# 📂 Directory Menu Helper
# ================================
echo "CD to your GIT workspace"
cd ~/Desktop/GIT/
cdmenu

