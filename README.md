# Threnty

A minimal macOS menu bar app that reminds you to follow the **20-20-20 rule**: every 20 minutes, look at something 20 meters away for 20 seconds.

## How it works

1. Click the menu bar icon and press **Start**
2. A countdown runs in the menu bar
3. After 20 minutes a sound plays and a full-screen overlay appears on every display
4. The overlay counts down 20 seconds, then dismisses automatically and the cycle restarts
5. Press **Skip** on the overlay or **Stop** in the menu to cancel at any time

## Requirements

- macOS 26.2+

## Build

Open `threnty.xcodeproj` in Xcode and run, or from the terminal:

```bash
xcodebuild build -project threnty.xcodeproj -scheme threnty -configuration Debug
```
