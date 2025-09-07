@echo off
echo ========================================
echo    Asteroids Game - Complete Archive
echo ========================================
echo.

echo Creating comprehensive archive with:
echo - Source code files
echo - Visual Studio project files  
echo - Release executable and folder
echo - Documentation
echo.

REM Check if Release version exists
if not exist "x64\Release\GameTemplate.exe" (
    echo WARNING: Release version not found!
    echo The archive will include source code only.
    echo To include executable, build Release version in Visual Studio:
    echo 1. Open GameTemplate.sln
    echo 2. Select Release configuration
    echo 3. Build solution (Ctrl+Shift+B)
    echo.
    pause
)

REM Create temporary directory for complete archive
if exist "Complete_Package_Temp" rmdir /s /q "Complete_Package_Temp"
mkdir "Complete_Package_Temp"

echo Copying source code files...
REM Copy all source files
copy "Game.cpp" "Complete_Package_Temp\" 2>nul
copy "Engine.cpp" "Complete_Package_Temp\" 2>nul
copy "Engine.h" "Complete_Package_Temp\" 2>nul

echo Copying Visual Studio project files...
REM Copy VS project files
copy "GameTemplate.sln" "Complete_Package_Temp\" 2>nul
copy "GameTemplate.vcxproj" "Complete_Package_Temp\" 2>nul
copy "GameTemplate.vcxproj.filters" "Complete_Package_Temp\" 2>nul
copy "GameTemplate.vcxproj.user" "Complete_Package_Temp\" 2>nul

echo Copying documentation...
REM Copy documentation
copy "README.md" "Complete_Package_Temp\" 2>nul
if exist ".gitignore" copy ".gitignore" "Complete_Package_Temp\" 2>nul

REM Copy release folder if it exists
if exist "x64\Release\GameTemplate.exe" (
    echo Copying release executable...
    copy "x64\Release\GameTemplate.exe" "Complete_Package_Temp\" 2>nul
    if exist "x64\Release\GameTemplate.pdb" copy "x64\Release\GameTemplate.pdb" "Complete_Package_Temp\" 2>nul
    
    REM Create complete release folder structure
    echo Creating release folder structure...
    mkdir "Complete_Package_Temp\Release" 2>nul
    copy "x64\Release\GameTemplate.exe" "Complete_Package_Temp\Release\" 2>nul
    if exist "x64\Release\GameTemplate.pdb" copy "x64\Release\GameTemplate.pdb" "Complete_Package_Temp\Release\" 2>nul
)

REM Create comprehensive build instructions
echo ======================================== > "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo    ASTEROIDS GAME - COMPLETE PACKAGE >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo ======================================== >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo. >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo This package contains everything you need: >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo. >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo SOURCE CODE FILES: >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Game.cpp (main game logic) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Engine.cpp/h (game engine) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo. >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo VISUAL STUDIO PROJECT FILES: >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - GameTemplate.sln (solution file) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - GameTemplate.vcxproj (project file) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - GameTemplate.vcxproj.filters (file organization) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - GameTemplate.vcxproj.user (user settings) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo. >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo RELEASE FILES: >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
if exist "x64\Release\GameTemplate.exe" (
    echo - GameTemplate.exe (compiled game) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
    echo - Release\ folder (executable location) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
) else (
    echo - No release files found (build Release version first) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
)
echo. >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo REQUIREMENTS: >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Visual Studio 2019 or later (for building from source) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Windows 10/11 >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo. >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo HOW TO BUILD FROM SOURCE: >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo 1. Open GameTemplate.sln in Visual Studio >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo 2. Select Release configuration (for best performance) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo 3. Build the solution (Ctrl+Shift+B) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo 4. Run GameTemplate.exe from Release\ folder >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo. >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo HOW TO RUN (if release included): >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
if exist "x64\Release\GameTemplate.exe" (
    echo 1. Navigate to Release\ folder >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
    echo 2. Run GameTemplate.exe >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
) else (
    echo 1. Build the project first (see above) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
)
echo. >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo PROJECT STRUCTURE: >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Engine.h/cpp: Game engine (window, input, rendering) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Game.cpp: Main game logic (Asteroids implementation) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - GameTemplate.sln: Visual Studio solution file >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - GameTemplate.vcxproj: Project file >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo. >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo FEATURES: >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Pixel-based rendering (32-bit BGRA buffer) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Vector mathematics for physics >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Custom text rendering system >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Dynamic object management >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Screen wrapping mechanics >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo. >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo GAME CONTROLS: >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Arrow Keys: Turn left/right >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Up Arrow: Accelerate forward >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Down Arrow: Brake (slow down) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Spacebar: Shoot >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Enter: Restart game (on Game Over/Victory screen) >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo - Escape: Exit game >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo. >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"
echo This is the COMPLETE package with everything included! >> "Complete_Package_Temp\COMPLETE_BUILD_INSTRUCTIONS.txt"

REM Create run script for release version
if exist "x64\Release\GameTemplate.exe" (
    echo @echo off > "Complete_Package_Temp\Run_Asteroids.bat"
    echo echo ======================================== >> "Complete_Package_Temp\Run_Asteroids.bat"
    echo echo    ASTEROIDS GAME >> "Complete_Package_Temp\Run_Asteroids.bat"
    echo echo ======================================== >> "Complete_Package_Temp\Run_Asteroids.bat"
    echo echo. >> "Complete_Package_Temp\Run_Asteroids.bat"
    echo echo Starting game... >> "Complete_Package_Temp\Run_Asteroids.bat"
    echo Release\GameTemplate.exe >> "Complete_Package_Temp\Run_Asteroids.bat"
    echo echo. >> "Complete_Package_Temp\Run_Asteroids.bat"
    echo echo Game closed. >> "Complete_Package_Temp\Run_Asteroids.bat"
    echo pause >> "Complete_Package_Temp\Run_Asteroids.bat"
)

REM Create ZIP archive
echo Creating complete ZIP archive...
powershell -command "Compress-Archive -Path 'Complete_Package_Temp\*' -DestinationPath 'Asteroids_Complete_Package_v1.0.zip' -Force"

if %errorlevel% equ 0 (
    echo Complete ZIP archive created successfully!
    echo.
    
    REM Clean up temporary directory
    rmdir /s /q "Complete_Package_Temp"
    
    echo ========================================
    echo    SUCCESS! Complete Archive Created
    echo ========================================
    echo.
    echo Archive: Asteroids_Complete_Package_v1.0.zip
    echo Size: 
    dir "Asteroids_Complete_Package_v1.0.zip" | findstr "Asteroids_Complete_Package_v1.0.zip"
    echo.
    echo Contents:
    echo - Source code files (Game.cpp, Engine.cpp/h)
    echo - Visual Studio project files (.sln, .vcxproj, etc.)
    if exist "x64\Release\GameTemplate.exe" (
        echo - Release executable (GameTemplate.exe)
        echo - Release folder with executable
        echo - Run_Asteroids.bat (easy launcher)
    )
    echo - README.md (detailed documentation)
    echo - COMPLETE_BUILD_INSTRUCTIONS.txt (comprehensive guide)
    echo - .gitignore (Git ignore file)
    echo.
    echo This archive contains EVERYTHING:
    echo - For developers: Complete source code and VS project
    echo - For players: Ready-to-run executable (if built)
    echo - For sharing: Complete package with all files
    echo.
) else (
    echo Failed to create complete ZIP archive.
    echo Please try again or create manually.
    echo.
)

echo Press any key to exit...
pause >nul
