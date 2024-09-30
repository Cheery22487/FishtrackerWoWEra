# Fishtracker

Fishtracker is a World of Warcraft addon written for the classic era servers that helps track the types and amounts of fish you catch while fishing. It records fish data by zone, season (summer/winter), and time period (night, morning, day, evening), as well as tracking fish catches for both your current session and all-time. Additionally, the addon allows users to toggle chat output to display nothing, current session or all-time fishing data, or both, for each fish caught.

Already available data for catchrates is often inaccurate due to not taking into account the dependency on time and season while fishing. Also the sample size is often very small. This addon attempts to track the fishing data in an organized way to 

## Features
- Tracks fish catches by:
  - Zone (including zones with spaces in their names)
  - Time period: Night (00:00–06:00), Morning (06:00–12:00), Day (12:00–18:00), Evening (18:00–00:00) (Servertime)
  - Season: Summer (March 20–September 22), Winter (September 23–March 19)
- Allows toggling of chat output for:
  - Current session data
  - All-time data
  - Both session and all-time data
  - No output
- Provides slash commands to dump fishing data for specific zones, time periods, and seasons.
- Tracks fish for your current login session and across multiple sessions.

## Ingame Slash Commands

### Set Chat Output Mode
Set how fish-catching data is printed in the chat when fishing:

/Fishtracker setmode <mode>

`<mode>` can be:
- `none`: No chat output
- `session`: Show current session data
- `alltime`: Show all-time data
- `both`: Show both session and all-time data (this is the default mode)

### Dump All-Time Data
Dump fishing data for a specific zone, season, and time period using dump for all-time data and dumpsession for data from the current login session:

/Fishtracker dump <zone> <season> <timePeriod>

For example:

/Fishtracker dump "Stranglethorn Vale" Summer Day

## Installation
1. Download or clone this repository.
2. Create a `Fishtracker` folder in your World of Warcraft `Interface/AddOns/` directory. 
   - The path will be something like `C:\Program Files\World of Warcraft\_classic_era_\Interface\AddOns\` on Windows
3. Move the Fishtracker.lua and Fishtracker.toc files int the Fishtracker folder. It is important that the Folder and the .lua and .toc files have the same Name.
4. Restart your game, relog or type `/reload` in the chat to load the addon.
