Button = class()

function Button:init(label, x, y, w, h, fillColor)
    self.label = label
    self.x, self.y = x, y
    self.w, self.h = w, h
    self.fillColor = fillColor or color(149, 145, 156, 255)
    local c = color(0, 0, 0, 255)
    self.strokeColor = self.fillColor:mix(c, 0.3)
    self._strokeColor = self.strokeColor
    self._fillColor = self.fillColor
    self._white = color(200, 200, 200, 255)
    self._black = color(0, 0, 0, 255)
end

function Button:draw()
    strokeWidth(1.5)
    fill(self.fillColor)
    stroke(self.strokeColor)
    rectMode(CORNER)
    rect(self.x, self.y, self.w, self.h)
    textMode(CORNER)
    font(self.font or "GillSans")
    fill(self.pressed and self._white or self._black)
    fontSize(30)
    text(self.label, self.x+10, self.y+10)
end

function Button:touched(touch)
    local x, y, w, h = self.x, self.y, self.w, self.h
    local clicked = false

    if (x <= touch.x and touch.x <= x+w) then
        if (y <= touch.y and touch.y <= y+h) then
            if touch.state == BEGAN then
                self.pressed = true
                local black = color(0, 0, 0, 255)
                self.fillColor, self.strokeColor = self.strokeColor, self.fillColor
                sound(DATA, "ZgJANwAiQHM6QEBAAAAAADQfND7Cvvs+fwBAf0BAQEA8QEBA")
            elseif touch.state == ENDED and self.pressed then
                clicked = true
            end
        end
    end
    
    if self.pressed and touch.state == ENDED then
        -- reset state
        self.pressed = false
        self.strokeColor = self._strokeColor
        self.fillColor = self._fillColor
    end
    
    if clicked then
        self:clicked()
    end
end

function Button:clicked()
    -- redefine this in subclasses
end