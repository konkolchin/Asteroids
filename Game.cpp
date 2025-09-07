#include "Engine.h"
#include <stdlib.h>
#include <memory.h>
#include <math.h>
#include <vector>
#include <algorithm>
#include <cstring>
#include <cstdio>

//
//  You are free to modify this file
//

//  is_key_pressed(int button_vk_code) - check if a key is pressed,
//                                       use keycodes (VK_SPACE, VK_RIGHT, VK_LEFT, VK_UP, VK_DOWN, 'A', 'B')
//
//  get_cursor_x(), get_cursor_y() - get mouse cursor position
//  is_mouse_button_pressed(int button) - check if mouse button is pressed (0 - left button, 1 - right button)
//  clear_buffer() - set all pixels in buffer to 'black'
//  is_window_active() - returns true if window is active
//  schedule_quit_game() - quit game after act()

// Game object structures
struct Vector2 {
    float x, y;
    Vector2(float x = 0, float y = 0) : x(x), y(y) {}
    Vector2 operator+(const Vector2& other) const { return Vector2(x + other.x, y + other.y); }
    Vector2 operator-(const Vector2& other) const { return Vector2(x - other.x, y - other.y); }
    Vector2 operator*(float scalar) const { return Vector2(x * scalar, y * scalar); }
    float length() const { return sqrtf(x * x + y * y); }
    Vector2 normalized() const { 
        float len = length();
        return len > 0 ? Vector2(x / len, y / len) : Vector2(0, 0);
    }
};

struct Ship {
    Vector2 position;
    Vector2 velocity;
    float angle; // rotation angle in radians
    float size;
    bool alive;
    
    Ship() : position(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), velocity(0, 0), angle(0), size(10), alive(true) {}
};

struct Bullet {
    Vector2 position;
    Vector2 velocity;
    float lifeTime;
    bool active;
    
    Bullet() : position(0, 0), velocity(0, 0), lifeTime(0), active(false) {}
};

struct Asteroid {
    Vector2 position;
    Vector2 velocity;
    float size;
    bool active;
    
    Asteroid() : position(0, 0), velocity(0, 0), size(0), active(false) {}
};

// Global game variables
Ship player;
std::vector<Bullet> bullets;
std::vector<Asteroid> asteroids;
int playerLives = 3;
int score = 0;
float shootCooldown = 0;
bool gameOver = false;
bool gameWon = false;

// Helper functions
uint32_t make_color(uint8_t r, uint8_t g, uint8_t b, uint8_t a = 255) {
    return (a << 24) | (r << 16) | (g << 8) | b;
}

void draw_rect(int x, int y, int width, int height, uint32_t color) {
    for (int dy = 0; dy < height; dy++) {
        for (int dx = 0; dx < width; dx++) {
            int px = x + dx;
            int py = y + dy;
            if (px >= 0 && px < SCREEN_WIDTH && py >= 0 && py < SCREEN_HEIGHT) {
                buffer[py][px] = color;
            }
        }
    }
}

void draw_circle(int centerX, int centerY, int radius, uint32_t color) {
    for (int y = -radius; y <= radius; y++) {
        for (int x = -radius; x <= radius; x++) {
            if (x * x + y * y <= radius * radius) {
                int px = centerX + x;
                int py = centerY + y;
                if (px >= 0 && px < SCREEN_WIDTH && py >= 0 && py < SCREEN_HEIGHT) {
                    buffer[py][px] = color;
                }
            }
        }
    }
}

void draw_ship(const Ship& ship) {
    if (!ship.alive) return;
    
    // Draw ship as triangle
    float cos_a = cosf(ship.angle);
    float sin_a = sinf(ship.angle);
    
    // Ship triangle vertices
    Vector2 nose(ship.position.x + cos_a * ship.size, ship.position.y + sin_a * ship.size);
    Vector2 left(ship.position.x + cos_a * (-ship.size/2) + sin_a * ship.size/2, 
                 ship.position.y + sin_a * (-ship.size/2) - cos_a * ship.size/2);
    Vector2 right(ship.position.x + cos_a * (-ship.size/2) - sin_a * ship.size/2, 
                  ship.position.y + sin_a * (-ship.size/2) + cos_a * ship.size/2);
    
    // Simple triangle rendering (filled)
    int minX = (int)fminf(fminf(nose.x, left.x), right.x);
    int maxX = (int)fmaxf(fmaxf(nose.x, left.x), right.x);
    int minY = (int)fminf(fminf(nose.y, left.y), right.y);
    int maxY = (int)fmaxf(fmaxf(nose.y, left.y), right.y);
    
    for (int y = minY; y <= maxY; y++) {
        for (int x = minX; x <= maxX; x++) {
            // Simple point-in-triangle test
            Vector2 p((float)x, (float)y);
            Vector2 v0 = right - left;
            Vector2 v1 = nose - left;
            Vector2 v2 = p - left;
            
            float dot00 = v0.x * v0.x + v0.y * v0.y;
            float dot01 = v0.x * v1.x + v0.y * v1.y;
            float dot02 = v0.x * v2.x + v0.y * v2.y;
            float dot11 = v1.x * v1.x + v1.y * v1.y;
            float dot12 = v1.x * v2.x + v1.y * v2.y;
            
            float invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
            float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
            float v = (dot00 * dot12 - dot01 * dot02) * invDenom;
            
            if (u >= 0 && v >= 0 && u + v <= 1) {
                if (x >= 0 && x < SCREEN_WIDTH && y >= 0 && y < SCREEN_HEIGHT) {
                    buffer[y][x] = make_color(255, 255, 255); // White ship
                }
            }
        }
    }
}

void wrap_position(Vector2& pos) {
    if (pos.x < 0) pos.x = (float)SCREEN_WIDTH;
    if (pos.x > SCREEN_WIDTH) pos.x = 0.0f;
    if (pos.y < 0) pos.y = (float)SCREEN_HEIGHT;
    if (pos.y > SCREEN_HEIGHT) pos.y = 0.0f;
}

bool check_collision(const Vector2& pos1, float size1, const Vector2& pos2, float size2) {
    float dx = pos1.x - pos2.x;
    float dy = pos1.y - pos2.y;
    float distance = sqrtf(dx * dx + dy * dy);
    return distance < (size1 + size2);
}

void draw_text(int x, int y, const char* text, uint32_t color) {
    // Improved text rendering with more readable characters
    int len = (int)strlen(text);
    for (int i = 0; i < len; i++) {
        int charX = x + i * 10; // Increase spacing between characters
        
        if (text[i] >= '0' && text[i] <= '9') {
            int digit = text[i] - '0';
            // Draw digits as more distinguishable shapes
            switch (digit) {
                case 0: // 0
                    draw_rect(charX, y, 8, 2, color);     // top
                    draw_rect(charX, y + 14, 8, 2, color); // bottom
                    draw_rect(charX, y, 2, 16, color);     // left
                    draw_rect(charX + 6, y, 2, 16, color);  // right
                    break;
                case 1: // 1
                    draw_rect(charX + 3, y, 2, 16, color);  // vertical line
                    break;
                case 2: // 2
                    draw_rect(charX, y, 8, 2, color);      // top
                    draw_rect(charX + 6, y + 2, 2, 6, color); // top right
                    draw_rect(charX, y + 8, 8, 2, color);  // middle
                    draw_rect(charX, y + 10, 2, 6, color);  // bottom left
                    draw_rect(charX, y + 14, 8, 2, color); // bottom
                    break;
                case 3: // 3
                    draw_rect(charX, y, 8, 2, color);       // top
                    draw_rect(charX + 6, y + 2, 2, 6, color); // top right
                    draw_rect(charX, y + 8, 8, 2, color);  // middle
                    draw_rect(charX + 6, y + 10, 2, 6, color); // bottom right
                    draw_rect(charX, y + 14, 8, 2, color); // bottom
                    break;
                case 4: // 4
                    draw_rect(charX, y, 2, 8, color);      // top left
                    draw_rect(charX, y + 8, 8, 2, color);  // middle
                    draw_rect(charX + 6, y, 2, 16, color);  // right
                    break;
                case 5: // 5
                    draw_rect(charX, y, 8, 2, color);       // top
                    draw_rect(charX, y + 2, 2, 6, color);   // top left
                    draw_rect(charX, y + 8, 8, 2, color);  // middle
                    draw_rect(charX + 6, y + 10, 2, 6, color); // bottom right
                    draw_rect(charX, y + 14, 8, 2, color); // bottom
                    break;
                case 6: // 6
                    draw_rect(charX, y, 8, 2, color);       // top
                    draw_rect(charX, y + 2, 2, 14, color);  // left (reduced height to avoid tail)
                    draw_rect(charX, y + 8, 8, 2, color);  // middle
                    draw_rect(charX + 6, y + 10, 2, 6, color); // bottom right
                    draw_rect(charX, y + 14, 8, 2, color); // bottom
                    break;
                case 7: // 7
                    draw_rect(charX, y, 8, 2, color);       // top
                    draw_rect(charX + 6, y + 2, 2, 14, color); // right
                    break;
                case 8: // 8
                    draw_rect(charX, y, 8, 2, color);       // top
                    draw_rect(charX, y, 2, 16, color);      // left
                    draw_rect(charX + 6, y, 2, 16, color);  // right
                    draw_rect(charX, y + 8, 8, 2, color);  // middle
                    draw_rect(charX, y + 14, 8, 2, color); // bottom
                    break;
                case 9: // 9
                    draw_rect(charX, y, 8, 2, color);       // top
                    draw_rect(charX, y, 2, 8, color);       // top left
                    draw_rect(charX + 6, y, 2, 16, color);  // right
                    draw_rect(charX, y + 8, 8, 2, color);  // middle
                    draw_rect(charX, y + 14, 8, 2, color); // bottom
                    break;
            }
        } else if (text[i] >= 'A' && text[i] <= 'Z') {
            // Simple letter rendering - draw recognizable letter shapes
            char letter = text[i];
            switch (letter) {
                case 'L': // L
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX, y + 14, 8, 2, color);   // bottom horizontal
                    break;
                case 'I': // I
                    draw_rect(charX + 3, y, 2, 16, color);  // vertical line
                    break;
                case 'V': // V
                    draw_rect(charX, y, 2, 12, color);       // left diagonal
                    draw_rect(charX + 6, y, 2, 12, color);   // right diagonal
                    draw_rect(charX + 2, y + 12, 4, 2, color); // bottom point
                    break;
                case 'E': // E
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX, y, 8, 2, color);       // top horizontal
                    draw_rect(charX, y + 7, 6, 2, color);   // middle horizontal
                    draw_rect(charX, y + 14, 8, 2, color);  // bottom horizontal
                    break;
                case 'S': // S
                    draw_rect(charX, y, 8, 2, color);       // top horizontal
                    draw_rect(charX, y + 2, 2, 6, color);    // top left vertical
                    draw_rect(charX, y + 8, 8, 2, color);   // middle horizontal
                    draw_rect(charX + 6, y + 10, 2, 6, color); // bottom right vertical
                    draw_rect(charX, y + 14, 8, 2, color);  // bottom horizontal
                    break;
                case 'C': // C
                    draw_rect(charX, y, 8, 2, color);       // top horizontal
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX, y + 14, 8, 2, color);  // bottom horizontal
                    break;
                case 'O': // O
                    draw_rect(charX, y, 8, 2, color);       // top horizontal
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX + 6, y, 2, 16, color);   // right vertical
                    draw_rect(charX, y + 14, 8, 2, color);  // bottom horizontal
                    break;
                case 'R': // R
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX, y, 8, 2, color);       // top horizontal
                    draw_rect(charX + 6, y + 2, 2, 6, color); // right vertical
                    draw_rect(charX, y + 8, 8, 2, color);   // middle horizontal
                    draw_rect(charX + 4, y + 10, 2, 6, color); // diagonal
                    break;
                case 'F': // F
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX, y, 8, 2, color);       // top horizontal
                    draw_rect(charX, y + 7, 6, 2, color);   // middle horizontal
                    break;
                case 'N': // N
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX + 6, y, 2, 16, color);  // right vertical
                    draw_rect(charX + 2, y + 2, 2, 4, color); // diagonal
                    draw_rect(charX + 4, y + 6, 2, 4, color); // diagonal
                    break;
                case 'A': // A
                    draw_rect(charX + 2, y, 4, 2, color);      // top horizontal
                    draw_rect(charX, y + 2, 2, 6, color);      // left diagonal
                    draw_rect(charX + 6, y + 2, 2, 6, color);  // right diagonal
                    draw_rect(charX, y + 8, 8, 2, color);      // middle horizontal (crossbar)
                    draw_rect(charX, y + 10, 2, 6, color);     // left vertical (foot)
                    draw_rect(charX + 6, y + 10, 2, 6, color); // right vertical (foot)
                    break;
                case 'T': // T
                    draw_rect(charX, y, 8, 2, color);       // top horizontal
                    draw_rect(charX + 3, y, 2, 16, color);  // vertical line
                    break;
                case 'Y': // Y
                    draw_rect(charX + 1, y, 2, 6, color);   // left diagonal
                    draw_rect(charX + 5, y, 2, 6, color);   // right diagonal
                    draw_rect(charX + 3, y + 6, 2, 10, color); // vertical line
                    break;
                case 'G': // G
                    draw_rect(charX, y, 8, 2, color);       // top horizontal
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX, y + 14, 8, 2, color);  // bottom horizontal
                    draw_rect(charX + 6, y + 8, 2, 8, color); // right vertical
                    draw_rect(charX + 4, y + 8, 4, 2, color); // middle extension
                    break;
                case 'M': // M
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX + 6, y, 2, 16, color);  // right vertical
                    draw_rect(charX + 2, y, 2, 6, color);    // left diagonal
                    draw_rect(charX + 4, y, 2, 6, color);    // right diagonal
                    break;
                case 'P': // P
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX, y, 8, 2, color);       // top horizontal
                    draw_rect(charX + 6, y + 2, 2, 6, color); // right vertical
                    draw_rect(charX, y + 8, 8, 2, color);   // middle horizontal
                    break;
                case 'U': // U
                    draw_rect(charX, y, 2, 14, color);      // left vertical
                    draw_rect(charX + 6, y, 2, 14, color);  // right vertical
                    draw_rect(charX, y + 14, 8, 2, color);  // bottom horizontal
                    break;
                case 'H': // H
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX + 6, y, 2, 16, color);  // right vertical
                    draw_rect(charX, y + 8, 8, 2, color);   // middle horizontal
                    break;
                case 'D': // D
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX, y, 6, 2, color);       // top horizontal
                    draw_rect(charX + 4, y + 2, 2, 12, color); // right vertical
                    draw_rect(charX, y + 14, 6, 2, color);  // bottom horizontal
                    break;
                case 'B': // B
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX, y, 6, 2, color);       // top horizontal
                    draw_rect(charX + 4, y + 2, 2, 6, color); // right vertical
                    draw_rect(charX, y + 8, 6, 2, color);   // middle horizontal
                    draw_rect(charX + 4, y + 10, 2, 6, color); // right vertical
                    draw_rect(charX, y + 14, 6, 2, color);  // bottom horizontal
                    break;
                case 'J': // J
                    draw_rect(charX + 4, y, 2, 12, color);  // vertical line
                    draw_rect(charX, y + 12, 6, 2, color);  // bottom horizontal
                    draw_rect(charX, y + 14, 2, 2, color);  // left hook
                    break;
                case 'K': // K
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX + 2, y + 6, 2, 2, color); // middle diagonal
                    draw_rect(charX + 4, y + 4, 2, 2, color); // upper diagonal
                    draw_rect(charX + 4, y + 8, 2, 2, color); // lower diagonal
                    draw_rect(charX + 6, y + 2, 2, 2, color); // upper right
                    draw_rect(charX + 6, y + 10, 2, 2, color); // lower right
                    break;
                case 'Q': // Q
                    draw_rect(charX, y, 8, 2, color);       // top horizontal
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX + 6, y, 2, 16, color);  // right vertical
                    draw_rect(charX, y + 14, 8, 2, color);  // bottom horizontal
                    draw_rect(charX + 4, y + 10, 2, 6, color); // tail
                    break;
                case 'W': // W
                    draw_rect(charX, y, 2, 16, color);      // left vertical
                    draw_rect(charX + 6, y, 2, 16, color);  // right vertical
                    draw_rect(charX + 2, y + 10, 2, 6, color); // left diagonal
                    draw_rect(charX + 4, y + 10, 2, 6, color); // right diagonal
                    break;
                case 'X': // X
                    draw_rect(charX, y, 2, 6, color);       // top left diagonal
                    draw_rect(charX + 6, y, 2, 6, color);   // top right diagonal
                    draw_rect(charX + 2, y + 6, 4, 2, color); // middle
                    draw_rect(charX, y + 10, 2, 6, color);   // bottom left diagonal
                    draw_rect(charX + 6, y + 10, 2, 6, color); // bottom right diagonal
                    break;
                case 'Z': // Z
                    draw_rect(charX, y, 8, 2, color);       // top horizontal
                    draw_rect(charX + 6, y + 2, 2, 2, color); // diagonal
                    draw_rect(charX + 4, y + 4, 2, 2, color); // diagonal
                    draw_rect(charX + 2, y + 6, 2, 2, color); // diagonal
                    draw_rect(charX, y + 8, 2, 2, color);    // diagonal
                    draw_rect(charX, y + 14, 8, 2, color);  // bottom horizontal
                    break;
                default:
                    // Fallback for unsupported letters
                    draw_rect(charX, y, 8, 16, color);
                    break;
            }
        } else if (text[i] == ':') {
            // Colon - two dots
            draw_rect(charX + 3, y + 4, 2, 2, color);
            draw_rect(charX + 3, y + 10, 2, 2, color);
        }
    }
}

void draw_lives(int lives, int x, int y) {
    char livesText[8];
    sprintf_s(livesText, "%d", lives);
    
    // Black background for lives
    draw_rect(x - 5, y - 2, 30, 20, make_color(0, 0, 0));
    
    // White text
    draw_text(x, y, livesText, make_color(255, 255, 255));
}

void draw_score(int score, int x, int y) {
    char scoreText[32];
    sprintf_s(scoreText, "%d", score);
    
    // Black background for score
    draw_rect(x - 5, y - 2, 100, 20, make_color(0, 0, 0));
    
    // White text
    draw_text(x, y, scoreText, make_color(255, 255, 255));
}

void spawn_asteroid() {
    Asteroid asteroid;
    asteroid.size = 15.0f + (float)(rand() % 15); // Size from 15 to 30 (smaller like original)
    
    // Spawn at screen edges
    int side = rand() % 4;
    switch (side) {
        case 0: // Top
            asteroid.position = Vector2((float)(rand() % SCREEN_WIDTH), 0.0f);
            asteroid.velocity = Vector2((float)(rand() % 200 - 100) / 3.0f, (float)(rand() % 100 + 50) / 3.0f);
            break;
        case 1: // Right
            asteroid.position = Vector2((float)SCREEN_WIDTH, (float)(rand() % SCREEN_HEIGHT));
            asteroid.velocity = Vector2(-(float)(rand() % 100 + 50) / 3.0f, (float)(rand() % 200 - 100) / 3.0f);
            break;
        case 2: // Bottom
            asteroid.position = Vector2((float)(rand() % SCREEN_WIDTH), (float)SCREEN_HEIGHT);
            asteroid.velocity = Vector2((float)(rand() % 200 - 100) / 3.0f, -(float)(rand() % 100 + 50) / 3.0f);
            break;
        case 3: // Left
            asteroid.position = Vector2(0.0f, (float)(rand() % SCREEN_HEIGHT));
            asteroid.velocity = Vector2((float)(rand() % 100 + 50) / 3.0f, (float)(rand() % 200 - 100) / 3.0f);
            break;
    }
    
    asteroid.active = true;
    asteroids.push_back(asteroid);
}


// initialize game data in this function
void initialize()
{
    // Initialize player
    player = Ship();
    
    // Clear vectors
    bullets.clear();
    asteroids.clear();
    
    // Reset game variables
    playerLives = 3; // Original Asteroids 1979: 3 lives
    score = 0;
    shootCooldown = 0;
    gameOver = false;
    gameWon = false;
    
    // Create initial asteroids (more like original)
    for (int i = 0; i < 12; i++) {
        spawn_asteroid();
    }
}

// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
void act(float dt)
{
    if (is_key_pressed(VK_ESCAPE))
        schedule_quit_game();
    
    // Reset gameWon if there are active asteroids
    if (gameWon) {
        bool hasActiveAsteroids = false;
        for (const auto& asteroid : asteroids) {
            if (asteroid.active) {
                hasActiveAsteroids = true;
                break;
            }
        }
        if (hasActiveAsteroids) {
            gameWon = false;
        }
    }
    
    if (gameOver || gameWon) {
        if (is_key_pressed(VK_RETURN)) {
            initialize(); // Restart game
        }
        return;
    }
    
    // Ship controls
    if (player.alive) {
        // Turn left and right (very fast rotation)
        if (is_key_pressed(VK_LEFT)) {
            player.angle -= 20.0f * dt; // 20 radians per second (very fast!)
        }
        if (is_key_pressed(VK_RIGHT)) {
            player.angle += 20.0f * dt; // 20 radians per second (very fast!)
        }
        
        // Forward acceleration
        if (is_key_pressed(VK_UP)) {
            float acceleration = 200.0f * dt; // pixels per second squared
            Vector2 thrust(cosf(player.angle) * acceleration, sinf(player.angle) * acceleration);
            player.velocity = player.velocity + thrust;
            
            // Maximum speed limit (increased for more dynamic gameplay)
            float maxSpeed = 500.0f; // Increased from 300 to 500
            if (player.velocity.length() > maxSpeed) {
                player.velocity = player.velocity.normalized() * maxSpeed;
            }
        }
        
        // Backward acceleration (braking) - classic Asteroids style
        if (is_key_pressed(VK_DOWN)) {
            // Apply gentle friction to slow down gradually (0.5% per frame)
            player.velocity = player.velocity * 0.995f;
        }
        
        // Apply constant friction (gradual slowdown) - disabled for debugging
        // player.velocity = player.velocity * 0.995f;
        
        // Shooting
        shootCooldown -= dt;
        if (is_key_pressed(VK_SPACE) && shootCooldown <= 0) {
            Bullet bullet;
            bullet.position = player.position;
            bullet.velocity = Vector2(cosf(player.angle), sinf(player.angle)) * 500.0f; // Bullet speed
            bullet.lifeTime = 3.0f; // Bullet lifetime
            bullet.active = true;
            bullets.push_back(bullet);
            shootCooldown = 0.2f; // Cooldown between shots
        }
        
        // Update ship position
        player.position = player.position + player.velocity * dt;
        wrap_position(player.position);
    }
    
    // Update bullets
    for (auto& bullet : bullets) {
        if (bullet.active) {
            bullet.position = bullet.position + bullet.velocity * dt;
            bullet.lifeTime -= dt;
            
            if (bullet.lifeTime <= 0) {
                bullet.active = false;
            }
            
            wrap_position(bullet.position);
        }
    }
    
    // Update asteroids
    for (auto& asteroid : asteroids) {
        if (asteroid.active) {
            asteroid.position = asteroid.position + asteroid.velocity * dt;
            wrap_position(asteroid.position);
        }
    }
    
    // Check bullet-asteroid collisions
    for (auto& bullet : bullets) {
        if (!bullet.active) continue;
        
        for (auto& asteroid : asteroids) {
            if (!asteroid.active) continue;
            
            if (check_collision(bullet.position, 2, asteroid.position, asteroid.size)) {
                bullet.active = false;
                asteroid.active = false;
                
                // Add points based on asteroid size
                // Large asteroids give more points
                if (asteroid.size > 40) {
                    score += 100; // Large asteroids
                } else if (asteroid.size > 25) {
                    score += 50;  // Medium asteroids
                } else {
                    score += 20;  // Small asteroids
                }
                
                // Create smaller asteroids if asteroid is big enough
                if (asteroid.size > 15) { // Split if larger than 15 (was 20)
                    for (int i = 0; i < 2; i++) {
                        Asteroid newAsteroid;
                        newAsteroid.position = asteroid.position;
                        newAsteroid.size = asteroid.size * 0.6f;
                        newAsteroid.velocity = Vector2((float)(rand() % 200 - 100) / 3.0f, (float)(rand() % 200 - 100) / 3.0f);
                        newAsteroid.active = true;
                        asteroids.push_back(newAsteroid);
                    }
                }
                break;
            }
        }
    }
    
    // Check ship-asteroid collisions
    if (player.alive) {
        for (const auto& asteroid : asteroids) {
            if (!asteroid.active) continue;
            
            if (check_collision(player.position, player.size, asteroid.position, asteroid.size)) {
                playerLives--;
                player.alive = false;
                
                if (playerLives <= 0) {
                    gameOver = true;
                } else {
                    // Respawn ship after 2 seconds
                    player.position = Vector2(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
                    player.velocity = Vector2(0, 0);
                    player.alive = true;
                    gameOver = false; // Reset gameOver on respawn
                }
                break;
            }
        }
    }
    
    // Check victory condition (all asteroids destroyed)
    bool allAsteroidsDestroyed = true;
    for (const auto& asteroid : asteroids) {
        if (asteroid.active) {
            allAsteroidsDestroyed = false;
            break;
        }
    }
    
    if (allAsteroidsDestroyed) {
        gameWon = true;
    }
    
    // Remove inactive objects
    bullets.erase(std::remove_if(bullets.begin(), bullets.end(), 
        [](const Bullet& b) { return !b.active; }), bullets.end());
    
    asteroids.erase(std::remove_if(asteroids.begin(), asteroids.end(), 
        [](const Asteroid& a) { return !a.active; }), asteroids.end());
}

// fill buffer in this function
// uint32_t buffer[SCREEN_HEIGHT][SCREEN_WIDTH] - is an array of 32-bit colors (8 bits per R, G, B)
void draw()
{
    // clear backbuffer
    memset(buffer, 0, SCREEN_HEIGHT * SCREEN_WIDTH * sizeof(uint32_t));
    
    // Draw asteroids
    for (const auto& asteroid : asteroids) {
        if (asteroid.active) {
            draw_circle((int)asteroid.position.x, (int)asteroid.position.y, (int)asteroid.size, make_color(128, 128, 128)); // Gray asteroids
        }
    }
    
    // Draw bullets
    for (const auto& bullet : bullets) {
        if (bullet.active) {
            draw_rect((int)bullet.position.x - 1, (int)bullet.position.y - 1, 3, 3, make_color(255, 255, 0)); // Yellow bullets
        }
    }
    
    // Draw ship
    if (player.alive) {
        draw_ship(player);
    }
    
    // Draw UI
    // Lives - display as "LIVES: X"
    draw_text(10, 10, "LIVES:", make_color(255, 255, 255));
    draw_lives(playerLives, 70, 10); // Increased distance from 60 to 70
    
    // Score - display as "SCORE: XXXX"
    draw_text(SCREEN_WIDTH - 150, 10, "SCORE:", make_color(255, 255, 255));
    draw_score(score, SCREEN_WIDTH - 50, 10);
    
    // Draw Game Over and Victory screens
    if (gameOver && playerLives <= 0) {
        // Semi-transparent black background
        for (int y = SCREEN_HEIGHT/2 - 50; y < SCREEN_HEIGHT/2 + 50; y++) {
            for (int x = SCREEN_WIDTH/2 - 100; x < SCREEN_WIDTH/2 + 100; x++) {
                if (x >= 0 && x < SCREEN_WIDTH && y >= 0 && y < SCREEN_HEIGHT) {
                    buffer[y][x] = make_color(0, 0, 0, 128);
                }
            }
        }
        
        // "GAME OVER" text and final score
        draw_text(SCREEN_WIDTH/2 - 40, SCREEN_HEIGHT/2 - 45, "GAME OVER", make_color(255, 0, 0));
        draw_text(SCREEN_WIDTH/2 - 30, SCREEN_HEIGHT/2 - 15, "FINAL SCORE:", make_color(255, 255, 255));
        draw_score(score, SCREEN_WIDTH/2 - 10, SCREEN_HEIGHT/2 + 8);
        draw_text(SCREEN_WIDTH/2 - 20, SCREEN_HEIGHT/2 + 38, "PRESS ENTER", make_color(255, 255, 255));
    }
    
    if (gameWon && asteroids.size() == 0) {
        // Semi-transparent black background
        for (int y = SCREEN_HEIGHT/2 - 50; y < SCREEN_HEIGHT/2 + 50; y++) {
            for (int x = SCREEN_WIDTH/2 - 100; x < SCREEN_WIDTH/2 + 100; x++) {
                if (x >= 0 && x < SCREEN_WIDTH && y >= 0 && y < SCREEN_HEIGHT) {
                    buffer[y][x] = make_color(0, 0, 0, 128);
                }
            }
        }
        
        // "VICTORY!" text and final score
        draw_text(SCREEN_WIDTH/2 - 30, SCREEN_HEIGHT/2 - 45, "VICTORY!", make_color(0, 255, 0));
        draw_text(SCREEN_WIDTH/2 - 30, SCREEN_HEIGHT/2 - 15, "FINAL SCORE:", make_color(255, 255, 255));
        draw_score(score, SCREEN_WIDTH/2 - 10, SCREEN_HEIGHT/2 + 8);
        draw_text(SCREEN_WIDTH/2 - 20, SCREEN_HEIGHT/2 + 38, "PRESS ENTER", make_color(255, 255, 255));
    }
}

// free game data in this function
void finalize()
{
}

