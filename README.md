# Fishtracker

Fishtracker is a World of Warcraft addon written for the classic era servers that helps track the types and amounts of fish you catch while fishing. It records fish data by zone, season (summer/winter), and time period (night, morning, day, evening), as well as tracking fish catches for both your current session and all-time. Additionally, the addon allows users to toggle chat output to display nothing, current session, all-time fishing data or both, for each fish caught.

Current available catch rate data is often unreliable as it fails to account for the impact of time and season on fishing. In addition, the sample size is frequently very limited. This addon seeks to systematically track fishing data to deliver more accurate estimates of the catch rates for specific fish.

## Features
- Tracks fish catches by:
  - Zone
  - Time period: Night (00:00–06:00), Morning (06:00–12:00), Day (12:00–18:00), Evening (18:00–00:00) (Servertime)
  - Season: Summer (March 20–September 22), Winter (September 23–March 19)
- Allows toggling different chat output options:
  - Current session data
  - All-time data
  - Both session and all-time data
  - No output
- Provides slash commands to dump fishing data for specific zones, time periods, and seasons.
- Tracks fish for your current login session and across multiple sessions.

## Ingame Slash Commands

### Set Chat Output Mode
Set how fish-catching data is printed in the chat when fishing:

/Fishtracker setmode `<mode>`

`<mode>` can be:
- `none`: No chat output
- `session`: Show current session data
- `alltime`: Show all-time data
- `both`: Show both session and all-time data (this is the default mode)

### Dump All-Time Data
Dump fishing data for a specific zone, season, and time period using `<dump>` for all-time data and `<dumpsession>` for data from the current login session:

/Fishtracker dump `<zone>` `<season>` `<timePeriod>`

For example:

/Fishtracker dump Stranglethorn Vale Summer Day

Capitalization in correct spelling is important!

## Installation
1. Download or clone this repository.
2. Create a `Fishtracker` folder in your World of Warcraft `Interface/AddOns/` directory. 
   - The path will be something like `C:\Program Files\World of Warcraft\_classic_era_\Interface\AddOns\` on Windows
3. Move the Fishtracker.lua and Fishtracker.toc files into the Fishtracker folder. It is important that the Folder and the .lua and .toc files have the same name.
4. Restart your game, relog or type `/reload` in the chat to load the addon.
