# Contribution Corner
This is a very simple MacOS menu bar that scrapes a github profile and then uses [AxisContribution]() to display the data.
It is very rudimentary still with *just* enough features that I'm happy using it.

It works by fetching data every time you click on the icon and display the graph, but you also have a reload button that can trigger a manual refresh.

For reporting bugs or feature requests just open an issue or contact me via other channels (link in profile).

## How to use
1. Download the .app file from the right hand side under 'Releases' or archive it yourself with Xcode after cloning the repository.
2. Drag Contribution Corner.app into your Applications folder
4. Run the app
5. Click the 3x3 square grid icon in the menu bar
6. Click the gear icon to enter your github username
7. Click save
8. Enjoy your pretty contribution graph

## Video/GIF
https://github.com/Lundeful/ContributionCorner/assets/31478985/34625b03-1ef2-49e2-8b48-e37f138c3a94


## Screenshots
![ContributionCornerV1 3-screenshot-1](https://github.com/Lundeful/ContributionCorner/assets/31478985/80209b64-812d-47be-a1ae-d8baa65b6fe4)
![ContributionCornerV1 3-screenshot-2](https://github.com/Lundeful/ContributionCorner/assets/31478985/91f7f3ee-bdd8-4639-9137-48f82772dcf0)


## Supported versions
This app supports MacOS version 12.0 (Monterey) and up.
Launch on startup is supported only from version 13.0 and up.

## Packages used
* [SwiftSoup ](https://github.com/scinfu/SwiftSoup)
  - A fantastic parser. Used to parse the GitHub HTML to get the contributions data.
* [AxisContribution](https://github.com/jasudev/AxisContribution)
  - Wonderful package by jasudev for displaying the data in a GitHub contribution graph style
