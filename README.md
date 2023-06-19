# Contribution Corner
This is a very simple MacOS menu bar that scrapes a github profile and then uses [AxisContribution]() to display the data.
It is very rudimentary still with *just* enough features that I'm happy using it.

For reporting bugs or feature requests just open an issue or contact me via other channels (link in profile).

## How to use
1. Download the .app file from the right hand side under 'Releases' or archive it yourself with Xcode after cloning the repository.
2. Drag Contribution Corner.app into your Applications folder
4. Run the app
5. Click the 3x3 square grid icon in the menu bar
6. Click the gear icon to enter your github username
7. Click save
8. Enjoy your pretty contribution graph

## Screenshots

![SCR-20230128-2qg](https://user-images.githubusercontent.com/31478985/220460863-3f77f9e0-c2bc-44a8-b225-bcebce1e94ef.png)

![SCR-20230128-2qo](https://user-images.githubusercontent.com/31478985/220460875-c42f5a3d-af29-48ad-81ea-5e9e0e5a643c.png)

## Supported versions
This app supports MacOS version 12.0 (Monterey) and up.
Launch on startup is supported only from version 13.0 and up.

## Packages used
* [SwiftSoup ](https://github.com/scinfu/SwiftSoup)
  - A fantastic parser. Used to parse the GitHub HTML to get the contributions data.
* [AxisContribution](https://github.com/jasudev/AxisContribution)
  - Wonderful package by jasudev for displaying the data in a GitHub contribution graph style
