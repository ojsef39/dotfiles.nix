# Completion for simple_sops
# Save this file to ~/.config/fish/completions/simple_sops.fish

# Define all the subcommands
set -l commands encrypt decrypt edit set-keys config rm clean-config get-key clear-key help

# Define files that can be encrypted/decrypted (YAML and JSON)
function __fish_simple_sops_files
    find . -type f -name "*.yaml" -o -name "*.yml" -o -name "*.json" 2>/dev/null
end

# Define files that are already encrypted
function __fish_simple_sops_encrypted_files
    grep -l "sops:" (__fish_simple_sops_files) 2>/dev/null
end

# Complete subcommands
complete -c simple_sops -f -n "not __fish_seen_subcommand_from $commands" -a encrypt -d "Encrypt files with Age"
complete -c simple_sops -f -n "not __fish_seen_subcommand_from $commands" -a decrypt -d "Decrypt files"
complete -c simple_sops -f -n "not __fish_seen_subcommand_from $commands" -a edit -d "Edit an encrypted file"
complete -c simple_sops -f -n "not __fish_seen_subcommand_from $commands" -a set-keys -d "Choose which keys to encrypt"
complete -c simple_sops -f -n "not __fish_seen_subcommand_from $commands" -a config -d "Show current SOPS configurations"
complete -c simple_sops -f -n "not __fish_seen_subcommand_from $commands" -a rm -d "Remove files and configurations"
complete -c simple_sops -f -n "not __fish_seen_subcommand_from $commands" -a clean-config -d "Clean orphaned rules"
complete -c simple_sops -f -n "not __fish_seen_subcommand_from $commands" -a get-key -d "Load SOPS key from 1Password"
complete -c simple_sops -f -n "not __fish_seen_subcommand_from $commands" -a clear-key -d "Remove SOPS key"
complete -c simple_sops -f -n "not __fish_seen_subcommand_from $commands" -a help -d "Show help message"

# File completions for the shorthand method (when no command is given, assume it's edit)
complete -c simple_sops -f -n "not __fish_seen_subcommand_from $commands && count (commandline -opc) = 1" -a "(__fish_simple_sops_encrypted_files)"

# Global options
complete -c simple_sops -s q -l quiet -d "Minimal output"
complete -c simple_sops -s d -l debug -d "Show debug information"

# Complete file arguments for encrypt (use non-encrypted files)
complete -c simple_sops -f -n "__fish_seen_subcommand_from encrypt" -a "(__fish_simple_sops_files)"

# Complete file arguments for decrypt
complete -c simple_sops -f -n "__fish_seen_subcommand_from decrypt" -a "(__fish_simple_sops_encrypted_files)"
complete -c simple_sops -f -n "__fish_seen_subcommand_from decrypt" -a --stdout -d "Output to stdout"

# Complete file arguments for edit
complete -c simple_sops -f -n "__fish_seen_subcommand_from edit" -a "(__fish_simple_sops_encrypted_files)"

# Complete file arguments for set-keys (any yaml/json files)
complete -c simple_sops -f -n "__fish_seen_subcommand_from set-keys" -a "(__fish_simple_sops_files)"

# Complete file arguments for rm (any yaml/json files)
complete -c simple_sops -f -n "__fish_seen_subcommand_from rm" -a "(__fish_simple_sops_files)"

# No arguments for config, clean-config, get-key, clear-key, or help
complete -c simple_sops -f -n "__fish_seen_subcommand_from config clean-config get-key clear-key help"
