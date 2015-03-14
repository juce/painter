-- Painter

supportedOrientations(CurrentOrientation)

function setup()
    displayMode(FULLSCREEN)

    print("Draw in the grey area")  
    local cw, ch = WIDTH, HEIGHT*0.85
    
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
    
    swatches = {
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
    
    MIN_RADIUS = 30
    MAX_RADIUS = 30
    
    radius = 20 --MIN_RADIUS
    dist2 = 0
    lastX, lastY = nil, nil
    
    --parameter.watch("radius")
    --parameter.watch("dist2")t
    parameter.integer("picSource", 1, 3, 2)
    local buttonFont = "GillSans"
    
    clearButton = Button("Clear", cw/2+205, HEIGHT-ch-65, 100, 60)
    clearButton.font = buttonFont
    clearButton.clicked = function(self)
        print("clearButton clicked")
        clearImage(canvas)
    end
    
    invertButton = Button("Invert", cw/2+100, HEIGHT-ch-65, 100, 60)
    invertButton.font = buttonFont
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

function drawButton(b, x, y, w, h)
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

function touchButton(b, t, touch)
    if touch.state == BEGAN then
        if inside(touch, t) then
            sound(SOUND_HIT, 8783)
            b.touched = true
        end 
    elseif touch.state == ENDED then
        b.touched = false
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
    
    local by, bw, bh = HEIGHT-ch-65, cw/2/8, 60
    for i,b in ipairs(swatches) do
        local x = bw*(i-1)
        drawButton(b, x, by, bw, bh)
        
        if b.touched then
            canvas_fc = canvas_fc:mix(b.clr, 0.99)
        end
    end
end

function touched(touch)
    -- first, handle button events
    invertButton:touched(touch)
    clearButton:touched(touch)
    
    -- swatches
    local cw, ch = spriteSize(canvas)
    local by, bw, bh = HEIGHT-ch-65, cw/2/8, 60
    for i,b in ipairs(swatches) do
        local t = {x=bw*(i-1), y=by, w=bw, h=bh}
        touchButton(b, t, touch)
    end
    
    -- canvas drawing
    canvasTouched(touch)
end
 
function canvasTouched(touch)
    local cw, ch = spriteSize(canvas)
    local t = {x=0, y=HEIGHT-ch, w=cw, h=ch}
    if inside(touch, t) then
        local cx, cy = touch.x, touch.y
        
        if touch.state == MOVING then
            moving = true
            if lastX and lastY then
                -- set radius based on speed of movement
                --dist2 = (cx-lastX)^2 + (cy-lastY)^2 + 1
                --radius = math.min(MAX_RADIUS, math.max(MIN_RADIUS, 50.0/dist2))
                pushStyle()
                setContext(canvas)
                strokeWidth(radius)
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
                ellipse(cx, cy - HEIGHT + ch, radius)
                setContext()
            end
            --radius = MIN_RADIUS
            lastX, lastY = nil, nil
            
        elseif touch.state == BEGAN then
            lastX, lastY = cx, cy
            --radius = math.max(MIN_RADIUS, math.min(MAX_RADIUS, radius * 1.06))
        end
    end
end

function inside(touch, r)
    return r.x <= touch.x and touch.x <= r.x + r.w
        and r.y <= touch.y and touch.y <= r.y + r.h
end

