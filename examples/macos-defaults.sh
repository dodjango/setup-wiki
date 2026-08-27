#!/usr/bin/env bash
# The Brewfile equivalent for system settings.
#
# Every row carries the reason next to the value. That is the entire point:
# at a rebuild, after a macOS update, or when a value has drifted, the
# question is not "what was this again" but "do I still want it, given why
# I wanted it".
#
#   ./macos-defaults.sh          read and compare, change nothing (default)
#   ./macos-defaults.sh --set    write every row whose Mode is `auto`
#
# Mode:
#   auto  the script may write it
#   hand  report only — either not a `defaults` key, or wrong values here
#         break enough of the interface that a human should do it
#
# Written for bash 3.2, which is what macOS ships: no associative arrays.
set -uo pipefail

# Domain|Key|Type|Value|Mode|Reason
SETTINGS='
NSGlobalDomain|KeyRepeat|int|2|auto|Fastest repeat rate -- cursor navigation in the editor
NSGlobalDomain|InitialKeyRepeat|int|15|auto|Short delay before the repeat starts, same reason
NSGlobalDomain|ApplePressAndHoldEnabled|bool|0|auto|No accent popup on hold: otherwise jjjj in vim shows accents instead of repeating
NSGlobalDomain|AppleKeyboardUIMode|int|3|auto|Tab reaches every control -- dialogs usable without the mouse
NSGlobalDomain|com.apple.keyboard.fnState|bool|1|auto|F-keys act as F1-F12: F2 renames. Cost: volume and brightness now need fn
NSGlobalDomain|NSAutomaticQuoteSubstitutionEnabled|bool|0|auto|Typographic quotes wreck code and commit messages
NSGlobalDomain|NSAutomaticDashSubstitutionEnabled|bool|0|auto|Dash substitution, same reason
NSGlobalDomain|NSAutomaticSpellingCorrectionEnabled|bool|0|auto|Autocorrect, same reason
NSGlobalDomain|NSAutomaticCapitalizationEnabled|bool|0|auto|Capitalisation at the start of a sentence, same reason
NSGlobalDomain|AppleShowAllExtensions|bool|1|auto|Extensions always visible. NOTE: this key lives here, NOT in com.apple.finder
com.apple.finder|ShowPathbar|bool|1|auto|Path bar -- Windows Explorer behaviour
com.apple.finder|ShowStatusBar|bool|1|auto|Status bar, same reason
com.apple.finder|FXPreferredViewStyle|string|Nlsv|auto|List view by default (Nlsv = list view)
com.apple.finder|_FXSortFoldersFirst|bool|1|auto|Folders before files, as in Explorer
com.apple.finder|FXDefaultSearchScope|string|SCcf|auto|Search the current folder, not the whole Mac (SCcf = current folder)
com.apple.finder|FXEnableExtensionChangeWarning|bool|0|auto|No confirmation dialog when changing a file extension
com.apple.finder|QuitMenuItem|bool|1|auto|Cmd-Q quits the Finder -- otherwise impossible on macOS
com.apple.dock|show-recents|bool|0|auto|No recent applications in the Dock -- they make it jump around
com.apple.dock|autohide-delay|float|0|auto|Show the Dock without a delay
com.apple.dock|autohide-time-modifier|float|0.15|auto|And quickly, not instantly -- 0 looks jerky
com.apple.dock|mru-spaces|bool|0|auto|Stops the desktops reordering by most recent use. Three fixed desktops depend on it
com.apple.WindowManager|EnableStandardClickToShowDesktop|bool|1|auto|Click on the background moves windows aside. Apple flipped this default itself, see the note
com.apple.WindowManager|GloballyEnabled|bool|0|auto|Stage Manager off
com.apple.screencapture|disable-shadow|bool|1|auto|Screenshots without a drop shadow -- the border wastes half the width in a document
com.apple.desktopservices|DSDontWriteNetworkStores|bool|1|auto|No .DS_Store on network shares -- otherwise litter on the company file server
NSGlobalDomain|NSWindowResizeTime|float|0.05|auto|Faster window animations
NSGlobalDomain|AppleLanguages|array|en-US de-DE|hand|Interface in English: error messages and support articles are English. You will not find "Bedienungshilfen" in them, "Accessibility" you will
NSGlobalDomain|AppleLocale|string|en_US@rg=dezzzz|hand|Region stays German (dates, numbers, paper size). A wrong value here turns half the interface around -- by hand only
'

# Not reachable through `defaults` at all. Reported, never written, so they are
# not forgotten at a rebuild.
BY_HAND='
chflags nohidden ~/Library|Makes ~/Library permanently visible (the equivalent of %APPDATA%). A filesystem flag, not a preference
System Settings > Control Centre|Take Focus and Wi-Fi out of the menu bar. Values written by defaults are overwritten within seconds; tested unsuccessfully in both orderings
Right-click a Dock icon > Options > Assign To|Pin the mail client and the terminal to their fixed desktops
Rosetta 2 installed|One bundled helper of a third-party app was x86-only and its launch failed with an architecture error. See apps/kap.md
'

set_mode=0
[ "${1:-}" = "--set" ] && set_mode=1

managed=""
if [ -d "/Library/Managed Preferences" ]; then
    managed="$(ls "/Library/Managed Preferences" 2>/dev/null | sed 's/\.plist$//')"
fi

drift=0
printf '%s\n' "$SETTINGS" | while IFS='|' read -r domain key type want mode reason; do
    [ -z "${domain:-}" ] && continue

    # A managed domain wins over anything written here. That is a policy,
    # not a malfunction — report it and move on.
    if printf '%s\n' "$managed" | grep -qx "$domain"; then
        printf '%-58s managed by policy — skipped\n' "$domain $key"
        continue
    fi

    have="$(defaults read "$domain" "$key" 2>/dev/null)" || have="<unset>"

    if [ "$have" = "$want" ]; then
        printf '%-58s ok\n' "$domain $key"
        continue
    fi

    drift=1
    printf '%-58s want %-22s have %s\n' "$domain $key" "$want" "$have"
    printf '   why: %s\n' "$reason"

    if [ "$mode" = "hand" ]; then
        printf '   mode: hand — not written by this script\n'
        continue
    fi

    if [ "$set_mode" = "1" ]; then
        # shellcheck disable=SC2086
        case "$type" in
            bool)   defaults write "$domain" "$key" -bool "$want" ;;
            int)    defaults write "$domain" "$key" -int "$want" ;;
            float)  defaults write "$domain" "$key" -float "$want" ;;
            string) defaults write "$domain" "$key" -string "$want" ;;
            # Deliberately unquoted: an array value is a list of words.
            array)  defaults write "$domain" "$key" -array $want ;;
            *)      printf '   unknown type %s — skipped\n' "$type"; continue ;;
        esac
        printf '   set. Note the way back: '
        if [ "$have" = "<unset>" ]; then
            printf 'defaults delete %s %s\n' "$domain" "$key"
        else
            printf 'defaults write %s %s -%s %s\n' "$domain" "$key" "$type" "$have"
        fi
    fi
done

printf '\nNot preferences — check these by hand:\n'
printf '%s\n' "$BY_HAND" | while IFS='|' read -r what why; do
    [ -z "${what:-}" ] && continue
    printf '  %-46s %s\n' "$what" "$why"
done

printf '\nAfter writing: killall Finder Dock — a written value is not an applied value.\n'
