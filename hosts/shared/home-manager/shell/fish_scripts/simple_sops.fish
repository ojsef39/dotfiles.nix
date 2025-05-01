#!/usr/bin/env fish

# Global settings
set -g simple_sops_debug 0
set -g simple_sops_quiet 0

# Helper for logging
function __log_debug
    if test $simple_sops_debug -eq 1
        echo "[DEBUG] $argv"
    end
end

function __log_info
    if test $simple_sops_quiet -eq 0
        echo "$argv"
    end
end

function __log_error
    echo "Error: $argv" >&2
end

function __log_success
    if test $simple_sops_quiet -eq 0
        echo "$argv"
    end
end

# 1Password integration for fetching Age key
function simple_sops_get_key
    __log_debug "Fetching SOPS key from 1Password..."

    # Create a secure temporary directory
    set -l tmp_dir (mktemp -d)
    chmod 700 $tmp_dir
    set -l tmp_file "$tmp_dir/age-key.txt"

    # Get the key directly from 1Password
    op item get SOPS_AGE_KEY_FILE --vault Personal --format json | jq -r '.fields[] | select(.label == "text") | .value' >$tmp_file

    # Check if we got anything
    if test -s $tmp_file
        chmod 600 $tmp_file
        set -gx SOPS_AGE_KEY_FILE $tmp_file
        __log_debug "SOPS Age key loaded from 1Password"

        # Register cleanup function to run on shell exit
        function __cleanup_sops_key --on-process-exit %self
            if test -d $tmp_dir
                rm -rf $tmp_dir
                set -e SOPS_AGE_KEY_FILE
                __log_debug "Temporary key removed on exit"
            end
        end

        return 0
    else
        __log_error "Failed to retrieve key from 1Password"
        rm -rf $tmp_dir
        return 1
    end
end

# Clear the key when it's no longer needed
function simple_sops_clear_key
    if set -q SOPS_AGE_KEY_FILE
        set -l tmp_dir (dirname $SOPS_AGE_KEY_FILE)
        if string match -q "/tmp/tmp.*" $tmp_dir
            rm -rf $tmp_dir
        end
        set -e SOPS_AGE_KEY_FILE
        __log_debug "SOPS key removed"
    else
        __log_debug "No SOPS key was set"
    end
end

# Check if key is available or get it
function simple_sops_ensure_key
    # Check if SOPS_AGE_KEY_FILE is already set and valid
    if set -q SOPS_AGE_KEY_FILE; and test -f $SOPS_AGE_KEY_FILE
        # Key exists, check if it's valid
        if grep -q "public key:" $SOPS_AGE_KEY_FILE
            __log_debug "Using existing Age key"
            return 0
        end
    end

    # Get the key from 1Password
    __log_debug "SOPS_AGE_KEY_FILE not set or invalid. Loading from 1Password..."
    simple_sops_get_key
    return $status
end

function simple_sops_help
    echo "Simple SOPS Helper - Making encryption easier"
    echo ""
    echo "Commands:"
    echo "  encrypt [file...]     - Encrypt one or more files with Age"
    echo "  decrypt [file...]     - Decrypt one or more files"
    echo "  edit [file]           - Edit an encrypted file"
    echo "  set-keys [file]       - Choose which keys to encrypt in a YAML file"
    echo "  config                - Show current SOPS configurations"
    echo "  rm [file...]          - Remove files and their SOPS configurations"
    echo "  clean-config          - Clean orphaned rules from SOPS config"
    echo "  get-key               - Load SOPS Age key from 1Password"
    echo "  clear-key             - Remove SOPS key when finished"
    echo "  help                  - Show this help message"
    echo ""
    echo "Options:"
    echo "  --quiet, -q           - Minimal output"
    echo "  --debug, -d           - Show debug information"
    echo "  --stdout              - For decrypt: output to stdout instead of files"
    echo ""
    echo "Examples:"
    echo "  simple_sops -q encrypt config.yaml    # Encrypt quietly"
    echo "  simple_sops encrypt *.yaml            # Encrypt multiple files"
    echo "  simple_sops decrypt secret.yaml --stdout | kubectl apply -f -"
    echo "  simple_sops edit secrets.yaml         # Edit encrypted file"
    echo "  simple_sops config.yaml               # Shorthand for edit"
end

function simple_sops_encrypt
    if test (count $argv) -lt 1
        __log_error "No files specified"
        echo "Usage: simple_sops encrypt [file...]"
        return 1
    end

    # Ensure we have the key from 1Password if needed
    simple_sops_ensure_key || return 1

    # Extract public key from Age key file
    set -l pubkey (grep "public key:" "$SOPS_AGE_KEY_FILE" | cut -d: -f2 | string trim)

    if test -z "$pubkey"
        __log_error "Could not extract public key from $SOPS_AGE_KEY_FILE"
        simple_sops_clear_key
        return 1
    end

    # Process each file
    set -l overall_status 0
    for file in $argv
        # Verify file exists
        if not test -f $file
            __log_error "File not found: $file"
            set overall_status 1
            continue
        end

        # Check if a config file exists
        if test -f ".sops.yaml"
            __log_debug "Using existing SOPS config from .sops.yaml"

            # Check if the config file has a specific rule for this file
            set -l file_name (basename $file)
            if not grep -q "$file_name" .sops.yaml
                __log_info "Adding specific rule for $file_name to .sops.yaml..."

                # Create a temporary file with the new rule
                set -l temp_file (mktemp)

                # Preserve the header comments
                grep "^#" .sops.yaml >$temp_file

                # Start with creation_rules
                echo "creation_rules:" >>$temp_file

                # Add the new rule for this file
                echo "  - path_regex: $file_name" >>$temp_file
                echo "    age: $pubkey" >>$temp_file

                # Check if there's an encrypted_regex in the existing file
                set -l regex (grep "encrypted_regex" .sops.yaml | head -1 | cut -d: -f2- | string trim)
                if test -n "$regex"
                    echo "    encrypted_regex: $regex" >>$temp_file
                end

                # Add all the existing rules
                sed -n '/creation_rules:/,$ p' .sops.yaml | grep -v "^creation_rules:" >>$temp_file

                # Replace the old config file
                mv $temp_file .sops.yaml
            end
        else
            __log_info "Creating SOPS config..."

            # Create a simple config for first file
            set -l file_name (basename $file)
            echo "# SOPS configuration file" >.sops.yaml
            echo "creation_rules:" >>.sops.yaml
            echo "  - path_regex: $file_name" >>.sops.yaml
            echo "    age: $pubkey" >>.sops.yaml

            # Add a wildcard rule for other files
            echo "  - path_regex: .*\\\.(yaml|yml|json)" >>.sops.yaml
            echo "    age: $pubkey" >>.sops.yaml
        end

        # Encrypt the file
        __log_info "Encrypting $file..."

        # Check encryption mode for debug output
        if test $simple_sops_debug -eq 1
            if grep -q encrypted_regex .sops.yaml
                __log_debug "Using selective encryption based on .sops.yaml config."
            else
                __log_debug "Encrypting the entire file."
            end
        end

        # Encrypt in-place without creating backup files
        sops --encrypt --age $pubkey --in-place $file

        if test $status -eq 0
            __log_success "File encrypted successfully: $file"
        else
            __log_error "Failed to encrypt: $file"
            set overall_status 1
        end
    end

    # Clear the key after use
    simple_sops_clear_key

    return $overall_status
end

function simple_sops_decrypt
    if test (count $argv) -lt 1
        __log_error "No files specified"
        echo "Usage: simple_sops decrypt [file...] [--stdout]"
        return 1
    end

    # Ensure we have the key from 1Password if needed
    simple_sops_ensure_key || return 1

    # Check if --stdout was specified
    set -l use_stdout 0
    set -l files

    for arg in $argv
        if test "$arg" = --stdout
            set use_stdout 1
        else
            set -a files $arg
        end
    end

    # If no files after removing --stdout option
    if test (count $files) -lt 1
        __log_error "No files specified"
        simple_sops_clear_key
        return 1
    end

    # Process each file
    set -l overall_status 0

    # If using stdout flag, automatically use stdout mode for all files
    if test $use_stdout -eq 1
        for file in $files
            # Verify file exists
            if not test -f $file
                __log_error "File not found: $file"
                set overall_status 1
                continue
            end

            __log_debug "Decrypting $file to stdout..."
            sops --decrypt $file

            if test $status -ne 0
                __log_error "Failed to decrypt: $file"
                set overall_status 1
            end
        end
    else
        # Interactive mode - ask for choice
        __log_info "How would you like to decrypt file(s)?"
        echo "1. Print to screen/stdout (for piping to commands)"
        echo "2. Decrypt in-place (overwrites the encrypted file)"
        read -p "echo 'Choose option [1-2]: '" -l choice

        # Validate mode
        if test "$choice" != 1 -a "$choice" != 2
            __log_error "Invalid option."
            simple_sops_clear_key
            return 1
        end

        for file in $files
            # Verify file exists
            if not test -f $file
                __log_error "File not found: $file"
                set overall_status 1
                continue
            end

            if test "$choice" = 1
                __log_info "Decrypting $file to stdout..."
                sops --decrypt $file

                if test $status -ne 0
                    __log_error "Failed to decrypt: $file"
                    set overall_status 1
                end
            else
                __log_info "Decrypting $file in-place..."
                sops --decrypt --in-place $file

                if test $status -eq 0
                    __log_success "File decrypted successfully: $file"
                else
                    __log_error "Failed to decrypt: $file"
                    set overall_status 1
                end
            end
        end
    end

    # Clear the key after use
    simple_sops_clear_key

    return $overall_status
end

function simple_sops_edit
    if test (count $argv) -lt 1
        __log_error "No file specified"
        echo "Usage: simple_sops edit [file]"
        return 1
    end

    # Ensure we have the key from 1Password if needed
    simple_sops_ensure_key || return 1

    set -l file $argv[1]

    # Verify file exists
    if not test -f $file
        __log_error "File not found: $file"
        simple_sops_clear_key
        return 1
    end

    # Edit the file
    __log_info "Opening $file for editing..."
    sops $file
    set -l edit_status $status

    # Clear the key after use
    simple_sops_clear_key

    if test $edit_status -eq 0
        __log_success "File edited and saved successfully."
        return 0
    else
        __log_error "Error while editing the file."
        return 1
    end
end

function simple_sops_set_keys
    if test (count $argv) -lt 1
        __log_error "No file specified"
        echo "Usage: simple_sops set-keys [file]"
        return 1
    end

    # Ensure we have the key from 1Password if needed
    simple_sops_ensure_key || return 1

    set -l file $argv[1]

    # Verify file exists
    if not test -f $file
        __log_error "File not found: $file"
        simple_sops_clear_key
        return 1
    end

    # Check file extension
    set -l ext (string match -r '\.([^.]+)$' $file)[2]
    if not string match -q -r 'ya?ml|json' $ext
        __log_error "Only YAML and JSON files are supported"
        simple_sops_clear_key
        return 1
    end

    # Extract public key
    set -l pubkey (grep "public key:" "$SOPS_AGE_KEY_FILE" | cut -d: -f2 | string trim)

    if test -z "$pubkey"
        __log_error "Could not extract public key from $SOPS_AGE_KEY_FILE"
        simple_sops_clear_key
        return 1
    end

    # Options for what keys to encrypt
    __log_info "What do you want to encrypt in this file?"
    echo "1. All values (encrypt entire file)"
    echo "2. Kubernetes secrets (data, stringData, password, token fields)"
    echo "3. Talos configuration secrets (secrets sections, certs, keys)"
    echo "4. Common sensitive data (passwords, tokens, keys, credentials)"
    echo "5. Custom pattern (provide your own regex)"
    read -p "echo 'Choose option [1-5]: '" option

    set -l encrypted_regex

    switch $option
        case 1
            set encrypted_regex ".*"
        case 2
            # Kubernetes-focused pattern
            set encrypted_regex "^(data|stringData|password|token|secret|key|cert|ca.crt|tls)"
        case 3
            # Talos-focused pattern
            set encrypted_regex "^(secrets|privateKey|token|key|crt|cert|password|secret|kubeconfig|talosconfig)"
        case 4
            # General sensitive data
            set encrypted_regex "^(password|token|secret|key|auth|credential|private|apiKey|cert)"
        case 5
            echo "Enter your regex pattern to match keys you want to encrypt:"
            echo "Example: ^(password|api_key|secret)"
            read encrypted_regex
        case "*"
            __log_error "Invalid option."
            simple_sops_clear_key
            return 1
    end

    # Extract the file name for exact matching
    set -l file_name (basename $file)

    # Create or update .sops.yaml
    if test -f ".sops.yaml"
        __log_info "Updating existing SOPS config for $file_name..."

        # Store the existing file content for reference
        set -l existing_content (cat .sops.yaml)

        # Create a temporary file for the new configuration
        set -l temp_file (mktemp)

        # Copy any comment lines from the top of the file
        grep "^#" .sops.yaml >$temp_file 2>/dev/null

        # Start with creation_rules tag
        echo "creation_rules:" >>$temp_file

        # Find existing rule for this file
        set -l file_rule_exists 0
        set -l rule_start_line 0
        set -l rule_end_line 0
        set -l line_number 0

        # Process each line to find and update the rule for this file
        while read -l line
            set line_number (math $line_number + 1)

            # Check if this is the start of a file-specific rule
            if string match -q "*path_regex: $file_name*" $line
                set file_rule_exists 1
                set rule_start_line $line_number
                continue
            end

            # If we're looking for the end of a rule and find a new rule starting
            if test $rule_start_line -gt 0; and string match -q "  - path_*" $line
                set rule_end_line (math $line_number - 1)
                break
            end
        end <.sops.yaml

        # If we found the start but not the end, the rule goes to the end of the file
        if test $rule_start_line -gt 0; and test $rule_end_line -eq 0
            set rule_end_line $line_number
        end

        # Process all rules, modifying or adding our file's rule
        set line_number 0
        set -l in_our_rule 0
        set -l added_our_rule 0

        while read -l line
            set line_number (math $line_number + 1)

            # Skip comments as they were already added
            if string match -q "#*" $line
                continue
            end

            # If this is the creation_rules line, we already added it
            if string match -q "creation_rules:*" $line
                continue
            end

            # Detect if we're entering our rule section
            if string match -q "*path_regex: $file_name*" $line
                # We're in our rule section, add the updated rule
                echo "  - path_regex: $file_name" >>$temp_file
                echo "    age: $pubkey" >>$temp_file
                echo "    encrypted_regex: \"$encrypted_regex\"" >>$temp_file
                set in_our_rule 1
                set added_our_rule 1
                continue
            end

            # If we're still in our rule section, skip lines until we reach the next rule
            if test $in_our_rule -eq 1
                if string match -q "  - path_*" $line
                    set in_our_rule 0
                    echo $line >>$temp_file
                end
                # Skip lines while in our rule
                continue
            end

            # Add our rule before the generic wildcards if this is the first one
            if not string match -q "*path_regex: $file_name*" $line; and string match -q "*path_regex: .*\\.*" $line; and test $added_our_rule -eq 0
                echo "  - path_regex: $file_name" >>$temp_file
                echo "    age: $pubkey" >>$temp_file
                echo "    encrypted_regex: \"$encrypted_regex\"" >>$temp_file
                set added_our_rule 1
            end

            # Copy all other lines
            echo $line >>$temp_file
        end <.sops.yaml

        # If we didn't add our rule yet, add it at the end
        if test $added_our_rule -eq 0
            echo "  - path_regex: $file_name" >>$temp_file
            echo "    age: $pubkey" >>$temp_file
            echo "    encrypted_regex: \"$encrypted_regex\"" >>$temp_file
        end

        # Replace the old config file
        mv $temp_file .sops.yaml
    else
        __log_info "Creating new .sops.yaml file..."

        # Create new config with file-specific rule and wildcard rule
        echo "# SOPS configuration file" >.sops.yaml
        echo "creation_rules:" >>.sops.yaml

        # File-specific rule
        echo "  - path_regex: $file_name" >>.sops.yaml
        echo "    age: $pubkey" >>.sops.yaml
        echo "    encrypted_regex: \"$encrypted_regex\"" >>.sops.yaml

        # General wildcard rule as fallback
        echo "  - path_regex: .*\\\.(yaml|yml|json)" >>.sops.yaml
        echo "    age: $pubkey" >>.sops.yaml
    end

    # Clear the key after use
    simple_sops_clear_key

    __log_success "SOPS config updated for $file_name! Pattern: $encrypted_regex"
    __log_info ""
    __log_info "You can now encrypt your file with:"
    __log_info "  simple_sops encrypt $file"
end

function simple_sops_list_config
    # Don't need the key for this operation

    if not test -f ".sops.yaml"
        __log_error "No SOPS configuration file (.sops.yaml) found in the current directory."
        return 1
    end

    __log_info "Current SOPS configuration:"
    __log_info --------------------------

    # Parse the config file to show rules in a more readable way
    set -l current_rule ""
    set -l current_indent 0

    while read -l line
        # Skip empty lines and comments
        if test -z (string trim $line); or string match -q "#*" $line
            continue
        end

        if string match -q "creation_rules:*" $line
            __log_info "Rules:"
            continue
        end

        if string match -q "  - path_regex: *" $line
            set current_rule (string replace "  - path_regex: " "" $line)
            __log_info ""
            __log_info "File pattern: $current_rule"
            continue
        end

        if string match -q "    age: *" $line
            set keyid (string replace "    age: " "" $line)
            __log_info "  Age key: $keyid"
            continue
        end

        if string match -q "    encrypted_regex: *" $line
            set regex (string replace "    encrypted_regex: " "" $line | tr -d '"')
            __log_info "  Encrypts: $regex"
            continue
        end

        # Other properties
        if string match -q "    *" $line
            set prop (string replace "    " "" $line)
            __log_info "  $prop"
            continue
        end
    end <.sops.yaml

    __log_info ""
    __log_info "This configuration will be used when encrypting files with SOPS."
end

function simple_sops_rm
    if test (count $argv) -lt 1
        __log_error "No files specified"
        echo "Usage: simple_sops rm [file...]"
        return 1
    end

    # Process each file
    set -l overall_status 0
    for file in $argv
        set -l file_name (basename $file)

        # Check if the file exists
        if not test -f $file
            __log_info "Warning: File $file not found."

            echo "Do you want to still check and clean up SOPS configuration for this file? [y/N]"
            read -l confirm

            if test "$confirm" != y -a "$confirm" != Y
                __log_info "Skipping $file..."
                continue
            end
        else
            # Prompt for confirmation
            __log_info "This will remove the file $file and its SOPS configuration."
            echo "Are you sure you want to continue? [y/N]"
            read -l confirm

            if test "$confirm" != y -a "$confirm" != Y
                __log_info "Skipping $file..."
                continue
            end

            # Remove the file
            rm $file
            __log_success "File $file removed."
        end

        # Check if .sops.yaml exists
        if not test -f ".sops.yaml"
            __log_info "No SOPS configuration file found for $file. Nothing to clean up."
            continue
        end

        # Look for config for this file
        if not grep -q "path_regex: $file_name" .sops.yaml
            __log_info "No configuration found for $file_name in .sops.yaml."
            continue
        end

        # Clean up the configuration
        __log_info "Removing configuration for $file_name from .sops.yaml..."

        # Create a temporary file
        set -l temp_file (mktemp)

        # Copy any comment lines from the top of the file
        grep "^#" .sops.yaml >$temp_file 2>/dev/null

        # Start with creation_rules tag
        echo "creation_rules:" >>$temp_file

        # Process all rules, skipping the rule for our file
        set -l in_our_rule 0

        while read -l line
            # Skip comments as they were already added
            if string match -q "#*" $line
                continue
            end

            # If this is the creation_rules line, we already added it
            if string match -q "creation_rules:*" $line
                continue
            end

            # Detect if we're entering our rule section
            if string match -q "*path_regex: $file_name*" $line
                # We're in our rule section, skip it
                set in_our_rule 1
                continue
            end

            # If we're in our rule section and find the start of a new rule, we're out
            if test $in_our_rule -eq 1; and string match -q "  - path_*" $line
                set in_our_rule 0
            end

            # Skip lines while in our rule
            if test $in_our_rule -eq 1
                continue
            end

            # Copy all other lines
            echo $line >>$temp_file
        end <.sops.yaml

        # Replace the old config file
        mv $temp_file .sops.yaml

        __log_success "SOPS configuration for $file_name removed successfully."
    end

    # Check if the file is now empty except for the header after all files processed
    if test -f ".sops.yaml"
        set -l rule_count (grep -c "path_regex:" .sops.yaml)

        if test $rule_count -eq 0
            __log_info "No rules remain in .sops.yaml. Do you want to remove it? [y/N]"
            read -l remove_config

            if test "$remove_config" = y -o "$remove_config" = Y
                rm .sops.yaml
                __log_success ".sops.yaml removed since it no longer contains any rules."
            end
        else
            __log_info "Remaining rules in .sops.yaml: $rule_count"
        end
    end

    return $overall_status
end

function simple_sops_clean_config
    # Check if .sops.yaml exists
    if not test -f ".sops.yaml"
        __log_info "No SOPS configuration file found. Nothing to clean up."
        return 0
    end

    __log_info "Scanning for orphaned rules in .sops.yaml..."

    # Get all file-specific rules (not wildcards)
    set -l rules
    set -l line_number 0
    set -l rule_start 0
    set -l current_file ""
    set -l orphaned_rules 0

    # First pass: identify all file-specific rules and check if files exist
    while read -l line
        set line_number (math $line_number + 1)

        # If line starts a new rule
        if string match -q "  - path_regex: *" $line
            # If it's not a wildcard pattern
            if not string match -q "*path_regex: .*\\\\.*" $line
                # Extract filename
                set current_file (string replace "  - path_regex: " "" $line)

                # Check if the file exists
                if not test -f $current_file
                    __log_info "Orphaned rule found for file: $current_file"
                    set orphaned_rules (math $orphaned_rules + 1)
                    set -a rules $current_file
                end
            end
        end
    end <.sops.yaml

    if test $orphaned_rules -eq 0
        __log_info "No orphaned rules found in .sops.yaml."
        return 0
    end

    # Ask for confirmation
    __log_info "Found $orphaned_rules orphaned rules in .sops.yaml."
    echo "Do you want to remove them? [y/N]"
    read -l confirm

    if test "$confirm" != y -a "$confirm" != Y
        __log_info "Operation cancelled."
        return 1
    end

    # Remove each orphaned rule
    for file in $rules
        __log_info "Removing configuration for $file..."
        simple_sops_rm $file
    end

    __log_success "Cleanup complete."
end

# Main function that controls everything
function simple_sops
    # Parse global options first
    set -g simple_sops_debug 0
    set -g simple_sops_quiet 0

    set -l args
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case -d --debug
                set simple_sops_debug 1
            case -q --quiet
                set simple_sops_quiet 1
            case "*"
                # Not an option, add to arguments
                set -a args $argv[$i]
        end
        set i (math $i + 1)
    end

    # If no arguments left after options, show help
    if test (count $args) -lt 1
        simple_sops_help
        return 0
    end

    # Regular command processing
    switch $args[1]
        case encrypt
            simple_sops_encrypt $args[2..-1]
        case decrypt
            simple_sops_decrypt $args[2..-1]
        case edit
            simple_sops_edit $args[2..-1]
        case set-keys
            simple_sops_set_keys $args[2..-1]
        case list-config config
            simple_sops_list_config
        case rm
            simple_sops_rm $args[2..-1]
        case clean-config
            simple_sops_clean_config
        case get-key
            simple_sops_get_key
        case clear-key
            simple_sops_clear_key
        case help
            simple_sops_help
        case "*"
            # Check if the first parameter is a file that exists
            if test -f $args[1]
                # If it's a file, assume the user wants to edit it
                __log_info "Assuming you want to edit the file $args[1]..."
                simple_sops_edit $args
            else
                __log_error "Unknown command: $args[1]"
                simple_sops_help
                return 1
            end
    end
end
