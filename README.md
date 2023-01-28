# Contribution Corner
This is a very simple MacOS menu bar that scrapes a github profile and then uses [AxisContribution]() to display the data.
It is very rudimentary still with *just* enough features that I'm happy using it.

For reporting bugs or feature requests just open an issue or contact me via other channels (link in profile).

## How to use
1. Download the .dmg (or build it yourself with Xcode)
2. Drag it into your Applications folder
4. Run the app
5. Click the icon in the menu bar
6. Click the gear icon to enter your github username
7. Click save
8. Enjoy your pretty contribution graph

## Packages used
* [SwiftSoup ](https://github.com/scinfu/SwiftSoup)
  - A fantastic parser. Used to parse the GitHub HTML to get the contributions data.
* [AxisContribution](https://github.com/jasudev/AxisContribution)
  - Wonderful package by jasudev for displaying the data in a GitHub contribution graph style
* [FluidMenuBarExtra](https://github.com/lfroms/fluid-menu-bar-extra)
  - Great package by lfroms used to get smooth animations when toggling the settings view
