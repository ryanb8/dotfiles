if [[ "$OSTYPE" == "darwin"* ]]; then
    show_files_on=$(defaults read com.apple.Finder AppleShowAllFiles)

    # Need to make these functions so they can be aliased AND called below
    showfilesfunc() {
        defaults write com.apple.Finder AppleShowAllFiles YES
        killall Finder /System/Library/CoreServices/Finder.app
    }

    hidefilesfunc() {
        defaults write com.apple.Finder AppleShowAllFiles NO
        killall Finder /System/Library/CoreServices/Finder.app
    }

    alias showfiles='showfilesfunc'
    alias hidefiles='hidefilesfunc'
    if [[ -z "$show_files_on" || "$show_files_on" != "YES" ]]; then
        echo "Turning show files on for mac"
        showfilesfunc
    fi
fi
