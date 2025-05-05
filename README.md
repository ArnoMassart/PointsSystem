# Points System

A flutter project made for Android mobile design.

This app is made for counting the scores while playing games (mainly board games). The app has a couple functionalities like:
- Creating a new game
- Creating new players to select from
- Select players in the game table from a dropdown
- Enter a score in the game table (negative numbers work too)
- View all the games played
- Edit a certain game

The app has a couple of different pages:
## Homepage: 
- Always first page on startup
- Has a dark mode toggle
- Shows the last saved game

## Games page:
- Shows a list of all the games saved on the device
- Has a filter to search for the name of the game
- Has a filter to search for the players of the game: it will search for all the games where, this person or people if mulitple selected, are a player of
- When clicking on the game it shows the details of the game
- Has a function to delete a game from the device

## Game detail page:
- Has the table of the game
- Has a edit mode where the game can be changed if nescessary

## Players page:
- Shows all the players saved on the device
- Has a function to add a new player to the list
- Has a function to sort alfabetically
- Has a function to delete a player from the device

All data is saved in the SharedPreferences
