@echo off
echo ========================================
echo    Asteroids Game - Create Source ZIP
echo ========================================
echo.

echo Creating source code archive for developers...
echo.

REM Create temporary directory for source archive
if exist "Asteroids_Source_Temp" rmdir /s /q "Asteroids_Source_Temp"
mkdir "Asteroids_Source_Temp"

REM Copy source files
echo Copying source files...
copy "Game.cpp" "Asteroids_Source_Temp\"
copy "Engine.cpp" "Asteroids_Source_Temp\"
copy "Engine.h" "Asteroids_Source_Temp\"
copy "GameTemplate.sln" "Asteroids_Source_Temp\"
copy "GameTemplate.vcxproj" "Asteroids_Source_Temp\"
copy "GameTemplate.vcxproj.filters" "Asteroids_Source_Temp\"
copy "README.md" "Asteroids_Source_Temp\"
copy ".gitignore" "Asteroids_Source_Temp\"

REM Create build instructions
echo ======================================== > "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo    ASTEROIDS GAME - BUILD INSTRUCTIONS >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo ======================================== >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo. >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo REQUIREMENTS: >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Visual Studio 2019 or later >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Windows 10/11 >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo. >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo HOW TO BUILD: >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo 1. Open GameTemplate.sln in Visual Studio >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo 2. Select Release configuration (for best performance) >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo 3. Build the solution (Ctrl+Shift+B) >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo 4. Run GameTemplate.exe from x64\Release\ folder >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo. >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo PROJECT STRUCTURE: >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Engine.h/cpp: Game engine (window, input, rendering) >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Game.cpp: Main game logic (Asteroids implementation) >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - GameTemplate.sln: Visual Studio solution file >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - GameTemplate.vcxproj: Project file >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo. >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo FEATURES: >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Pixel-based rendering (32-bit BGRA buffer) >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Vector mathematics for physics >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Custom text rendering system >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Dynamic object management >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Screen wrapping mechanics >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo. >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo GAME MECHANICS: >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Ship rotation: 20 radians/second >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Ship acceleration: 200 pixels/second^2 >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Ship max speed: 500 pixels/second >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Ship braking: 0.5%% per frame >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Asteroid speed: 17-33 pixels/second >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Asteroid size: 15-30 pixels >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo - Initial asteroids: 12 >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo. >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"
echo Enjoy developing! >> "Asteroids_Source_Temp\BUILD_INSTRUCTIONS.txt"

REM Create ZIP archive
echo Creating source ZIP archive...
powershell -command "Compress-Archive -Path 'Asteroids_Source_Temp\*' -DestinationPath 'Asteroids_Game_Source_v1.0.zip' -Force"

if %errorlevel% equ 0 (
    echo Source ZIP archive created successfully!
    echo.
    
    REM Clean up temporary directory
    rmdir /s /q "Asteroids_Source_Temp"
    
    echo ========================================
    echo    SUCCESS! Source Archive Created
    echo ========================================
    echo.
    echo Archive: Asteroids_Game_Source_v1.0.zip
    echo Size: 
    dir "Asteroids_Game_Source_v1.0.zip" | findstr "Asteroids_Game_Source_v1.0.zip"
    echo.
    echo Contents:
    echo - Game.cpp (main game logic)
    echo - Engine.cpp/h (game engine)
    echo - GameTemplate.sln (Visual Studio solution)
    echo - GameTemplate.vcxproj (project file)
    echo - README.md (detailed documentation)
    echo - BUILD_INSTRUCTIONS.txt (how to compile)
    echo - .gitignore (Git ignore file)
    echo.
    echo This archive is for developers who want to:
    echo - Study the code
    echo - Modify the game
    echo - Compile it themselves
    echo.
) else (
    echo Failed to create source ZIP archive.
    echo Please try again or create manually.
    echo.
)

echo Press any key to exit...
pause >nul
