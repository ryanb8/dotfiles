#!/usr/bin/env zsh

# Git Clone with organized structure
gclone() {
    local url="$1"
    shift  # Remove URL from args, rest are git clone options

    if [[ -z "$url" ]]; then
        echo "Usage: gclone <repo_url> [git-clone-options...]"
        return 1
    fi

    # Check for --bare flag and warn
    for arg in "$@"; do
        if [[ "$arg" == "--bare" || "$arg" == "-bare" ]]; then
            echo "Error: --bare conflicts with this workflow (expects full clones)"
            echo "Use 'git clone --bare --run-raw-clone' directly if you really need a bare repo"
            return 1
        fi
    done

    # Parse the URL to extract host, org, and repo
    local host org repo

    # SSH format: git@github.com:org/repo.git
    if [[ "$url" =~ ^git@([^:]+):(.+)/([^/]+)(\.git)?$ ]]; then
        host="${match[1]}"
        org="${match[2]}"
        repo="${match[3]}"
    # HTTPS format: https://github.com/org/repo.git
    elif [[ "$url" =~ ^https?://([^/]+)/(.+)/([^/]+)(\.git)?$ ]]; then
        host="${match[1]}"
        org="${match[2]}"
        repo="${match[3]}"
    else
        echo "Error: Unable to parse URL: $url"
        echo "Expected format:"
        echo "  SSH: git@host.com:org/repo.git"
        echo "  HTTPS: https://host.com/org/repo.git"
        echo ""
        echo "Please update the regex in gclone() to support this URL format"
        return 1
    fi

    # Remove .git suffix if present
    repo="${repo%.git}"

    # Simplify host (remove www., convert to simple name)
    host="${host#www.}"
    # NOTE: Using first part of hostname only (github.com -> github)
    # Risk: Different hosts with same prefix collide (e.g., github.com and github.enterprise.corp)
    # Acceptable for personal use with public hosts; avoid for environments with multiple private Git hosts
    host="${host%%.*}"  # Take first part: github.com -> github

    local target_dir="$HOME/src/$host/$org/$repo"

    # Check if already cloned
    if [[ -d "$target_dir" ]]; then
        echo "Already cloned at: $target_dir"
        echo "cd-ing to location"
        cd "$target_dir"
        return 0
    fi

    # Create parent directories
    mkdir -p "$(dirname "$target_dir")"

    # Clone the repo with any additional options
    echo "Cloning to: $target_dir"
    git clone "$@" "$url" "$target_dir"
}
alias gitclone=gclone

# Zsh completion for gclone - delegates to git clone completion
_gclone() {
    # Set up completion context to look like git clone
    local -a git_args
    git_args=(clone "${words[@]:1}")

    # Use git's completion system
    _git-clone
}

compdef _gclone gclone

# Override git command to intercept clone
git() {
    if [[ "$1" == "clone" ]]; then
        shift  # remove 'clone'

        # Check for --run-raw-clone flag or GIT_CLONE_RAW env var
        local run_raw=false
        local -a args

        if [[ -n "$GIT_CLONE_RAW" ]]; then
            run_raw=true
        fi

        for arg in "$@"; do
            if [[ "$arg" == "--run-raw-clone" ]]; then
                run_raw=true
            else
                args+=("$arg")
            fi
        done

        if [[ "$run_raw" == "true" ]]; then
            echo "Running raw git clone..."
            command git clone "${args[@]}"
        else
            gclone "${args[@]}"
        fi
    else
        # Pass through all other git commands
        command git "$@"
    fi
}

# Completion for git wrapper
_git_wrapper() {
    if [[ "${words[2]}" == "clone" ]]; then
        # Use gclone completion for git clone
        words[1]=gclone
        _gclone
    else
        # Use standard git completion for everything else
        _git
    fi
}

compdef _git_wrapper git

# === Git worktree management ===
# ASSUMPTION: These functions opinionatedly clone and create worktrees for git.
# They are organizes them in ~/src/<host>/<org>/<repo> structure.
# Worktres are created under ~/src/<host>/<org>/worktrees/<repo>/<worktree-name>
# They may not work correctly for repos cloned using standard git clone or worktrees in other locations.

# Create a new worktree for the current repo.
gwt-new() {
    local worktree_name="$1"
    local branch_name="${2:-$worktree_name}"  # Default to worktree name
    local base_branch="${3:-HEAD}"             # Default to current branch

    if [[ -z "$worktree_name" ]]; then
        echo "Usage: gwt-new <worktree-name> [new-branch] [base-branch]"
        echo ""
        echo "Defaults:"
        echo "  new-branch:  same as worktree-name"
        echo "  base-branch: current branch (HEAD)"
        echo ""
        echo "Examples:"
        echo "  gwt-new my-feature                 # Worktree + branch 'my-feature' from current"
        echo "  gwt-new wt-dir my-branch           # Worktree 'wt-dir', branch 'my-branch'"
        echo "  gwt-new wt-dir my-branch main      # Explicitly base on 'main'"
        return 1
    fi

    # Find the git repo root
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

    if [[ -z "$repo_root" ]]; then
        echo "Error: Not inside a git repository"
        return 1
    fi

    # Extract repo info from path
    # Expected format: ~/src/<host>/<org>/<repo>
    local rel_path="${repo_root#$HOME/src/}"
    local path_parts=("${(@s:/:)rel_path}")

    if [[ ${#path_parts[@]} -lt 3 ]]; then
        echo "Error: Repository not in expected format ~/src/<host>/<org>/<repo>"
        echo "Current path: $repo_root"
        return 1
    fi

    local host="${path_parts[1]}"
    local org="${path_parts[2]}"
    local repo="${path_parts[3]}"

    local worktree_dir="$HOME/src/$host/$org/worktrees/$repo/$worktree_name"

    if [[ -d "$worktree_dir" ]]; then
        echo "Error: Worktree already exists at $worktree_dir"
        return 1
    fi

    # Create worktree directory structure
    mkdir -p "$(dirname "$worktree_dir")"

    # Create the worktree with new branch based on base branch
    echo "Creating worktree: $worktree_dir"
    echo "New branch: $branch_name (based on $base_branch)"
    git worktree add -b "$branch_name" "$worktree_dir" "$base_branch"
}

# List worktrees for current repo
gwt-list() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

    if [[ -z "$repo_root" ]]; then
        echo "Error: Not inside a git repository"
        return 1
    fi

    echo "Worktrees:"
    echo ""

    # Get all worktrees from git
    #TODO - I haven't double checked claude's awk here.
    git worktree list --porcelain | awk '
        /^worktree / {
            path = substr($0, 10)
            n = split(path, parts, "/")
            name = parts[n]
        }
        /^branch / {
            branch = substr($0, 8)
            gsub(/^refs\/heads\//, "", branch)
        }
        /^detached/ {
            branch = "(detached)"
        }
        /^$/ {
            if (path) {
                printf "  %-20s %-30s %s\n", name, branch, path
            }
            path = ""; branch = ""; name = ""
        }
    '
}

# Change to a worktree directory
cdwt() {
    local target="$1"

    if [[ -z "$target" ]]; then
        echo "Usage: cdwt <worktree-name>"
        return 1
    fi

    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

    if [[ -z "$repo_root" ]]; then
        echo "Error: you're not inside a git repo or a worktree"
        return 1
    fi

    # If target contains /, treat as full path
    if [[ "$target" == */* ]]; then
        if [[ -d "$target" ]]; then
            cd "$target"
        else
            echo "Error: Directory not found: $target"
            return 1
        fi
        return 0
    fi

    # Extract worktree paths and match on basename
    local -a matches
    matches=($(git worktree list --porcelain | awk -v target="$target" '
        /^worktree / {
            path = substr($0, 10)
            n = split(path, parts, "/")
            name = parts[n]
            if (name == target) {
                print path
            }
        }
        /^$/ { path = "" }
    '))

    if [[ ${#matches[@]} -eq 0 ]]; then
        echo "Error: Worktree '$target' not found"
        echo ""
        echo "Available worktrees:"
        gwt-list
        return 1
    elif [[ ${#matches[@]} -gt 1 ]]; then
        echo "Error: Multiple worktrees named '$target' found:"
        printf '  %s\n' "${matches[@]}"
        return 1
    else
        cd "${matches[1]}"
    fi
}

# Zsh completion for cdwt
_cdwt() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

    if [[ -z "$repo_root" ]]; then
        return 0
    fi

    # Get all worktree basenames from git
    local -a worktrees
    worktrees=($(git worktree list --porcelain | awk '
        /^worktree / {
            path = substr($0, 10)
            n = split(path, parts, "/")
            name = parts[n]
            print name
        }
    '))

    _describe 'worktree' worktrees
}

compdef _cdwt cdwt

# Zsh completion for gwt-new
_gwt-new() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

    if [[ -z "$repo_root" ]]; then
        return 0
    fi

    case $CURRENT in
        2)
            # First arg: worktree name - no completion (user types it)
            _message 'worktree name'
            ;;
        3)
            # Second arg: new branch name - show hint but allow free input
            _message 'new branch name (defaults to worktree name)'
            ;;
        4)
            # Third arg: base branch - complete from existing branches
            local -a branches
            branches=($(git branch --format='%(refname:short)' 2>/dev/null))
            _describe 'base branch (defaults to current)' branches
            ;;
    esac
}

compdef _gwt-new gwt-new
