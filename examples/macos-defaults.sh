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
com.apple.finder|FXDefaultSearchScope|string|SCcf|auto|Search the current folder, not the whole Mac. SCcf = current folder
com.apple.finder|ShowPathbar|bool|1|auto|The path bar answers "where am I" without a second click
com.apple.finder|FXPreferredViewStyle|string|Nlsv|auto|List view by default; icon view hides the modification date
NSGlobalDomain|AppleShowAllExtensions|bool|1|auto|Extensions always visible. NOTE: this key lives here, NOT in com.apple.finder
NSGlobalDomain|ApplePressAndHoldEnabled|bool|0|auto|Key repeat instead of the accent popup. Required for editor navigation
NSGlobalDomain|InitialKeyRepeat|int|15|auto|Repeat starts sooner. 15 = 225ms
NSGlobalDomain|KeyRepeat|int|2|auto|And repeats faster. 2 = 30ms
NSGlobalDomain|com.apple.keyboard.fnState|bool|1|auto|F-keys act as F1-F12. Cost: volume and brightness now need fn
com.apple.dock|autohide|bool|1|auto|Reclaims vertical space on a 14-inch display
com.apple.dock|show-recents|bool|0|auto|Recent apps make the Dock jump around; the position is the muscle memory
com.apple.screencapture|location|string|~/Screenshots|auto|Keeps the desktop clean. Reverting means `defaults delete`, not writing the old path
com.apple.screencapture|disable-shadow|bool|1|auto|Window shadows waste half the image width in a document
NSGlobalDomain|AppleLocale|string|en_US@rg=dezzzz|hand|Region stays German (dates, numbers, paper size). A wrong value here turns half the interface around
com.apple.controlcenter|Bluetooth|int|18|hand|Control Centre cannot be steered by defaults; written values are overwritten within seconds
com.apple.symbolichotkeys|AppleSymbolicHotKeys|dict|-|hand|Shortcuts hang off the keyboard layout, not the character. Set in System Settings
com.apple.universalaccess|reduceMotion|bool|1|hand|Accessibility settings are protected; the write is refused without a TCC grant
'

# Things that are not a `defaults` key at all. Reported, never written.
BY_HAND='
chflags nohidden ~/Library|The Library folder is a filesystem flag, not a preference
Rosetta 2 installed|One bundled helper of a third-party app is x86-only; the launch fails with an architecture error without it
Accessibility permission for the window manager|Silently revoked by some macOS updates. Only a keypress proves it
FileVault enabled|Company policy, enforced by the management profile. Listed so its absence is noticed
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
        case "$type" in
            bool)   defaults write "$domain" "$key" -bool "$want" ;;
            int)    defaults write "$domain" "$key" -int "$want" ;;
            string) defaults write "$domain" "$key" -string "$want" ;;
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
