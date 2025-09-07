@echo off
echo Creating Asteroids Game ZIP archive...

REM Check if game exists
if not exist "x64\Release\GameTemplate.exe" (
    echo ERROR: GameTemplate.exe not found!
    echo Please build the project in Visual Studio first.
    pause
    exit /b 1
)

echo Found game! Creating archive...

REM Create temp directory
if exist "temp_zip" rmdir /s /q "temp_zip"
mkdir "temp_zip"

REM Copy files
copy "x64\Release\GameTemplate.exe" "temp_zip\"
copy "README.md" "temp_zip\"

REM Create run script
echo @echo off > "temp_zip\Run_Asteroids.bat"
echo echo Starting Asteroids Game... >> "temp_zip\Run_Asteroids.bat"
echo GameTemplate.exe >> "temp_zip\Run_Asteroids.bat"
echo pause >> "temp_zip\Run_Asteroids.bat"

REM Create instructions
echo ASTEROIDS GAME - HOW TO PLAY > "temp_zip\INSTRUCTIONS.txt"
echo. >> "temp_zip\INSTRUCTIONS.txt"
echo CONTROLS: >> "temp_zip\INSTRUCTIONS.txt"
echo - Arrow Keys: Turn left/right >> "temp_zip\INSTRUCTIONS.txt"
echo - Up Arrow: Accelerate >> "temp_zip\INSTRUCTIONS.txt"
echo - Down Arrow: Brake >> "temp_zip\INSTRUCTIONS.txt"
echo - Spacebar: Shoot >> "temp_zip\INSTRUCTIONS.txt"
echo - Enter: Restart >> "temp_zip\INSTRUCTIONS.txt"
echo - Escape: Exit >> "temp_zip\INSTRUCTIONS.txt"
echo. >> "temp_zip\INSTRUCTIONS.txt"
echo OBJECTIVE: Destroy all asteroids! >> "temp_zip\INSTRUCTIONS.txt"

REM Create ZIP using PowerShell
powershell -command "Compress-Archive -Path 'temp_zip\*' -DestinationPath 'Asteroids_Game_Ready.zip' -Force"

if %errorlevel% equ 0 (
    echo SUCCESS! Created Asteroids_Game_Ready.zip
    rmdir /s /q "temp_zip"
    echo.
    echo Archive contains:
    echo - GameTemplate.exe (the game)
    echo - Run_Asteroids.bat (easy launcher)
    echo - INSTRUCTIONS.txt (how to play)
    echo - README.md (detailed info)
    echo.
    echo You can now send this ZIP to your friends!
) else (
    echo FAILED to create ZIP archive
)

echo.
pause
