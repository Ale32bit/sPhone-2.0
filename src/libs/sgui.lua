_G.aread = function( _sReplaceChar, _sDefault )
	if _sReplaceChar ~= nil and type( _sReplaceChar ) ~= "string" then
		error( "bad argument #1 (expected string, got " .. type( _sReplaceChar ) .. ")", 2 )
	end
	if _sDefault ~= nil and type( _sDefault ) ~= "string" then
		error( "bad argument #2 (expected string, got " .. type( _sDefault ) .. ")", 2 )
	end
	term.setCursorBlink( true )
--.
	local sLine
	if type( _sDefault ) == "string" then
		sLine = _sDefault
	else
		sLine = ""
	end
	local nPos = #sLine
	if _sReplaceChar then
		_sReplaceChar = string.sub( _sReplaceChar, 1, 1 )
	end

	local w = term.getSize()
	local sx = term.getCursorPos()

	local function redraw( _bClear )
		local nScroll = 0
		if sx + nPos >= w then
			nScroll = (sx + nPos) - w
		end

		local cx,cy = term.getCursorPos()
		term.setCursorPos( sx, cy )
		local sReplace = (_bClear and " ") or _sReplaceChar
		if sReplace then
			term.write( string.rep( sReplace, math.max( string.len(sLine) - nScroll, 0 ) ) )
		else
			term.write( string.sub( sLine, nScroll + 1 ) )
		end

		term.setCursorPos( sx + nPos - nScroll, cy )
	end

	local function clear()
		redraw( true )
	end

	redraw()

	while true do
		local sEvent, param, x,y = os.pullEvent()
		if sEvent == "char" then
			-- Typed key
			clear()
			sLine = string.sub( sLine, 1, nPos ) .. param .. string.sub( sLine, nPos + 1 )
			nPos = nPos + 1
			redraw()

		elseif sEvent == "paste" then
			-- Pasted text
			clear()
			sLine = string.sub( sLine, 1, nPos ) .. param .. string.sub( sLine, nPos + 1 )
			nPos = nPos + string.len( param )
			redraw()

		elseif sEvent == "key" then
			if param == keys.enter then
				-- Enter
				break

			elseif param == keys.backspace then
				-- Backspace
				if nPos > 0 then
					clear()
					sLine = string.sub( sLine, 1, nPos - 1 ) .. string.sub( sLine, nPos + 1 )
					nPos = nPos - 1
					redraw()
				end

			elseif param == keys.home then
				-- Home
				if nPos > 0 then
					clear()
					nPos = 0
					redraw()
				end

			elseif param == keys.delete then
				-- Delete
				if nPos < string.len(sLine) then
					clear()
					sLine = string.sub( sLine, 1, nPos ) .. string.sub( sLine, nPos + 2 )
					redraw()
				end

			elseif param == keys["end"] then
				-- End
				if nPos < string.len(sLine ) then
					clear()
					nPos = string.len(sLine)
					redraw()
				end
			end

		elseif sEvent == "term_resize" then
			-- Terminal resized
			w = term.getSize()
			redraw()

		elseif sEvent == "mouse_click" then
				os.queueEvent("mouse_click",param,x,y)
				break
			end
	end

	local cx, cy = term.getCursorPos()
	term.setCursorBlink( false )
	term.setCursorPos( w + 1, cy )
	print()

	return sLine
end





	function create(viewport, _BG, _allowTerminate)
	local obj = {}
	local bg = _BG or colors.black
	local vp = viewport
	local elements = {}
	local at = _allowTerminate or true
	local lastid = 1
	local stop = false
	function obj.deleteItem(targetid)
		for i=1,#elements do
			if elements[i].id == targetid then
				table.remove(elements,i)
			end
		end
		obj.redraw()
	end
	function obj.addButton(x,y,text,callback, _BG, _FG)
		elements[#elements + 1] = {id=lastid+1,element="BTN",callback = callback, x = x, y = y, text = text, bg = _BG or colors.lightGray, fg = _FG or colors.white}
		local id = lastid + 1
		lastid = lastid + 1
		return id
	end
	function obj.alterButton(targetid,_newX,_newY,_newText,_newCallback,_newBG,_newFG)
		for i=1,#elements do
			if elements[i].id == targetid then
				local oldCallback = elements[i].callback
				local oldX = elements[i].x
				local oldY = elements[i].y
				local oldText = elements[i].text
				local oldBg = elements[i].bg
				local oldFg = elements[i].fg
				elements[i] = {id=targetid,element="BTN",callback = _newCallback or oldCallback, x = _newX or oldX, y = _newY or oldY, text = _newText or oldText, bg = _newBG or oldBg, fg = _newFG or oldFg}
			end
		end
	end
	function drawButton(id)
		vp.setCursorPos(elements[id].x,elements[id].y)
		vp.setBackgroundColor(elements[id].bg)
		vp.setTextColor(elements[id].fg)
		vp.write(elements[id].text)
	end

	function obj.addLabel(x,y,text, _BG, _FG)
		elements[#elements + 1] = {id=lastid+1,element="LBL", x = x, y = y, text = text, bg = _BG or bg, fg = _FG or colors.white}
		local id = lastid + 1
		lastid = lastid + 1
		return id
	end

	function drawLabel(id)
		vp.setCursorPos(elements[id].x,elements[id].y)
		vp.setBackgroundColor(elements[id].bg)
		vp.setTextColor(elements[id].fg)
		vp.write(elements[id].text)
	end

	function obj.alterLabel(targetid,_newX,_newY,_newText,_newBG,_newFG)
		for i=1,#elements do
			if elements[i].id == targetid then
				local oldX = elements[i].x
				local oldY = elements[i].y
				local oldText = elements[i].text
				local oldBg = elements[i].bg
				local oldFg = elements[i].fg
				elements[i] = {id=targetid,element="LBL", x = _newX or oldX, y = _newY or oldY, text = _newText or oldText, bg = _newBG or oldBg, fg = _newFG or oldFg}
			end
		end
	end

	function obj.addInput(x,y,width,_replace,_placeholder,_callback,_BG,_FG,_PHFG)
		elements[#elements + 1] = {width = width, text = "", rep = _replace or false, id = lastid+1,element="INP", x = x, y = y, placeholder = _placeholder or "", callback = _callback or function() end, bg = _BG or colors.lightGray, fg = _FG or colors.black, placecol = _PHFG or colors.gray}
		local id = lastid + 1
		lastid = lastid + 1
		return id
	end
	

	function drawInput(id)
		local toDraw = {}
		vp.setCursorPos(elements[id].x,elements[id].y)
		vp.setBackgroundColor(elements[id].bg)
		for i=1,elements[id].width do
			vp.write(" ")
		end
		if #elements[id].text  == 0 then
			vp.setTextColor(elements[id].placecol)
			for i=1,#elements[id].placeholder do
				toDraw[i] = elements[id].placeholder:sub(i,i)
			end
		else
			vp.setTextColor(elements[id].fg)
			for i=1,#elements[id].text do
				toDraw[i] = elements[id].text:sub(i,i)
			end
		end
		vp.setCursorPos(elements[id].x,elements[id].y)
		if #toDraw > elements[id].width then
			for i=1,elements[id].width - 3 do
				if elements[id].rep and #elements[id].text > 0 then vp.write(elements[id].rep) else vp.write(toDraw[i]) end
			end
			vp.write("...")
		else
			for i=1,#toDraw do
				if elements[id].rep and #elements[id].text > 0 then vp.write(elements[id].rep) else vp.write(toDraw[i]) end
			end
		end
	end
	
	function obj.alterInput(id,_x,_y,_width,_text,_replace,_placeholder,_callback,_bg,_fg,_phfg)
		for i=1,#elements do
			if id == elements[i].id then
				local id = elements[i].id
				local element = "INP"
				local x = _x or elements[i].x
				local y = _y or elements[i].y
				local width = _width or elements[i].width
				local text = _text or elements[i].text
				local replace = _replace or elements[i].rep
				local placeholder = _placeholder or elements[i].placeholder
				local callback = _callback or elements[i].callback
				local bg = _bg or elements[i].bg
				local fg = _fg or elements[i].fg
				local phfg = _phfg or elements[i].placecol
				elements[i] = {id=id,element=element,x=x,y=y,width=width,text=text,rep=replace,placeholder=placeholder,callback=callback,bg=bg,fg=fg,placecol=phfg}
			end
		end
	end
	function obj.getInput(id)
		for i=1,#elements do
			if id==elements[i].id then
				return elements[i].text
			end
		end
	end
	
	function handleInput(id)
		local svp = window.create(vp,elements[id].x,elements[id].y,elements[id].width,1,true)
		svp.setBackgroundColor(elements[id].bg)
		svp.setTextColor(elements[id].fg)
		svp.clear()
		svp.setCursorPos(1,1)
		local old = term.current()
		term.redirect(svp)
		if elements[id].rep == false then elements[id].rep = nil end
		local input = aread(elements[id].rep, elements[id].text)
		term.redirect(old)
		elements[id].text = input
		elements[id].callback(input)
	end
	
	function obj.redraw()
		vp.setBackgroundColor(bg)
		vp.clear()
		for i=1,#elements do
			if elements[i].element == "BTN" then
				drawButton(i)
			end
			if elements[i].element == "LBL" then
				drawLabel(i)
			end
			if elements[i].element == "INP" then
				drawInput(i)
			end
		end
	end
	function obj.alert(text, _title, _titlefg, _border, _middlebg, _middlefg, _buttonbg, _buttonfg)
		local xx, yy = vp.getSize()
		xx = xx / 2
		yy = yy / 2
		local bcol = _border or colors.red
		local titlecol = _titlefg or colors.black
		local title = _title or "ALERT"
		local mcolbg = _middlebg or colors.black
		local mcolfg = _middlefg or colors.white
		local buttonbg = _buttonbg or colors.lightGray
		local buttonfg = _buttonfg or colors.black
		vp.setCursorPos(xx-10,yy-2)
		vp.setBackgroundColor(bcol)
		vp.setTextColor(titlecol)
		for i=1,20 do
			vp.write(" ")
		end
		vp.setCursorPos(xx-10,yy-2)
		vp.write(title)
		vp.setCursorPos(xx-10,yy-1)
		for i=1,20 do
			vp.write(" ")
		end
		vp.setCursorPos(xx-9,yy-1)
		vp.setBackgroundColor(mcolbg)
		for i=1,18 do
			vp.write(" ")
		end
		vp.setCursorPos(xx-9,yy-1)
		vp.setTextColor(mcolfg)
		vp.write(text)
		vp.setCursorPos(xx-10,yy)
		vp.setBackgroundColor(bcol)
		for i=1,20 do
			vp.write(" ")
		end
		vp.setCursorPos(xx+8,yy)
		vp.setBackgroundColor(buttonbg)
		vp.setTextColor(buttonfg)
		vp.setBackgroundColor(buttonbg)
		vp.write("OK")
		os.pullEvent("mouse_click")
		obj.redraw()
	end
	function obj.exit()
		stop = true
		os.queueEvent("_")
	end
	function obj.go()
		while stop == false do
		local ev = {os.pullEventRaw()}
		if ev[1] == "terminate" and at == true then break end
		for i=1,#elements do
			if elements[i].element == "BTN" then
				if ev[1] == "mouse_click" then
					--print("Mouse click")
					if ev[4] == elements[i].y then
						--print("Y correct")
						--print("X: " .. ev[3] .. " Y: " .. ev[4] .. elements[i].x .. " to " .. elements[i].x + #elements[i].text)
						if ev[3] >= elements[i].x and ev[3] <= elements[i].x + #elements[i].text then
							--print("DOING STUFF")
							--sleep(2)
							elements[i].callback(elements[i].id)
						end
					end
				end
			end
			if elements[i].element == "INP" then
				if ev[1] == "mouse_click" then
					--print("Mouse click")
					if ev[4] == elements[i].y then
						--print("Y correct")
						--print("X: " .. ev[3] .. " Y: " .. ev[4] .. elements[i].x .. " to " .. elements[i].x + #elements[i].text)
						if ev[3] >= elements[i].x and ev[3] <= elements[i].width then
							--print("DOING STUFF")
							--sleep(2)
							handleInput(i)
						end
					end
				end
			end
		end
		--sleep(1)
		obj.redraw()
		end
	end

	return obj
end
