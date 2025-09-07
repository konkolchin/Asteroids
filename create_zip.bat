@echo off
echo ========================================
echo    Asteroids Game - Create ZIP Archive
echo ========================================
echo.

REM Check if Visual Studio build exists
if not exist "x64\Release\GameTemplate.exe" (
    echo ERROR: GameTemplate.exe not found!
    echo Please build the project in Visual Studio first:
    echo 1. Open GameTemplate.sln in Visual Studio
    echo 2. Select Release configuration
    echo 3. Build the solution (Ctrl+Shift+B)
    echo.
    pause
    exit /b 1
)

echo Found compiled game! Creating ZIP archive...
echo.

REM Create temporary directory for archive
if exist "Asteroids_Game_Temp" rmdir /s /q "Asteroids_Game_Temp"
mkdir "Asteroids_Game_Temp"

REM Copy game files
echo Copying game files...
copy "x64\Release\GameTemplate.exe" "Asteroids_Game_Temp\"
if exist "x64\Release\GameTemplate.pdb" copy "x64\Release\GameTemplate.pdb" "Asteroids_Game_Temp\"

REM Copy documentation
copy "README.md" "Asteroids_Game_Temp\"

REM Create a simple run script
echo @echo off > "Asteroids_Game_Temp\Run_Asteroids.bat"
echo echo ======================================== >> "Asteroids_Game_Temp\Run_Asteroids.bat"
echo echo    Asteroids Game >> "Asteroids_Game_Temp\Run_Asteroids.bat"
echo echo ======================================== >> "Asteroids_Game_Temp\Run_Asteroids.bat"
echo echo. >> "Asteroids_Game_Temp\Run_Asteroids.bat"
echo echo Starting game... >> "Asteroids_Game_Temp\Run_Asteroids.bat"
echo echo. >> "Asteroids_Game_Temp\Run_Asteroids.bat"
echo GameTemplate.exe >> "Asteroids_Game_Temp\Run_Asteroids.bat"
echo echo. >> "Asteroids_Game_Temp\Run_Asteroids.bat"
echo echo Game closed. >> "Asteroids_Game_Temp\Run_Asteroids.bat"
echo pause >> "Asteroids_Game_Temp\Run_Asteroids.bat"

REM Create game instructions
echo ======================================== > "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo    ASTEROIDS GAME - INSTRUCTIONS >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo ======================================== >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo. >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo HOW TO PLAY: >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo - Run "Run_Asteroids.bat" or "GameTemplate.exe" >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo. >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo CONTROLS: >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo - Arrow Keys: Turn left/right >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo - Up Arrow: Accelerate forward >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo - Down Arrow: Brake (slow down) >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo - Spacebar: Shoot >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo - Enter: Restart game (on Game Over/Victory screen) >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo - Escape: Exit game >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo. >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo OBJECTIVE: >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo Destroy all asteroids without colliding with them! >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo. >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo SCORING: >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo - Large asteroids: 100 points >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo - Medium asteroids: 50 points >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo - Small asteroids: 20 points >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo. >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo LIVES: 3 lives (like the original 1979 game) >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo. >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"
echo Enjoy the classic Asteroids experience! >> "Asteroids_Game_Temp\GAME_INSTRUCTIONS.txt"

REM Create ZIP archive
echo Creating ZIP archive...
powershell -command "Compress-Archive -Path 'Asteroids_Game_Temp\*' -DestinationPath 'Asteroids_Game_v1.0.zip' -Force"

if %errorlevel% equ 0 (
    echo ZIP archive created successfully!
    echo.
    
    REM Clean up temporary directory
    rmdir /s /q "Asteroids_Game_Temp"
    
    echo ========================================
    echo    SUCCESS! Archive Created
    echo ========================================
    echo.
    echo Archive: Asteroids_Game_v1.0.zip
    echo Size: 
    dir "Asteroids_Game_v1.0.zip" | findstr "Asteroids_Game_v1.0.zip"
    echo.
    echo Contents:
    echo - GameTemplate.exe (the game)
    echo - Run_Asteroids.bat (easy launcher)
    echo - GAME_INSTRUCTIONS.txt (how to play)
    echo - README.md (detailed info)
    echo.
    echo You can now send this ZIP file to your friends!
    echo They just need to extract it and run "Run_Asteroids.bat"
    echo.
) else (
    echo Failed to create ZIP archive.
    echo Please try again or create manually.
    echo.
)

echo Press any key to exit...
pause >nul
