# ![Icon](icon.png) Kazooey
A library for Godot that creates chirpy voices from a sound bank.

## Usage
Kazooey is a modification of the AudioEmitter class, which when sent a signal containing a line of dialog will read it out using randomly selected chirps (voice samples) from a pocket (subfolder) in its bag (specific folder).

Example crow sound files are provided, showing the required folder structure of Kazooey.

## Folder Structure
Kazooey requires a folder named `bag` to be present somewhere under the resources. The bag must contain uniquely named pockets for each voice available in the game. All samples in the folder must be provided as `i.wav`, where `1 ≤ i ≤ n`.

## Instantiating
A new instance of Kazooey is created by attaching it to an AudioEmitter. The base director for Kazooey (the directory containing `bag`) must be provided as a property, as well as the name of the pocekt that Kazooey will draw from when speaking.

## Credits
Created by [Luna Lapin](https://www.shadenexus.com) during [AdventureJam 2020](https://jams.gamejolt.io/advjam2020)
