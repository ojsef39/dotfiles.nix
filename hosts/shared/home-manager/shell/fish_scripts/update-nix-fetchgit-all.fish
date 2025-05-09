#!/usr/bin/env fish

function update-nix-fetchgit-all
    set -l options (fish_opt -s d -l dry-run --long-only)
    set -l options $options (fish_opt -s e -l exclude --long-only --required-val)
    argparse $options -- $argv

    set -l dry_run ""
    if set -q _flag_dry_run
        set dry_run -d
        echo "⚠️ Running in dry-run mode"
    end

    # Default exclusion directories
    set -l exclude_dirs node_modules result ".direnv"

    # Default exclusion files
    set -l exclude_files "import.nix" "import-hm.nix" "import-sys.nix" "host-users.nix"

    # Add user-specified exclusions
    if set -q _flag_exclude
        for item in (string split ',' $_flag_exclude)
            # Check if it's likely a directory or a file
            if string match -q "*.nix" $item
                set -a exclude_files $item
            else
                set -a exclude_dirs $item
            end
        end
    end

    # Start with all .nix files
    set -l find_cmd "find . -type f -name \"*.nix\""

    # Add directory exclusions
    for dir in $exclude_dirs
        set find_cmd "$find_cmd -not -path \"*/$dir/*\""
    end

    # Execute find command to get initial file list
    set -l all_nix_files (eval $find_cmd)

    # Filter out specific files
    set -l nix_files
    for file in $all_nix_files
        set -l basename (basename $file)
        set -l exclude false

        for excluded_file in $exclude_files
            if test "$basename" = "$excluded_file"
                set exclude true
                break
            end
        end

        if test $exclude = false
            set -a nix_files $file
        end
    end

    if test (count $nix_files) -eq 0
        echo "⚠️ No .nix files found"
        return 1
    end

    echo "ℹ️ Found "(count $nix_files)" .nix files after exclusions"

    # Run update-nix-fetchgit on each file
    for file in $nix_files
        echo "ℹ️ Processing $file..."
        if test "$dry_run" = -d
            update-nix-fetchgit $dry_run -v $file
        else
            update-nix-fetchgit -v $file
        end
    end
end
