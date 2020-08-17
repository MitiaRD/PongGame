--global constants
Class = require 'class'
push = require 'push'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200



function love.load()-- load up start screen

    math.randomseed(os.time())

    -- sorting out fonts and font size and clarity

    love.graphics.setDefaultFilter('nearest', 'nearest')  

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryfont = love.graphics.newFont('font.ttf', 24)


    --sounds

    sounds = {
        ['paddle'] = love.audio.newSource('paddle_hit.wav', 'static'), 
        ['point'] = love.audio.newSource('loser.wav', 'static'), 
        ['wall'] = love.audio.newSource('wall.wav', 'static'),
        ['button'] = love.audio.newSource('button.wav', 'static')
    }

    -- initial score post
    love.window.setTitle('Pong')
    player1score = 0
    player2score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2
    winningplayer = 0
    
    paddle1 = Paddle(5, 20, 5, 20)  
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT/ 2 -2, 5, 5)

    if servingPlayer == 1 then 
        ball.dx = 100 
    else 
        ball.dx = -100
    end

    gameState = 'start'
    -- setting up shape and size of start screen
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT,WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, 
        vsync = true, 
        resizable = true
    })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)-- update the load screen in real time
    if gameState == 'play' then

        if ball.x <= 0 then
            player2score = player2score + 1
            servingPlayer = 1
            ball:reset()
            sounds['point']:play()
            

            

            if player2score >= 3 then
                gameState = 'victory'
                winningplayer = 2
            else
                gameState = 'serve'
            end
        end

        if ball.x >= VIRTUAL_WIDTH - 4 then
            player1score = player1score + 1
            servingPlayer = 2
            ball:reset()
            sounds['point']:play()
            
            if player1score >= 3 then
                gameState = 'victory'
                winningplayer = 1
            else
                gameState = 'serve'
            end
        end

        if ball:collides(paddle1) then
            sounds['paddle']:play()
            ball.dx = -ball.dx

            
            
        end

        if ball:collides(paddle2) then
            sounds['paddle']:play()
            ball.dx = -ball.dx
            
            
        end

        if ball.y <= 0 then
            ball.dy = -ball.dy
            ball.y = 0

            sounds['wall']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4

            sounds['wall']:play()

        end
        paddle1:update(dt)
        paddle2:update(dt)

        -- keyboard inputs to move paddles
        if love.keyboard.isDown('w') then 
            paddle1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            paddle1.dy = PADDLE_SPEED

        else
            paddle1.dy = 0  
    
        end

        if love.keyboard.isDown('up') then
            paddle2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            paddle2.dy = PADDLE_SPEED
     
        else
            paddle2.dy = 0  
        end

        if gameState == 'play' then
            ball:update(dt)
     
        end
    end
end



function love.keypressed(key) -- end game function
    if key == 'escape' then
        sounds['button']:play()
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        sounds['button']:play()
        if gameState == 'start' then
            gameState = 'serve'

        elseif gameState == 'victory' then
            gameState = 'start'
            player1score = 0
            player2score = 0

        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end
end    




function love.draw()--display function
    -- applies the push file extention downloaded 
    push:apply('start')
    --gives screen different colour to black, must be at start of function or will erase all following data with blank screen
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    ball:render()


    paddle1:render()
    paddle2:render()

    --font and text showing up on screen
    love.graphics.setFont(smallFont) 
    if gameState == 'start' then
        love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center') 
        love.graphics.printf("Press Enter to Play!", 0,  32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf("Player " .. tostring(servingPlayer).. "'s turn!", 0, 20, VIRTUAL_WIDTH, 'center') 
        love.graphics.printf("Press Enter to Serve!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        --draw victory message
        love.graphics.setFont(victoryfont)
        love.graphics.printf('Player '..tostring(winningplayer).." wins!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Serve!", 0, 42, VIRTUAL_WIDTH, 'center')
        

        
    end

    love.graphics.setFont(scoreFont) 
    love.graphics.print(player1score, VIRTUAL_WIDTH / 2 -50, VIRTUAL_HEIGHT/ 3 )
    love.graphics.print(player2score, VIRTUAL_WIDTH / 2 + 40 , VIRTUAL_HEIGHT/ 3)  

    displayFPS()

    push:apply('end')

end


function displayFPS()
    love.graphics.setColor(0,1,0,1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS' .. tostring(love.timer.getFPS()))
    love.graphics.setColor(1, 1, 1, 1)
end