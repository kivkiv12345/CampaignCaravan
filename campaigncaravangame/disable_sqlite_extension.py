#!/usr/bin/env python3

## Mostly sourced from: https://chatgpt.com


from __future__ import annotations


import os
from posixpath import dirname


def remove_editor_plugins_section(file_path: str):
    # Read the content of the file
    with open(file_path, 'r') as file:
        lines = file.readlines()

    # Prepare to store the modified lines
    modified_lines = []
    inside_editor_plugins_section = False
    has_written_plugins_header = False

    # Iterate through the lines and exclude the editor_plugins section
    for line in lines:
        if line.strip() == "[editor_plugins]":
            inside_editor_plugins_section = True
            continue

        # If inside the section and detect the end of it
        if inside_editor_plugins_section:
            if line.strip().startswith("[") and line.strip() != "[editor_plugins]":
                inside_editor_plugins_section = False

        if not inside_editor_plugins_section:
            modified_lines.append(line)
        elif inside_editor_plugins_section and len(line.strip()) and "godot-sqlite" not in line:
            if not has_written_plugins_header:
                modified_lines.append("[editor_plugins]")
            modified_lines.append(line)

    # Write the modified content back to the file
    with open(file_path, 'w') as file:
        file.writelines(modified_lines)

script_dir = dirname(__file__)

# Specify the path to project.godot file
project_godot_path = os.path.join(script_dir, "project.godot")


if __name__ == '__main__':

    # Run the script to remove the section
    remove_editor_plugins_section(project_godot_path)

    print("Removed [editor_plugins] section from project.godot")
