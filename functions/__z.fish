function __z -d "Jump to a recent directory."
    set -l option
    set -l arg
    set -l typ ''
    set -l list
    set -g z_path (command dirname (status -f))
    set -l target

    getopts $argv | while read -l 1 2
        switch $1
            case c clean
                __z_clean
                printf "%s cleaned!" $Z_DATA
                return 0
            case p purge
                echo >$Z_DATA
                printf "%s purged!" $Z_DATA
                return 0
            case e echo
                set option "ech"
                set arg "$2"
                break
            case l list
                set list "list"
                set arg "$2"
                break
            case r rank
                set typ "rank"
                set arg "$2"
                break
            case t recent
                set typ "recent"
                set arg "$2"
                break
            case _
                set arg "$2"
                break
            case h help
                printf "Usage: $Z_CMD  [-celrth] dir\n\n"
                printf "         -c --clean    Cleans out $Z_DATA\n"
                printf "         -e --echo     Prints best match, no cd\n"
                printf "         -l --list     List matches, no cd\n"
                printf "         -p --purge    Purges $Z_DATA\n"
                printf "         -r --rank     Search by rank, cd\n"
                printf "         -t --recent   Search by recency, cd\n"
                printf "         -h --help     Print this help\n\n"
                printf "If installed with fisherman, run `fisher help z` for more info"
                return 0
            case \*
                printf "$Z_CMD: '%s' is not a valid option\n" $1
                __z --help
                return 1
        end
    end

    if test "$list" = "list"
        # Handle list separately as it can print common path information to stderr
        # which cannot be captured from a subcommand.
        command awk -v t=(date +%s) -v list="$list" -v typ="$typ" -v q="$arg" -F "|" -f $z_path/z.awk "$Z_DATA"
    else
        set target (command awk -v t=(date +%s) -v typ="$typ" -v q="$arg" -F "|" -f $z_path/z.awk "$Z_DATA")

        if test "$status" -gt 0
            return
        end

        if test -z "$target"
            printf "'%s' did not match any results" "$arg"
            return 1
        end

        if test "$option" = "ech"
            printf "%s\n" "$target"
        else
            pushd "$target"
        end
    end
end
