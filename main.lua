local love=require "love" 
push=require 'push'
Class=require 'Class'
require'Ball'
require'Paddle'

Window_Width=1280
Window_Height=720

virtual_Width=432
virtual_Height=243

paddle_speed=200

function love.load()
    love.graphics.setDefaultFilter('nearest','nearest')
    love.window.setTitle('Pong')
    math.randomseed(os.time())
    smallFont =love.graphics.newFont('font.ttf',8)
    largeFont =love.graphics.newFont('font.ttf',16)
    scoreFont =love.graphics.newFont('font.ttf',32)
    sounds={
        ['paddle_hit']=love.audio.newSource('sounds/paddle.wav','static'),
        ['score']=love.audio.newSource('sounds/score.wav','static'),
        ['wall_hit']=love.audio.newSource('sounds/Paste3.wav','static')
    }
    push:setupScreen(virtual_Width, virtual_Height,Window_Width, Window_Height, {
        fullscreen= false, 
        resizable= true,
        vsync=true
    })
    player1=Paddle(10,30,5,20)
    player2=Paddle(virtual_Width-15,virtual_Height-30,5,20)
    ball=Ball(virtual_Width/2-2,virtual_Height/2-2,4,4)

    player1_score=0
    player2_score=0
    
    servingPlayer=1

    gameState='start'
end

function love.resize(w,h)
    push:resize(w,h)
end
function love.keypressed(key)
    if key=='escape' then
        love.event.quit()

    elseif key=='enter' or key=='return' then
        if gameState=='start' then
            gameState='serve'
        elseif gameState=='serve' then
            gameState='play'
        elseif gameState=='won' then
            gameState='serve'
            ball:reset()
            player1_score=0
            player2_score=0
            if winningPlayer==1 then
                servingPlayer=2
            else
                servingPlayer=1
            end
        end
    end
end

function love.update(dt)
    if gameState=='serve' then
        ball.dy=math.random(-50,50)
        if servingPlayer==1 then
            ball.dx=math.random(140,200)
        else 
            ball.dx=-math.random(140,200)
        end
    elseif gameState=='play' then 
        if ball:collides(player1) then
            ball.dx=-ball.dx*1.03
            ball.x=player1.x+5

            if ball.dy<0 then
                ball.dy=-math.random(10,150)
            else
                ball.dy=math.random(10,150)
            end
            sounds['wall_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx=-ball.dx*1.03
            ball.x=player2.x -4
            
            if ball.dy<0 then
                ball.dy=-math.random(10,150)
            else
                ball.dy=math.random(10,150)
            end
            sounds['wall_hit']:play()
        end
        if ball.y<=0 then
            ball.y=0
            ball.dy=-ball.dy
            sounds['wall_hit']:play()

        end
        if ball.y>=virtual_Height-4 then
            ball.y=virtual_Height-4
            ball.dy=-ball.dy
            sounds['wall_hit']:play()
        end
        ball:update(dt)
        if ball.x<0 then
            servingPlayer=1
            player2_score=player2_score+1
            sounds['score']:play()
            
            if player2_score==10 then
                winningPlayer=2
                gameState='won'
            else
                gameState='serve'
                ball:reset()
            end
        end
        if ball.x> virtual_Width then
            sounds['score']:play()
            servingPlayer=2
            player1_score=player1_score+1
            if player1_score==10 then
                winningPlayer=1
                gameState='won'
            else
                gameState='serve'
                ball:reset()
            end
        end

    end
    player1:update(dt)
    player2:update(dt)

    if love.keyboard.isDown('w') then
        player1.dy=-paddle_speed
    elseif love.keyboard.isDown('s') then
        player1.dy=paddle_speed 
    else
        player1.dy=0  
    end

    if love.keyboard.isDown('up') then
        player2.dy=-paddle_speed
    elseif love.keyboard.isDown('down') then
        player2.dy=paddle_speed
    else
        player2.dy=0
    end
    
end

function love.draw()
    push:apply('start')
    love.graphics.clear(40/255, 45/255, 52/255, 1)
    if gameState=='start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Hello Pong!",0,10, virtual_Width, 'center')
        love.graphics.printf("Press enter to begin!",0,20, virtual_Width, 'center')
    elseif gameState=='serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player '.. tostring(servingPlayer).."'s serve!",0,10,virtual_Width,'center')
        love.graphics.printf('Press Enter to serve! ',0, 20, virtual_Width,'center')
    elseif gameState=='play' then                
    elseif gameState=='won' then  
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player '..tostring(winningPlayer)..'wins!',0,10,virtual_Width,'center')              
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart! ',0, 40, virtual_Width,'center')
    end
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1_score), virtual_Width/2-50, virtual_Height/3)
    love.graphics.print(tostring(player2_score), virtual_Width/2+50, virtual_Height/3)
    player1:render()
    player2:render()
    ball:render()
    displayFPS()
    push:apply('end')
    
end
function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0,1,0,1)
    love.graphics.print('FPS: '.. tostring(love.timer.getFPS()),10,10)
end