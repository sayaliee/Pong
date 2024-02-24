--[[Represents a ball which will bounce back and forth between padddles and walls
until it passes a left or right boundary of the screen,
scoring a point for opponent]]

Ball = Class{}

function Ball:init(x,y,width,height)
    self.x = x
    self.y = y
    self.width = width
    self.height= height

    --these variables are for keeping track of our velocity
    --on both the X and Y axis, since the ball can move in two dimensions
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50)
end


--[[Expect a paddle as an argument, and return true or false
depending on whether the rectangles overlap]]

function Ball:collides(paddle) --case
    --first, check if the left edge of any of the either ia far from the other right
    --edge (i.e., they're not overlapping). If so, there's no collision.
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return  false
    end

    --then check the bottom and top edges of the ball and paddle
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    --if the above aren't true, they are overlapping
    return true
end

--[[Places the ball on the middle of the screen, with an initial random 
velocity on both the axes.]]

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50,50)
end

--[[simply applies velocity to the position, scaled by deltatime]]
function Ball:update(dt)
    --apply local physics to the ball
    --we multiply dt (which is seconds since last frame) by our dx and dy values
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.rectangle('fill',self.x, self.y, self.width, self.height)
end
