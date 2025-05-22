# LmaoGet for Lmaobox

LmaoGet is a Lua package manager for Lmaobox that allows you to easily download, update and manager Lua scripts from inside the game.
Lua developers are able to create manifest files for their repositories and contribute them here.

## Installation

To install LmaoGet, follow these steps:

1. Download the latest `LmaoGet.lua` from the Releases
2. Place the file inside your `%localappdata%` folder
3. Load the script in-game through the "Lua" menu

## Usage

The LmaoGet package manager can be used through the game's console.
Type `lmaoget help` to get a list of available commands and their descriptions.

## Safety

Please note that contributed repositories may **not** be checked thoroughly and can be changed by the authors at any time.
You should **always** check the scripts you're installing, updating or running and make sure they aren't malicious!

## Contributing

Want to add your Lua repository to the package manager? Then follow these steps:

1. Create a `.json` file at the root of your repository, that follows [this](https://raw.githubusercontent.com/lnx00/Lmaobox-LmaoGet/refs/heads/main/repo/example-repo.json) example structure.
2. Add all of your packages to the `packages` field. Make sure that the `url` points to the **raw** Lua file!
3. Create an [Issue](https://github.com/lnx00/Lmaobox-LmaoGet/issues) with a link to your repository json and your desired repository id.

## Credits

- [dkjson](https://dkolf.de/dkjson-lua/)
