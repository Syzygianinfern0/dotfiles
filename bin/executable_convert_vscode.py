#!/usr/bin/env python
import json
import sys


def generate_vscode_config(command):
    parts = command.split()
    if parts[0] != "python":
        raise ValueError("This script currently only supports Python commands.")

    script_path = parts[1]

    # Assuming every even part (starting from 2) is an option and the next one is its value
    args = []
    for i in range(2, len(parts), 2):
        option = parts[i]
        # Handle the case where some options might not have a value (e.g. flags)
        try:
            value = parts[i + 1]
        except IndexError:
            value = None

        # If the option doesn't start with '-', consider it as a positional argument
        if not option.startswith("-"):
            args.append(option)
            if value and not value.startswith("-"):
                args.append(value)
        else:
            args.append(option)
            if value and not value.startswith("-"):
                args.append(value)
            else:
                i -= 1  # Adjust loop counter to consider this as a standalone option

    config = {
        "name": "Converted Debug",
        "type": "python",
        "request": "launch",
        "program": "${workspaceFolder}/" + script_path,
        "args": args,
        "console": "integratedTerminal",
    }

    print(json.dumps(config, indent=4))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python convert_to_vscode.py '<your_command>'")
    else:
        command = sys.argv[1]
        generate_vscode_config(command)
