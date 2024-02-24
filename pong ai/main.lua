--[The Sound and Resize Update] PONG REMAKE
-- Final Pong
--push is a library that will allow our game at 
--virtual reaolution, instead of however large our window is; 
--used to provide a more retro aesthetic

push = require 'push'

--[[The "Class" library we are using will allow us to represent
anything in our game as code, rather can leeping track of many 
disparate variables and methods]]

Class = require 'class'

--[[Our Paddle class, which stores position and dimensions
for each Paddle and logic for rendering them]]
require 'Paddle'

--our Ball class , which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently

require 'Ball'


--firstly we will define all the constants used in the code
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH =432
VIRTUAL_HEIGHT =243

--speed at which we will move our paddle; multiplied by dt in update
PADDLE_SPEED = 200

--run when the game first starts up, only once;
--used to initialize the game

function love.load()
    love.graphics.setDefaultFilter('nearest','nearest')

    --set the title for our appication window
    love.window.setTitle('Pong')

    --"seed" the RNG so that we get calls to random which will always be random
    --use of the current time, since that will vary on startup every time
    --differnt value at each iteration at each second
    math.randomseed(os.time())
    
    --more "retro looking" font object we can usse for any text
    --fakt add kela new font ani tyachi size
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 15)
    --largerfont for displaying scores on the screen
    scoreFont = love.graphics.newFont('font.ttf', 25)
    --set LOVE2D's active font to the smallFont object
    --graphics madhe new font takla game chya
    love.graphics.setFont(smallFont)

    --set up our sound effects
    sounds = {
        ['paddle_hit']=love.audio.newSource('sounds/paddle_hit.wav','static'),
        ['score']=love.audio.newSource('sounds/score.wav','static'),
        ['wall_hit']=love.audio.newSource('sounds/wall_hit.wav','static'),
        ['victory']=love.audio.newSource('sounds/tadaa-47995.mp3','static'),
    }

    --initialize window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen=false,
        resizable=true,
        vsync=true
    })

    --initialize score variable; used for rendering on screen
    --and keeping track of the winner
    player1score = 0
    player2score = 0

    servingPlayer = 1 --whoever scores the point, will get to serve

    -- initialize our player paddles; make them global so that they can be
    -- detected by other functions and modules
    player1 = Paddle(10,30,5,20)
    player2 = Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT-30,5,20)

    --place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH/2-2, VIRTUAL_HEIGHT/2-2, 4,4)

    --game state variable is used to transition between 
    --various parts of the game
    --(used for beginnibg, menus, main game, high score list, etc.)
    --we will use this to render behaviour between render and update
    gamestate ='start'
end

--[[called when we change dimensions of our window]]
function love.resize(width,height)
    push:resize(width, height)
end


--[[
runs every frame,with dt passed in,our delta in seconds
since the last frame which love2d supplies us
]]
function love.update(dt)
    if gamestate == 'serve' then
        --before switching the state to play, initialize ball's 
        --velocity based on who scored  the point
        ball.dy = math.random (-50.50)
        if servingPlayer == 1 then
            ball.dx = math.random(140,200)
        else
            ball.dx = -math.random(140,200)
        end
    elseif gamestate =='play' then
        --detect ball collision with paddles, reversing dx
        --if true and slightly increasing it, then altering the dy
        --based on position of collision
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5  -- +5 since paddle width from left to right

            --keep velocity going on same direction but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10)/150
            else
                ball.dy = math.random(10)/150
            end

            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x -4 -- -4 since balls width from right to left

            --keep velocity going in same direction but randomize it
            if  ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
            sounds['paddle_hit']:play()
        end

        --detect upper and lowe screen boundaries collision and reverse if collided
        if ball.y <= 0 then
            ball.y=0
            ball.dy=-ball.dy
            sounds['wall_hit']:play()
        end

        -- -4 to account for balls size
        if ball.y >= VIRTUAL_HEIGHT - 4 then 
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        --if we reach the left or right end of the screen
        --then go back to start and update the score
        if ball.x < 0 then
            servingPlayer = 1
            player2score = player2score + 1
            sounds['score']:play()

         --if reached the score ten then game over
            if player2score == 10 then
                winningPlayer = 2
                gamestate = 'done'
                sounds['victory']:play()
            else
                gamestate = 'serve'
                --place ball in middle of screen with no velocity
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1score = player1score + 1
            sounds['score']:play()
            --if reached the score ten then game over
            if player1score == 10 then
                winningPlayer = 1
                gamestate = 'done'
                sounds['victory']:play()
            else
                gamestate = 'serve'
                --place ball in middle of screen with no velocity
                ball:reset()
            end
        end
    end
    

    --player1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    --player2 movement
    --same as above but for player2
    if gamestate =='play' then

        if ball.y+ball.height/2 < player2.y+player2.height/2 then
            player2.dy = - PADDLE_SPEED
        elseif ball.y+ball.height/2 > player2.y+player2.height/2 then
            player2.dy =  PADDLE_SPEED
        else 
            player2.dy = 0
        end
    end

    --update our ball based on its DX and DY only if we are in play state
    --scale the velocity by dt so that the  ball moves at same speed regardless of frames per second
    if gamestate=='play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
    
end

--keyboard handling, called by love2d each frame;
--passes in the key we pressed so we can acces

function love.keypressed(key)
    --keys can be accessed by string name
    if key == 'escape' then
        --close out of the application
        love.event.quit()
    
    --if we press enter during start state of the game
    --we will go into play mode
    --during lay mode, ball will move in random direction
    elseif key == 'enter' or key == 'return' then
        if  gamestate == 'start' then
            gamestate='serve'
        elseif gamestate == 'serve' then
            gamestate = 'play'
        elseif gamestate == 'done' then
            --game is simply in restart phase, but will set the 
            --serving for the player who lose
            gamestate = 'serve'
            
            ball:reset()

            --reset score to 0
            player1score = 0
            player2score = 0

            --decide serving player as the opposite who won
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

--called after update, used to draw anything to the screen

function love.draw()
    --start drawing things off the screen with our push:apply function
    --begin rendering at virtual resolution
    push:apply('start')

    --clear the screen with specific color; in this case;
    --color similar to some versions of pong
    love.graphics.clear(0/255,69/255,110/255,255/255)

    --draw welcome text toward the top of the screen
    love.graphics.setFont(smallFont)
    --love.graphics.printf('Hello to Pong by Sayali!',0,20,VIRTUAL_WIDTH,'center')

    displayScore()
    

    if gamestate =='start' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('PONG BY SAYALI', 0,10,VIRTUAL_WIDTH,'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to begin!', 0,30,VIRTUAL_WIDTH,'center')
    elseif gamestate =='serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer).. "'s serve!",0,10,VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press Enter to serve',0,20,VIRTUAL_WIDTH,'center')
    elseif gamestate =='play' then
        --no message to diaplay in play
    elseif gamestate == 'done' then
        --UI messages
        love.graphics.setDefaultFilter('nearest','nearest')
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',0,20,VIRTUAL_WIDTH,'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('press enter to restart',0,40,VIRTUAL_WIDTH,'center')
    end

    --paddles are simply rectangles we draw at certain points
    --as is the ball
    

    -- render paddles, now using their class's render method
    player1:render()
    player2:render()
    
    -- render ball using its class's render method
    ball:render()

    --new function just to demonstrate how to see FPS in love2d
    displayFPS()

    --end rendering at virtual resolution
    push:apply('end')
end

--[[This function will just render or show the current FPS
 or frames per second]]
 function displayFPS()
    --simply display fps across all the states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0,255/255,0,255/255)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
 end

--[[Simply draws the score on the screen]]
function displayScore()
    --draw score on the left and right corner of the screen
    --need to switch font to draw before actually printing
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end
