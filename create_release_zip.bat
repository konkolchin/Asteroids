@echo off
echo ========================================
echo    Creating Asteroids Game ZIP
echo ========================================
echo.

REM Check if Release version exists
if not exist "x64\Release\GameTemplate.exe" (
    echo ERROR: Release version not found!
    echo Please build Release version in Visual Studio:
    echo 1. Open GameTemplate.sln
    echo 2. Select Release configuration
    echo 3. Build solution (Ctrl+Shift+B)
    echo.
    pause
    exit /b 1
)

echo Found Release version! Creating ZIP archive...
echo.

REM Create temp directory
if exist "Asteroids_Release_Temp" rmdir /s /q "Asteroids_Release_Temp"
mkdir "Asteroids_Release_Temp"

REM Copy Release files
echo Copying Release files...
copy "x64\Release\GameTemplate.exe" "Asteroids_Release_Temp\"
if exist "x64\Release\GameTemplate.pdb" copy "x64\Release\GameTemplate.pdb" "Asteroids_Release_Temp\"

REM Copy documentation
copy "README.md" "Asteroids_Release_Temp\"

REM Create run script
echo @echo off > "Asteroids_Release_Temp\Run_Asteroids.bat"
echo echo ======================================== >> "Asteroids_Release_Temp\Run_Asteroids.bat"
echo echo    ASTEROIDS GAME >> "Asteroids_Release_Temp\Run_Asteroids.bat"
echo echo ======================================== >> "Asteroids_Release_Temp\Run_Asteroids.bat"
echo echo. >> "Asteroids_Release_Temp\Run_Asteroids.bat"
echo echo Starting game... >> "Asteroids_Release_Temp\Run_Asteroids.bat"
echo GameTemplate.exe >> "Asteroids_Release_Temp\Run_Asteroids.bat"
echo echo. >> "Asteroids_Release_Temp\Run_Asteroids.bat"
echo echo Game closed. >> "Asteroids_Release_Temp\Run_Asteroids.bat"
echo pause >> "Asteroids_Release_Temp\Run_Asteroids.bat"

REM Create instructions
echo ======================================== > "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo    ASTEROIDS GAME - INSTRUCTIONS >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo ======================================== >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo. >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo HOW TO PLAY: >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo - Run "Run_Asteroids.bat" or "GameTemplate.exe" >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo. >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo CONTROLS: >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo - Arrow Keys: Turn left/right >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo - Up Arrow: Accelerate forward >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo - Down Arrow: Brake (slow down) >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo - Spacebar: Shoot >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo - Enter: Restart game (on Game Over/Victory screen) >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo - Escape: Exit game >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo. >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo OBJECTIVE: >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo Destroy all asteroids without colliding with them! >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo. >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo SCORING: >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo - Large asteroids: 100 points >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo - Medium asteroids: 50 points >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo - Small asteroids: 20 points >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo. >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo LIVES: 3 lives (like the original 1979 game) >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo. >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"
echo This is the RELEASE version - optimized for best performance! >> "Asteroids_Release_Temp\GAME_INSTRUCTIONS.txt"

REM Create ZIP archive
echo Creating ZIP archive...
powershell -command "Compress-Archive -Path 'Asteroids_Release_Temp\*' -DestinationPath 'Asteroids_Game_Release_v1.0.zip' -Force"

if %errorlevel% equ 0 (
    echo ZIP archive created successfully!
    echo.
    
    REM Clean up
    rmdir /s /q "Asteroids_Release_Temp"
    
    echo ========================================
    echo    SUCCESS! Release Archive Created
    echo ========================================
    echo.
    echo Archive: Asteroids_Game_Release_v1.0.zip
    echo.
    echo Contents:
    echo - GameTemplate.exe (RELEASE version - optimized!)
    echo - Run_Asteroids.bat (easy launcher)
    echo - GAME_INSTRUCTIONS.txt (how to play)
    echo - README.md (detailed documentation)
    echo.
    echo This is the optimized Release version for best performance!
    echo Perfect for sharing with friends!
    echo.
) else (
    echo FAILED to create ZIP archive.
    echo Please try again.
)

echo Press any key to exit...
pause >nul
