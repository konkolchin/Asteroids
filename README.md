\\\# Asteroids Game

Simple Asteroids game implementation in C++.

## How to Play

- **Arrow Keys**: Turn left/right
- **Up Arrow**: Accelerate
- **Down Arrow**: Slow down
- **Spacebar**: Shoot
- **Enter**: Restart
- **Escape**: Exit

Destroy all asteroids to win. Don't crash into them.

## Build

1. Open `GameTemplate.sln` in Visual Studio
2. Build Release configuration
3. Run `GameTemplate.exe`

## Files

- `Game.cpp` - Game logic
- `Engine.cpp/h` - Engine
- `GameTemplate.sln` - Visual Studio project

## Features

- 3 lives (like original 1979 game)
- Score system:
  - Large asteroids (>25px): 100 points
  - Medium asteroids (15-25px): 50 points  
  - Small asteroids (<15px): 20 points
- Asteroid splitting: Large asteroids split into 2 medium ones when destroyed
- Screen wrapping (objects wrap around screen edges)
- Pixel-based graphics with custom rendering