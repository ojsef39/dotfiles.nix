#!/usr/bin/env fish

function update-nix-pullimage
    set -l options (fish_opt -s d -l dry-run --long-only)
    set -l options $options (fish_opt -s a -l all --long-only)
    set -l options $options (fish_opt -s e -l exclude --long-only --required-val)
    argparse $options -- $argv

    set -l dry_run false
    if set -q _flag_dry_run
        set dry_run true
        echo "⚠️  Running in dry-run mode"
    end

    # Handle --all flag
    if set -q _flag_all
        _update_all_pullimages $dry_run $_flag_exclude
        return $status
    end

    # Single file mode
    if test (count $argv) -eq 0
        echo "❌ Usage: update-nix-pullimage [--dry-run] [--all] [--exclude=<files>] <file>" >&2
        echo "  --all: Update all .nix files with pullImage" >&2
        echo "  --dry-run: Preview changes without applying them" >&2
        echo "  --exclude: Comma-separated list of files/dirs to exclude (only with --all)" >&2
        return 1
    end

    set -l file $argv[1]
    _update_single_file $file $dry_run
end

function _update_single_file
    set -l file $argv[1]
    set -l dry_run $argv[2]

    if not test -f $file
        echo "❌ File not found: $file" >&2
        return 1
    end

    # Check if file contains pullImage
    if not grep -q "pullImage" $file
        echo "ℹ️  No pullImage found in $file"
        return 0
    end

    set -l temp_file (mktemp)
    set -l updated false

    cat $file >$temp_file

    # Extract image names
    set -l image_names (grep -A 5 "pullImage" $file | grep "imageName" | sed 's/.*imageName = "\(.*\)";.*/\1/')

    if test (count $image_names) -eq 0
        rm $temp_file
        return 0
    end

    echo "  Found "(count $image_names)" Docker image(s) in $file"

    for image_name in $image_names
        # Extract current metadata
        set -l current_digest (grep -A 5 "imageName = \"$image_name\"" $file | grep "imageDigest" | sed 's/.*imageDigest = "\(.*\)";.*/\1/')
        set -l current_tag (grep -A 5 "imageName = \"$image_name\"" $file | grep "finalImageTag" | sed 's/.*finalImageTag = "\(.*\)";.*/\1/')

        if test -z "$current_tag"
            set current_tag "latest"
        end

        echo "  Fetching metadata for $image_name:$current_tag..."

        # Fetch new metadata
        set -l prefetch_output (nix-shell -p nix-prefetch-docker --run "nix-prefetch-docker --image-name $image_name --image-tag $current_tag --arch amd64 --os linux 2>/dev/null")

        if test $status -ne 0
            echo "  ⚠️  Failed to fetch metadata for $image_name:$current_tag" >&2
            continue
        end

        # Parse new values - extract only the value between quotes, stop at first semicolon
        set -l new_digest (echo $prefetch_output | grep -o 'imageDigest = "[^"]*"' | sed 's/imageDigest = "\(.*\)"/\1/')
        set -l new_hash (echo $prefetch_output | grep -o 'hash = "[^"]*"' | sed 's/hash = "\(.*\)"/\1/')

        if test -z "$new_digest" -o -z "$new_hash"
            echo "  ⚠️  Failed to parse metadata for $image_name" >&2
            continue
        end

        # Check if update needed
        if test "$current_digest" = "$new_digest"
            echo "  ✓ $image_name is up to date"
            continue
        end

        echo "  📦 Updating $image_name"
        echo "    Old digest: $current_digest"
        echo "    New digest: $new_digest"

        if test $dry_run = false
            # Update imageDigest
            sed -i.bak "s|imageDigest = \"$current_digest\"|imageDigest = \"$new_digest\"|g" $temp_file
            # Update sha256 (assumes it's on the next line after imageDigest)
            set -l line_num (grep -n "imageDigest = \"$new_digest\"" $temp_file | head -1 | cut -d: -f1)
            set -l sha_line (math $line_num + 1)
            sed -i.bak "$sha_line s|sha256 = \".*\"|sha256 = \"$new_hash\"|" $temp_file

            set updated true
        end
    end

    if test $updated = true
        mv $temp_file $file
        rm -f $file.bak $temp_file.bak
        echo "  ✅ Updated $file"
        return 0
    else
        rm -f $temp_file $temp_file.bak
        return 1
    end
end

function _update_all_pullimages
    set -l dry_run $argv[1]
    set -l exclude_arg $argv[2]

    # Default exclusions
    set -l exclude_dirs node_modules result ".direnv"
    set -l exclude_files "import.nix" "import-hm.nix" "import-sys.nix" "host-users.nix"

    # Add user exclusions
    if test -n "$exclude_arg"
        for item in (string split ',' $exclude_arg)
            if string match -q "*.nix" $item
                set -a exclude_files $item
            else
                set -a exclude_dirs $item
            end
        end
    end

    # Build find command
    set -l find_cmd "find . -type f -name \"*.nix\""
    for dir in $exclude_dirs
        set find_cmd "$find_cmd -not -path \"*/$dir/*\""
    end

    # Get all nix files
    set -l all_nix_files (eval $find_cmd)

    # Filter excluded files
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
        echo "⚠️  No .nix files found"
        return 1
    end

    echo "ℹ️  Found "(count $nix_files)" .nix files after exclusions"

    set -l updated_files
    set -l files_with_pullimage 0

    # Process files
    for file in $nix_files
        if grep -q "pullImage" $file
            set files_with_pullimage (math $files_with_pullimage + 1)
            echo ""
            echo "📄 Processing $file..."
            if _update_single_file $file $dry_run
                set -a updated_files $file
            end
        end
    end

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 Summary:"
    echo "  Files checked: "(count $nix_files)
    echo "  Files with pullImage: $files_with_pullimage"
    echo "  Files updated: "(count $updated_files)

    if test (count $updated_files) -gt 0
        if test $dry_run = false
            git add $updated_files
            git commit -m "chore(docker): update pullImage hashes" || true
            echo "  ✅ Changes committed"
        else
            echo "  (dry-run mode - no changes made)"
        end
    else
        echo "  ℹ️  No updates needed"
    end
end
