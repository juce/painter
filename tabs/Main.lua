-- Painter

supportedOrientations(CurrentOrientation)

function setup()
    displayMode(FULLSCREEN)

    local cw, ch = WIDTH, HEIGHT*0.85
    parameter.integer("brush_radius", 2, 50, 20)
    
    canvas_bc = color(197, 197, 197, 255)
    canvas_fc = color(50, 50, 50, 255)
    
    colors = {}
    colors.red = color(255, 0, 0, 255)
    colors.green = color(2, 255, 0, 255)
    colors.blue = color(9, 0, 255, 255)
    colors.yellow = color(251, 255, 0, 255)
    colors.white = color(255, 255, 255, 255)
    colors.black = color(0, 0, 0, 255)
    colors.orange = color(255, 151, 0, 255)
    colors.violet = color(204, 0, 255, 255)
    
    paints = {
        {clr = colors.red},
        {clr = colors.orange},
        {clr = colors.yellow},
        {clr = colors.green},
        {clr = colors.blue},
        {clr = colors.violet},
        {clr = colors.black},
        {clr = colors.white},
    }
    
    canvas = image(cw, ch)
    setContext(canvas)
    background(canvas_bc)
    setContext()
    
    lastX, lastY = nil, nil
       
    clearButton = Button("Clear", WIDTH-100, HEIGHT-ch-65, 100, 60)
    clearButton.clicked = function(self)
        clearImage(canvas)
    end
    
    invertButton = Button("Invert", WIDTH-205, HEIGHT-ch-65, 100, 60)
    invertButton.clicked = function(self)
        canvas_bc, canvas_fc = canvas_fc, canvas_bc
    end
    invertButton.draw = function(self)
        local x, y, w, h = self.x, self.y, self.w, self.h
        pushStyle()
        strokeWidth(3)
        stroke(canvas_fc)
        fill(canvas_bc)
        smooth()
        rect(x, y, w, h)
        fill(canvas_fc)
        noSmooth()
        rect(x+14, y+14, w-28, h-28)
        popStyle()
    end
end

function drawPaint(b, x, y, w, h)
    pushStyle()
    strokeWidth(3)
    stroke(117, 117, 117, 255)
    fill(76, 76, 76, 255)
    smooth()
    rect(x, y, w, h)
    fill(b.clr)
    noSmooth()
    noStroke()
    local s = b.touched and 3 or 14
    rect(x+s, y+s, w-s*2, h-s*2)
    popStyle()
end

function touchPaint(p, t, touch)
    if touch.state == BEGAN then
        if inside(touch, t.x, t.y, t.w, t.h) then
            sound(SOUND_HIT, 8783)
            p.touched = true
        end 
    elseif touch.state == ENDED then
        p.touched = nil
    end
end

function clearImage(img, c)
    c = c or canvas_bc
    setContext(img)
    background(c)
    setContext()
end

function draw()
    background(0, 0, 0, 255)
    blendMode(NORMAL)
    local cw, ch = spriteSize(canvas)
        
    sprite(canvas, cw/2, HEIGHT-ch/2)
    invertButton:draw()
    clearButton:draw()
    
    local py, pw, ph = HEIGHT-ch-65, 60, 60
    for i,p in ipairs(paints) do
        local x = pw*(i-1)
        drawPaint(p, x, py, pw, ph)
        -- mix color
        if p.touched then
            canvas_fc = canvas_fc:mix(p.clr, 0.99)
        end
    end
end

function touched(touch)
    local cw, ch = spriteSize(canvas)
    
    -- first, handle button events
    invertButton:touched(touch)
    clearButton:touched(touch)
    
    -- paints
    local py, pw, ph = HEIGHT-ch-65, 60, 60
    for i,p in ipairs(paints) do
        local t = {x=pw*(i-1), y=py, w=pw, h=ph}
        touchPaint(p, t, touch)
    end
    
    -- canvas drawing
    canvasTouched(touch)
end
 
function canvasTouched(touch)
    local cw, ch = spriteSize(canvas)
    if inside(touch, 0, HEIGHT-ch, cw, ch) then
        local cx, cy = touch.x, touch.y
        
        if touch.state == MOVING then
            moving = true
            if lastX and lastY then
                pushStyle()
                setContext(canvas)
                strokeWidth(brush_radius)
                stroke(canvas_fc)
                smooth()
                noFill()
                lineCapMode(ROUND)
                line(cx, cy - HEIGHT + ch, lastX, lastY - HEIGHT + ch)
                setContext()
                popStyle()
            end
            setContext()
            lastX, lastY = cx, cy
            
        elseif touch.state == ENDED then
            local wasMoving
            wasMoving, moving = moving, nil
            if not wasMoving then
                setContext(canvas)
                stroke(canvas_fc)
                fill(canvas_fc)
                ellipse(cx, cy - HEIGHT + ch, brush_radius)
                setContext()
            end
            lastX, lastY = nil, nil
            
        elseif touch.state == BEGAN then
            lastX, lastY = cx, cy
        end
    end
end

function inside(touch, x, y, w, h)
    return x <= touch.x and touch.x <= x + w
        and y <= touch.y and touch.y <= y + h
end
