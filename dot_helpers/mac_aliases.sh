if [[ "$OSTYPE" == "darwin"* ]]; then
    show_files_on=$(defaults read com.apple.finder AppleShowAllFiles)
    alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
    alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
    if [[ "$show_files_on" != "YES" ]]; then
        echo "Turning show files on for mac"
        echo "This seems inconsistent; may need to be run manually"
        showfiles
    fi
fi