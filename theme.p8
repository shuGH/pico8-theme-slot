pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
themes = {
 "you are the weapon",
 "a light in the dark",
 "keep growing",
 "3 rules",
 "shelter",
 "unusual magic",
 "color changes everything",
 "at the beginning there is nothing",
 "combine 2 incompatible genres",
 "you really shouldn't mix those",
 "floating islands",
 "it spreads",
 "the environment changes you",
 "fragile",
 "you are what you eat",
 "self-replication"
}

-- float index
findex = 0.0
-- frame count
frame = 0
-- reel speed (line / sec)
speed = 0
speed_min = 0.4
speed_max = 16
-- fixed reel
fixed = false
-- idle, spinning, pressed, decided
state = "idle"

-- util ------------------------

function printl(s,x,y,c)
	print(s,x,y,c)
end
function printr(s,x,y,c)
 x -= (#s*4)-1
	print(s,x,y,c)
end
function printm(s,x,y,c)
 x -= ((#s*4)/2)-1
	print(s,x,y,c)
end

function blink(func, on, off)
	sec = frame/30
	sec %= on + off
	if sec <= on then
		func()
	end
end

function rndr(l,u)
	return rnd(abs(u-l))+min(l,u)
end

-- init ------------------------

function _init()
	fixed = false
end

-- update ------------------------

function move_state(st)
	state = st
	frame = -1
	if state == "idle" then
		_init()
	end
end

function get_index(fidx)
	idx = flr(fidx)
	if idx < 0 then
		get_index(idx + #themes)
	elseif idx >= #themes then
		get_index(idx - #themes)
	end
	return idx+1
end

function update_reel(acc, decided)
	decided = decided or false

	dsec = 1/30
	speed += acc * dsec
	speed = mid(0, speed, speed_max)

	if decided then
		if speed < speed_min then
			speed = speed_min

 		fidx = findex + (speed * dsec)
 		if ceil(fidx) != ceil(findex) then
 			findex = ceil(findex)
 			speed = 0
 			fixed = true
 			return
 		end
		end
 	findex += speed * dsec
 	findex = findex % #themes
	else
 	findex += speed * dsec
 	findex = findex % #themes
	end
end

-- update state ------------------------

function _update_idle()
	if     btnp(🅾️)==true then
		move_state("spinning")
		return
	elseif btnp(❎)==true then
	end

	update_reel(-20)
end

function _update_spinning()
	if     btnp(🅾️)==true then
		if frame >= 60 then
			move_state("pressed")
			return
		end
	elseif btnp(❎)==true then
		move_state("idle")
		return
	end

	update_reel(8)
end

function _update_pressed()
	if     btnp(🅾️)==true then
	elseif btnp(❎)==true then
		move_state("idle")
		return
	end
	
	if fixed then
		move_state("decided")
		return
	end

	update_reel(-3, true)
end

function _update_decided()
	if     btnp(🅾️)==true then
		move_state("idle")
		return
	elseif btnp(❎)==true then
		move_state("idle")
		return
	end
end

-- update main ------------------------

function _update()
 if     state == "idle" then
 	_update_idle()
 elseif state == "spinning" then
 	_update_spinning()
 elseif state == "pressed" then
 	_update_pressed()
 elseif state == "decided" then
 	_update_decided()
 end
 
 frame += 1
end

-- draw ------------------------

function draw_reel_line(offset)
	cidx = get_index(findex)
	idx = get_index(cidx + offset)
	theme = themes[idx]
 center = {x=128/2, y=128/2}
 pos = {
 	x=center.x,
 	y=center.y
 	 + (((findex % #themes) - cidx)*7)
 	 - (offset * 7)
 	 + 5
 }
 printm(theme, pos.x, pos.y, 7)
end

function draw_reel()
 c = {x=128/2, y=128/2}

	draw_reel_line(1)
	draw_reel_line(0)
	draw_reel_line(-1)

	rectfill(0,c.y-18,128,c.y-6,0)
	rectfill(0,c.y+6,128,c.y+18,0)

	rect(
		0,c.y+6,
		127,c.y-6,
		1
	)
end

-- draw state ------------------------

function _draw_idle()
	draw_reel()

	rectfill(0,c.y-26,128,c.y-18,1)
	rectfill(0,c.y+18,128,c.y+26,1)
	
	printm("-- what's a theme --", 64, 26, 6)
 blink(function ()
		printm("press 🅾️ button", 64, 100, 6)
 end, 1.0, 1.0)
end

function _draw_spinning()
	draw_reel()

	if frame >= 60 then
  blink(function ()
 		printm("press 🅾️ button", 64, 100, 6)
  end, 0.2, 0.2)
	end
end

function _draw_pressed()
	draw_reel()
end

function _draw_decided()
	draw_reel()

	rectfill(0,c.y-26,128,c.y-18,10)
	rectfill(0,c.y+18,128,c.y+26,10)

	printm("this jam's theme is...", 64+4, 26, 6)
	printm("press 🅾️ button", 64, 100, 6)
end

-- draw main ------------------------

function _draw_debug()
 color(11)
 print(state.." "..frame)
 print(get_index(findex).." "..findex)
 print(speed)
end

function _draw()
 cls()
 _draw_debug()
 if     state == "idle" then
 	_draw_idle()
 elseif state == "spinning" then
 	_draw_spinning()
 elseif state == "pressed" then
 	_draw_pressed()
 elseif state == "decided" then
 	_draw_decided()
 end
end
