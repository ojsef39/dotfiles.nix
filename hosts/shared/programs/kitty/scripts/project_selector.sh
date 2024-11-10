#!/bin/bash

project_dirs=(~/CodeProjects/github.com/ojsef39 ~/CodeProjects/gitlab.com/ojsef39 ~/.config)

# Display the subfolders of the project directories
projects() {
  for dir in "${project_dirs[@]}"; do
    find "$dir" -maxdepth 1 -type d | tail -n +2 # List subdirectories only, excluding the base directory itself
  done
}

# Select a project directory using fzf
project_selector() {
  local project
  project=$(projects | fzf)

  if [ -n "$project" ]; then
    {
      kitten @ launch --type=tab --cwd="$project"
      echo "Changed to $project"
    } || {
      echo "Failed to change directory to $project"
      exit 1
    }
  else
    echo "No project selected."
  fi
}

project_selector
