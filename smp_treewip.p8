pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- initialize
-- whitney 

t = true
f = false
	 
function _init() 
	
	roomsetup() 
	dtb_init()
	
	m = ""
	
	tick = 0
	state = 0 
	step = 0
	select = 1
	
	plr = {
		pnme = "",
		x=1,
		y=1,
		w=6,
		h=8,
		
		moving = f,
		inven = {}
	} 
 
 box = {
		sp=112,
		x=8,
		y=16,
		w=8,
		h=8
	}
	 
	--spawn(settype())
	--gen_room() 
  
end
 
function setxy()
	--for gen 
	px = plr.x/8
	py = plr.y/8
end 

function roomsetup()
	
	rooms = {}
	world = {}
	
	lvl = 1 -- keeps track of where the player is
	pr = 0 -- keeps track so we can access our rooms
	roomtracker = 1 
	
	rm = {
		max_goal = 3,
		max_exit = 2,
	}
end 
-->8
-- gen

function spawn(rtype) 
	 
	--defaults
	rx,ry = 15,15
 xlim,ylim,num=1,1,8  
	
	rm.c = 3 
	--set sprite of char
	psp = 64
	
	rm.type = rtype
	rm.max_goal = 1 
	
	--room cleared is if the room is finished.
	-- can pass is if character can go to the next room
	rm.roomcleared = f
	rm.canpass = f	--quest variables
	rm.gettrash = f
	
	
	if rm.type == "forest" then 
		  
		rm.max_goal = 3
		--potential items to be spawned
		rm.pot_elms = {1,2,3,16,
		17,18,36,50,51,20,52}
		
		--goals and exits 
		rm.pot_goals = {53,54,55,35,19}
		
		if tograndma then 
			rm.pot_exits = {26}
			plr.x = 8
			plr.y = 8
		else 
			rm.pot_exits = {132}
			plr.x = 112
			plr.y = 56
		end  
	
	--beach 
	elseif rm.type == "beach" then
		
		num,ry,beach,lim = 9,10,4
		
		rm.c = 15 
		
		plr.x = 58 
		plr.y = 0
		
		px = 8
 	py = 5 
		
		--trash quest counter
		rm.trashcount = 0
		rm.max_goal = 2 
		ylim = 4 
		
		rm.pot_elms = {16,17,28,36,89,115,116}
		
		rm.pot_goals = {15,48,54,63,94,
		37}
		rm.pot_exits = {9}
	
	elseif rm.type == "cave" then 
	 
	 xlim,ylim,ry,rx = 3,3,13,13
 	
 	rm.c = 0
 	
	 plr.x = 56
		plr.y = 104 
		
	 rm.max_exit = 0 
		rm.pot_elms = {28,36}
		
		rm.pot_goals = {31}
		rm.pot_exits = {132,84}
 	
	elseif rm.type == "town" then 
	
		plr.x = 64
		plr.y = 11
		
		rm.max_exit = 0
		rm.max_goal = 1 
		
		rm.pot_goals = {55,114} 
		rm.pot_elms = {} 
		rm.pot_exits = {132}  
	end 
	
	setxy()
	
end

s1= ""
m="" 
m2 = ""
-- generate the room
-- tiles, exits, and goals 
function gen_room()
	
	rm.tiles = {} 
	addentrances(rm)
	
	if cave then 
		--add torches randomly
		crng = flr(rnd(5)) + 4 
		crng2 = flr(rnd(7)) + 6
		
		temp = {x=crng,y=2,s=78}
		temp2 = {x=crng2,y=2,s=78}
 	
 	add(rm.tiles,temp)
 	add(rm.tiles,temp2) 
	end   
	
	--build the goals and exits 
	rm.num_goals = flr(rnd(rm.max_goal)+1)
	rm.goals = {} --store the goals
	
	rm.num_exits = flr(rnd(rm.max_exits)+1)
	rm.exits = {}
	
	--how many placed so far 
	cgoal,cexit = 1,1
	
	--gets our specifics goals 
	-- and exits for room 	
	for i=0, rm.num_goals do 
 	goal = rm.pot_goals[flr(rnd(#rm.pot_goals)+1)]	 
		add(rm.goals, goal)
		
		ex = rm.pot_exits[flr(rnd(#rm.pot_exits)+1)]
		add(rm.exits, ex)
	end 
	
	--places tiles randomly 	  
	for i = xlim, rx-1 do 
		for j = ylim, ry-1 do 
		 
		 if not checkoccupied(i,j) then 
				--pick a random element
				rand_elm = rm.pot_elms[flr(rnd(#rm.pot_elms)+1)]
				temp = {}
				
				--temp
				temp.x = i
				temp.y = j
				temp.s = 0
			
				--add start point 
				if i == px and j == py then
					if rm.type == "forest" then
						temp.s = 131
					elseif rm.type=="cave" and i == px and j == py-1 then
						temp.s = 159 
					end 
				--random elem
				elseif rnd(10)+1 > num then
				
					temp.s = rand_elm
					temp.path = f
					
					
					--tree and other stuff
					--if palm tree
					if temp.s == 89 then
						placenext(i,j,90,73,74,89)
						if cplace then 
							temp.s = 0 
						end  
					--if its a regular tree or fern tree
					elseif temp.s == 20 or temp.s == 57 then
						placenext(i,j,21,4,5,20)
						if cplace then 
							temp.s = 0 
						end
					elseif temp.s == 116 then
						--trigger trash quest
						--for little quest
						rm.trashtrigger = t
						rm.trashcount += 1
						--quest trigger    
					end 
					 
				--add our goals
				elseif rnd(10)+1 < 4 and cgoal < rm.max_goal and i > 2 and j > 3  then 
					temp.s = rm.goals[cgoal]
					temp.path = t 
					cgoal += 1
				
				--exits	
				elseif rnd(10)+1 < 4 and cexit < rm.max_exit and i > 3 and j > 4 and j < 14 then
					temp.s = rm.exits[cexit]
					temp.path = t
					cexit += 1
				
					--next room
					temp.nr = {}
				
					--add a house
					if temp.s == 26 then
						placenext(i,j,27,10,11,26)
						addon(i,j,17)
					elseif temp.s == 9 then 
						temp.y = 3
						--prevent overlap 
						if i == 7 or i == 8 then 
							temp.x = 6
						end 
					addon(i,temp.y,17)
					
					--dirt exit
					elseif temp.s == 132 then 
					
						positionsx = {7,15}
						temp.x = positionsx[flr(rnd(#positionsx))+1]
					
						--determine y 
						if temp.x == 7 then 
							temp.y = 0 
						elseif temp.x == 15 then 
							temp.y = 7 
						end  
					end --end temp
							
				end--end elseif  
			
				--if s isnt 0 
				if temp.s != 0 then
					s1 = s1..temp.x.." "
					add(rm.tiles,temp)
				
					for i in all(rm.tiles) do
						m = i.x
					end 
		
					n = #rm.tiles
				end
			
			--end if occupied 
			end  
			
		end --end j 
	end -- end i  
	
	--if no path regen 
	for i in all(rm.tiles) do
 	if i.path then
 	 if not findpath(i.x, i.y) then 
 	 	gen_room()
 	 end  
  end
 end
	 
	add(rooms,rm) 
	
	setitems(rm.tiles)
end

--add entrance
function addentrances(rm)
	
	temp = {} 
	if rm.types == "cave" then 
		temp.x = 8
		temp.y = 13
		temp.s = 132
		temp.pr = lvl
	end 
	
	add(rm.tiles,temp)
end

--deletes the map being printed
function delmap(til)
	for i in all(til) do
		mset(i.x,i.y,0)
	end 
end 

--checks if an element is in the tiles
function checkelem(spn,til)
	local isthere = f 
	
	for i in all(til) do
		if i.s == spn then 
			isthere = t 
		end 
	end 
	
	return isthere	
end 

--deletes a sprite blocking 
function delelem(x,y,til,rsp)
	for i in all(til) do 
		if i.x == x and i.y == y then 
			del(til,i)
		end
	end 
	
	mset(x,y, rsp)
end 

-- this function checks
-- if the tile is occupied
function checkoccupied(x,y)
	
	occupied = false
	
	for i in all(rm.tiles) do
	 if i.x == x and i.y == y then
	 	 occupied = true 
	 end 
	end 
	
	return occupied   
end 
 	
--add around in a squr 
function placenext(i,j,s1,s2,s3,sp) 
	
	cplace = f 
	
	if not checkoccupied(i+1,j) 
	and not checkoccupied(i,j-1) 
	and not checkoccupied(i,j-1)
	and not checkoccupied(i+1,j-1)
	or sp == 26 then
	
		temp2 = {x=i+1,y=j,s=s1}
		temp3 = {x=i,y=j-1,s=s2}
		temp4 = {x=i+1,y=j-1,s=s3}
									
		add(rm.tiles,temp2)
		add(rm.tiles,temp3)
		add(rm.tiles,temp4)
	else
		cplace = t 
	end 
	 
end 

--add in front of things
function addon(i,j,s)   
	temp5 = {x=i,y=j+1,s=s}
	add(rm.tiles,temp5)
	
	delelem(i,j+1,rm.tiles)
end 


--check if the node is visited
function checkvisited(visted,x,y)
 
 visit = false 
 for i in all(visited) do
 	if i.x == x and i.y == y then 
 		visit = true
 	end
 end 
 
 return visit
end 
 
-- doesnt work and needs condensing     
function findpath(i,j)
	
	--source 
	s = {x=i,y=j}
	q = {s} 
	
	--keep track
	visited = {}

	
	for s in all(q) do 
		
		if s.x != px and s.y != py then 
				--x+1, y 
			if not fget(mget(s.x+1,s.y),0) and not checkvisited(visited,s.x+1,s.y) then
				add(q,{x=s.x+1,y=s.y})
				
			end 
				
			--x-1, y 
			if not fget(mget(s.x-1,s.y),0) and not checkvisited(visited,s.x-1,s.y)  then 
				add(q,{x=s.x-1,y=s.y})

			end
			
			--x,y+1
			if not fget(mget(s.x,s.y+1),0) and not checkvisited(visited,s.x,s.y+1)  then
				add(q,{x=s.x,y=s.y+1})
			
			end 
				
			--x, y -1 
			if not fget(mget(s.x,s.y-1),0) and not checkvisited(visited,s.x,s.y-1)  then 
				add(q,{x=s.x,y=s.y-1})
			end
			
			--[[if not checkvisited(s.x,s.y) then
				add(visited,s)
			end 
			--]]
			
			del(q,s)
			
		else
			-- path exists
			r = t
			break
			
		end-- if
		  
	end --end for
 
	return r
	  
end 

-->8
-- collision
map_tile=0
 
function getitem(item)
		
		d = "picked up a"
		
		if item == 35 then 
			d = d.."n" 
			ni="apple"
		elseif item == 19 then 
			ni="potion"
			potion = t 
		elseif item == 31 then
			ni="gem"
		elseif item == 53 then 
			ni="mushroom"
		elseif item == 54 then 
			ni="nugget"
		elseif item == 94 then 
			ni="coconut"
		else
			ni="unknown item" 
		end 
		
		o = {n=ni, sp=item}
		show = t
		dtb_disp(d.." "..o.n..".")
		
		if #plr.inven < 8 then 
		
			add(plr.inven, o)
			delelem(grid_x,grid_y,rm.tiles,0) 
		
		else
			dtb_disp(d.."\n... but i can't fit it in \nmy bag..")
		end  		
end 

--collision 
function collide_map(obj,flag)
	
	local x=obj.x local y=obj.y
	local w=obj.w local h=obj.h
	
	local x1=x local y1=y
	local x2=x+w-1 local y2=y+h-1
	
	x1/=8  x2/=8
	y1/=8  y2/=8
	
	if fget(mget(x1,y1),flag)
	or fget(mget(x1,y2),flag)
	or fget(mget(x2,y1),flag)
	or fget(mget(x2,y2),flag)
	
	--for map 
	or fget(mget(x1+offsetx,y1+offsety),flag)
	or fget(mget(x1+offsetx,y2+offsety),flag)
	or fget(mget(x2+offsetx,y1+offsety),flag)
	or fget(mget(x2+offsetx,y2+offsety),flag) then
		return true
	else
		return false
	end

end

--check the bounds when going 
--to a new room 
function checkbounds()
	-- if rm.trashcount != nil or 0
	-- do not let thru 
	bump,bumpu,bumpd,bumpl,bumpr = f 
	
	if plr.y < 0 then 
		plr.y += 1
		bump = t
		bumpu = t 
	elseif plr.y > 128 then
		plr.y -= 1
		bump = t 
		bumpd = t 
	elseif plr.x < 0 then 
		plr.x += 1 
		bump = t
		bumpl = t  
	elseif plr.x > 120 then 
		plr.x -= 1
		bump = t
		bumpr = t 
	end 
	
	if bump then 
		rm.roomcleared = f 
		--if trash
		if rm.trashcount != 0 and not rm.roomcleared then 
			dtb_disp("i haven't picked up all the trash yet.") 
		elseif not rm.roomcleared then
			dtb_disp("i still have something to do here.")
		elseif beach and bumpu and rm.roomcleared then
			delmap(rm.tiles)
			spawn("cave")
			gen_room() 
		end
		
	end  
end
-->8
-- dialoge -- animations

--functions from lexaffle  
function dtb_init(numlines)
 dtb_queu={}
 dtb_queuf={}
 dtb_numlines=3
 if numlines then
  dtb_numlines=numlines
 end
 _dtb_clean()
end

-- this will add a piece of text to the queu. the queu is processed automatically.
function dtb_disp(txt,callback)
 local lines={}
 local currline=""
 local curword=""
 local curchar=""
 local upt=function()
 	if #curword+#currline>29 then
 	 add(lines,currline)
 	 currline=""
	 end
  currline=currline..curword
  curword=""
 end
 for i=1,#txt do
  curchar=sub(txt,i,i)
  curword=curword..curchar
  if curchar==" " then
  	upt()
  elseif #curword>28 then
   curword=curword.."-"
   upt()
  end
 end
 upt()
 if currline~="" then
  add(lines,currline)
 end
 add(dtb_queu,lines)
 if callback==nil then
  callback=0
 end
 add(dtb_queuf,callback)
end

-- functions with an underscore prefix are ment for internal use, don't worry about them.
function _dtb_clean()
 dtb_dislines={}
 for i=1,dtb_numlines do
  add(dtb_dislines,"")
 end
 dtb_curline=0
 dtb_ltime=0
end

function _dtb_nextline()
 dtb_curline+=1
 for i=1,#dtb_dislines-1 do
 dtb_dislines[i]=dtb_dislines[i+1]
 end
 dtb_dislines[#dtb_dislines]=""
 sfx(2)
end

function _dtb_nexttext()
 if dtb_queuf[1]~=0 then
  dtb_queuf[1]()
 end
 del(dtb_queuf,dtb_queuf[1])
 del(dtb_queu,dtb_queu[1])
 _dtb_clean()
 sfx(2)
 
 state = 1 
end

-- make sure that this function is called each update.
function dtb_update()
 if #dtb_queu>0 then
 state = 2 
  if dtb_curline==0 then
    dtb_curline=1
  end
 local dislineslength=#dtb_dislines
 local curlines=dtb_queu[1]
 local curlinelength=#dtb_dislines[dislineslength]
 local complete=curlinelength>=#curlines[dtb_curline]
 if complete and dtb_curline>=#curlines then
 if btnp(4) then
  _dtb_nexttext()
  return
 end
 elseif dtb_curline>0 then
  dtb_ltime-=1
 	if not complete then
   if dtb_ltime<=0 then
    local curchari=curlinelength+1
    local curchar=sub(curlines[dtb_curline],curchari,curchari)
    dtb_ltime=1
    if curchar~=" " then
    	sfx(0)
    end
    if curchar=="." then
     dtb_ltime=6
    end
    	dtb_dislines[dislineslength]=dtb_dislines[dislineslength]..curchar
    end
    	if btnp(4) then
    		dtb_dislines[dislineslength]=curlines[dtb_curline]
    	end
   else
    if btnp(4) then
     _dtb_nextline()
    end
   end
  end
 end
end

-- make sure to call this function everytime you draw.
function dtb_draw()
 if #dtb_queu>0 then
  local dislineslength=#dtb_dislines
  local offset=0
  if dtb_curline<dislineslength then
   offset=dislineslength-dtb_curline
  end
  rectfill(2,125-dislineslength*8,125,125,0)
  if dtb_curline>0 and #dtb_dislines[#dtb_dislines]==#dtb_queu[1][dtb_curline] then
    print("\x8e",118,120,1)
  end
  for i=1,dislineslength do
   print(dtb_dislines[i],4,i*8+119-(dislineslength+offset)*8,7)
  end
 end
 
end

-- anim
--animation
function anim(o,sf,nf,sp,fl,isob)
  if(not o.a_ct) o.a_ct=0
  if(not o.a_st) o.a_st=0
		
		--print(sp.." hey ")
		
  o.a_ct+=1
	 
  if(o.a_ct%(30/sp)==0) then
    o.a_st+=1
    if(o.a_st==nf) o.a_st=0
  end

  o.a_fr=sf+o.a_st
  
  x = o.x 
  y = o.y 
  
  --if animating and oj 
  if isob == t then 
  	x= o.x * 8
  	y= o.y * 8
 	end 
 	
 	spr(o.a_fr,x,y,1,1,fl)
end

function draw_menu(t1,t2) 
	
	if select == 1 then
		t1 = "➡️"..sub(t1,1)
	elseif select == 2 then 
		t2 = "➡️"..sub(t2,1)
	end
	 
	print(t1,16,120)
	print(t2,80,120)

end

-- use the selection menu for 
-- our shop 
function use_menu()	
	if btnp(0) then
		if not (select % 2 == 1) then
			select-=1
		end
	elseif btnp(1) then
		if not (select % 2 == 0) then
			select +=1
		end
	elseif btnp(5) then
	 selected = true
		selection = select
	end
	
	selection_check()
	
end

--checks which one were trying to do
function selection_check()
	if selected then
		selected = false
		if selection == 1 then 
		 choice = "forest"  
		else 
			choice = "beach" 
		end
		 
	end 
end  
-->8
-- update & draw

function _update()
	
	tick += 1 
	 
	if state == 0 then 
		if btnp(4) then 
			step+=1
		end	
	
	elseif state == 1 then  
		 
		plr.moving = f
		move_plr() 
		 
		grid_x = flr(box.x/8)
		grid_y = flr(box.y/8)
		
		map_tile = mget(grid_x,grid_y)
		
		--activate picking up things
		if btnp(5) then 
			trigger()
		end
		
		quests()
	
	elseif state == 2 then 
		plr.moving = f 
		
	end
	
	dtb_update()  
end  


-- spr( n, x, y, [w,] [h,] [flip_x,] [flip_y] ) 
function _draw()
	
	cls(0)
	
	
	if state == 0 then 
		intro()
	else 

	--offsets
	offsetx = 0
	offsety = 0
	
	--display current room 
	print("x "..s1)
	print("m "..m)
	print("length"..n)
	--displayroom()
	
	npalt(64)
	if plr.moving then 
		
		eflp,sf,sp,nf = f,81,6,2
		 
		if plr.move == "l" then 
			eflp = t
		elseif plr.move =="u" then 
			sf = 67 
		elseif plr.move == "d"	then 
			sf = 65
		end 
		
		anim(plr,sf,nf,sp,eflp)
	else
	 spr(psp,plr.x,plr.y,1,1,spf) 
	end  	
	
	--draw reticle
	if fget(map_tile,1) or fget(map_tile,6) then
		box.sp = 117
	else
		box.sp = 112 
	end 
	
	spr(box.sp, box.x, box.y)
	
	draw_bar()

	dtb_draw()
	
	end 
end

--function to change color
function npalt(s)
	if fget(s, 7) then
		palt(0, f)
		palt(3, t)
	else 
		palt(0,t)
		palt(3,f)
	end 
end 

function setitems(til)
	for i in all(til) do 
		mset(i.x,i.y,i.s)
	end 
end 

function draw_bar() 
 
	for i = 4, 11 do
		npalt(113) 
		spr(113,i*8,120)
	end 
	
	local j = 4 
	for i in all(plr.inven) do 
		npalt(i.sp)
		spr(i.sp,j*8,120)
		j+=1
	end 
end 

--display the current room
function displayroom()  
	
	cls(croom.c)
	
	if croom.type == "house" then
		map(16,0,0,0,16,16)
		npalt(62)
		
		--offsets
		offsetx = 16 
		offsety = 0
		
		spr(62,48,48)
		mset(6,6,62)
	else
		--beach background 
		if croom.type == "beach" then
		
			offsetx = 32 
			offsety = 0
		 
			npalt(0)
			map(32,0,0,0,16,16)
			
			
		elseif croom.type == "cave" then
			
			offsetx = 48
			offsety = 0
			 
			npalt(0)
			map(48,0,0,0,16,16)
		elseif croom.type == "forest" then 
		
			offsetx = 0
			offsety = 16
			
			npalt(0)
			map(0,16,0,0,16,16)
		elseif croom.type == "town" then
		
			offsetx = 64
			offsety = 0 
 
			npalt(0) 
			map(64,0,0,0,16,16) 
		end
		
		for i in all(croom.tiles) do 
			
			npalt(i.s)			
	 	
	 	if i.s == 55 then
	 		anim(i,55,2,1,f,t)
	 		
			elseif i.s == 78 then
	 		anim(i,78,2,1,f,t)
			else
	 		spr(i.s,i.x*8,i.y*8)
			end 
		end
		
		if rm.type == "forest" then 
			npalt(0)
			map(0,17,0,8,16,16)
		end 
	end 
	 
end 
-->8
-- player functions 

function move_plr()
	
	if (btn(0)) then
			plr.x -= 1
			plr.move = "l"
			plr.moving = t
			aim("l") 
			
			--not moving 
			psp,spf= 80,t
 
		if collide_map(plr,0) then
			plr.x +=1
		end
		
		checkbounds() 
		
	elseif (btn(1)) then 
		plr.x +=  1
		plr.move = "r"
		plr.moving = t
		aim("r")
		
		--not moving 
		psp,spf = 80,f 
			
		if collide_map(plr,0) then
			plr.x -=1
		end
		
		checkbounds()  
		
	elseif (btn(2)) then 
		plr.y -= 1
		plr.move = "u"
		plr.moving = t
		aim("u")
		
		--not moving 
		psp,spf = 83,f
	
		if collide_map(plr,0) then
			plr.y +=1
		end
		
		checkbounds()  
	
	elseif (btn(3)) then 
		plr.y += 1
		plr.move = "d"
		plr.moving = t
		aim("d")
		
		--not moving 
		psp,spf= 64,f 
		
		if collide_map(plr,0) then
			plr.y -=1
		end
		
		checkbounds() 
		
	end 
end

function aim(b)
	if b == "l" then
		box.x = flr(plr.x)-8
		box.y = plr.y
	elseif b == "r" then
		box.x = flr(plr.x+7)
		box.y = plr.y
	elseif b == "u" then
		box.x = plr.x
		box.y = plr.y-7
	elseif b == "d" then
		box.x = plr.x
		box.y = plr.y+8
	end
end

function trigger()
	
	if fget(map_tile,1) and map_tile != 116 then 
		getitem(map_tile)
	elseif map_tile == 116 then 
		pickuptrash(grid_x,grid_y,rm.tiles) 	
	elseif map_tile ==12  then
		
		nextroom(current,rtype,rm,map_tile)
		
	elseif map_tile == 26 then 
		delmap(rm.tiles)
		house = t
		plr.x = 56
		plr.y = 88 
		c = 0
	elseif map_tile == 62 then
		d = "hello!"
		show = t
	elseif map_tile == 9 then 
		delmap(rm.tiles)
		spawn("cave")
		gen_room()
		
		generateroom(room[lvl],rtype,map_tile)
	
	elseif map_tile == 37 then 
		dtb_disp("a chest! wonder what's inside?")
		
		delelem(grid_x,grid_y,rm.tiles,38) 
		temp = {x=grid_x,y=grid_y,s=38}
		add(rm.tiles,temp)
		
		dtb_disp("... it was empty!")
		
	end
 
end
-->8
--game state
 
--introdunction to the game 
function intro()
	
	if step == 0 then 
		print("aren't you going to be late, red?\nyou are suppose to help your \ngrandma out today!")
		npalt(64)
		sspr( 0, 32, 8, 8, 32, 32,48,48 )
	elseif step == 1 then 
		print("let's go over the controls.")
	elseif step == 2 then 
		print("to walk around, use ⬅️➡️⬆️⬇️\nbuttons on your keyboad.")
	elseif step == 3 then
		print("to interact with stuff, use the\n❎ button!")
	elseif step == 4 then 
		print("you should take your grandma\na gift.")
	elseif step >= 5 then
		print("do you think she\nwould like something\nfrom the forest or beach?")
		draw_menu("forest","beach")
		use_menu()
		
		if choice != nil then 
			spawn(choice) 
			gen_room()
			croom = rooms[1]
			
			state = 1 
		end 
		
	end   	
end

--little function for trash side quest
function pickuptrash()

	delelem(grid_x,grid_y,rm.tiles)
	
	rm.trashcount -= 1
	
	if rm.trashcount > 0 then  
		dtb_disp("picked up some trash.only "..rm.trashcount.." left!")  
	else 
		dtb_disp("found all the trash! i feel good cleaning up the beach!")
	end 
	show = t 
end 

function quests()
	
	qtriggers(rm.tiles)
	
	if tick % 100 == 1 then
	
		--trash quest   
		if rm.trashtrigger and rm.trashcount > 0 then 
			dtb_disp("look at all this trash!\n gross!")
	  dtb_disp("let's clean it up before we see grandma." )  
			
			rm.trashtrigger = f 
		end 
				
	end
	
	--potion quest 
	if gmeds and potion then 
		dtb_disp("wonder if grandma can use this? let's take it to her.")
		potion = f 
	end
	 	 
end

--quest list and triggers 
function qtriggers(tiles)
--potion quest
	--gmeds,gapples,grilledmush,storytime,
	if checkelem(19,tiles) then 
		gmeds = t 	
	elseif checkelem(35,tiles) then 
		gapples = t 
	elseif checkelem(53,tiles) then 
		if checkelem(55,tiles) then 
			grilledmush = t
		end 
	elseif checkelem(55,tiles) then 
		storytime = t
	elseif gemtalk then 
		gemhunt = t 
	elseif checkelem(63,tiles) then 
		basket = t 
	end 
	
end  

 
-->8
-- transversing trees  

--room exit, spr
function addnextroom(rm,tl,lvl)
	
	--if the tile passed over or
	--clicked, compare
	e = getexit(rm,tl) 
	add(e.nr,lvl+1)
	
end  


--prev room
function addprevroom(rm,tl) 
	
	e = getexit(rm,tl) 
	add(e.pr,pr)

end 


--takes in type,room  
function generateroom(rm,rtype,rm,tl)
	
	spawn(rtype)
	gen_room()
	
	--updates current tiles link
	addnextroom(rm,tl,lvl)
	lvl+=1  
	
end 

function moverooms(rm,tl)
	
	e = getexit(rm,tl)
	
	currentroom = rooms[e.nr]
end 

--get exit 
function getexit(rm,tl)
	for i in all(rm.tiles) do 
		if i.s == tl and i.x == grid_x and i.y == grid_y then 
			return i
		end 
	end 	
end 
__gfx__
0000000000000000000b000000000000000000bbbbbb1000bbbbbbbb000000000000b00b42000024000000000000000033333333000001110011100000000000
000000000000000000bb0b0000000bb0000bbbbbbbbb3100111111120b0b1bbbbb0000b140000004002222222222220033900933011115651155511100666610
000000000000000000bbbbb00bb88bbb00bbbbbbbbbbb310221222240001411111bbbb1420000002028888888888882030955903155565555556555566111155
0000000000bb0b000bbbb8b000b82b110bbbbbbbbbb3b33142224424011444444411114420000002888888888888888805999950165666665656666506666651
000000000bbbbbb00b8bbbb00bbbbbb0bbbbbbbbbbbb3331442444440b1444424444444440000004888888888888888800400400156665666666666606666651
000000000bb11bb00bbb8b10b111bbb0bbbbbbbbbbb3b331444442440b1442444424444440000004882ee222222ee28800000000155666666666665606666551
000000000b1000b001bbbb10100011b01b13bbbbb3b33331424444240b1444444444444440000004ee111111111111ee30000003015566566565666601665510
0000000000000000000000000000000001313bbbbb33131044424424b14444444444424420000002111111111111111133333333015666666666666600111100
000000000666000000009000334443330011113b3131311044444444b14444444444444400000000116122215166651133333333344444430400004000000000
00000000066660660009a900330203330001111111111100444444440b144444444444240000000016122222115651613333333344003344044774400f00f000
0040044001111011000090003303033300000111111000001424424400b144424424444400156000151222226615166133666033400b2204047777400fe0f0f0
44424000000000000000000030373033000000242200000042124424b0b144444444444400615000111222225651611136666603444b4444048888400ee0eee0
2444442060066006000000900878820300000024420000001121121100b144444442444400665000161222291511516106666550400000040888888000feefef
1122444410666600090009a90888220300000214242000002212212200b142444444444400516000151222225115161105555550480010340888888000fefee0
00111422006661009a900090308220330000211122122000131311310b144444424442440011100011122222561165113055550348991234088888800eefee00
000004116601106009000000330003330000000020000000333333330b1444444444444400000000111111111111111133333333444444440880088000000000
0000000000000000cccccccc00000000333333330000000000044000300333333003333300000000000000000077077022222222000000000000000000000000
0000077777700000c77ccc7c00010000333663330000000009444490042033330420333300000000b0000000c77c777742224242222222220009000000033000
770077cccc770077cccc7ccc028122003066666304244240044aa44004200000042033330000000bb000000077c7c7c742422242888888880088800000bbb300
c7777cccccc7777ccccccccc28e8881006666110244444422111111204204444042033330000000bbb0000000cccc7c04442422288888888000200000bbbb330
cc77cccccccc77cccccccccc28888810666666119aaaaaa9411111140420222204203333000000bbbbb000000cccc7c042424244888888880b0b0b0000003330
ccccccc77cccccccc77ccccc02888100166611112449944224499442042000000420333300000bbbbbb000000c7cccc0424442242222222200bbb00000033330
77cc77cccc77cc77ccccc77c0021100001111110224224222242242204203333042033330000bbbbbbbb00000c7cccc02442442411111111000b000000333300
cc7cccccccccc7cccccccccc0000000030000003022222200222222032233333322333330001bbb3b333b0000cccc7c022424242111111110000000000000000
000000e000000000000000000000000000bbbb000088820000000000000009000009000001113b33bb311b000cccccc000000000656665660066600000999900
00000ee00b0b0bb00800000000bbbbb00bbbbbb008e888200000000000a0900000000090000113313b1100000ccc7cc000000000115651650666660009000090
000eefe00bbb0b00888000000bbbbbbbbbbbbbbb88888882000a9000000909000000900000013311131110000ccc7cc00444444016151651061f160009000090
0eeefee0013bb310098b00000bbbbbbbbbbbbbbb2882282200aaa9000089a9800089a9000011111111111100077cccc0044444401651611600fff0009a9009a9
e22efee0122222218080b0000bbbbbbbbbbbbbbb0222222000aa99000089a9800089a980011110211210111077cc7c70002992001511566100ccc00009a99a90
e222ee00144442210000b0000bbbbbb11bbbbbb1000fe00000099000044448000444480000100024242000000777c77700222200611516160c9c9c00099aa990
ee22ee00014422100bb0b00001bbbb1111bbbb1100ffe00000000000422024444220244400002244141200007777777000200200561165150c777c0000999900
0eeee00000142100000b0000001111100111111000fe000000000000000002400000024000000021002000000000700700000000155155510c666c0000000000
33383833333838333333333333383833333838330000000033360333b000000b0000000b00033333003333113333333333333333cc666ccc0080000000080000
338888833388888333383833338888833388888300000000337660331bbbbbb10000000b00003333333311103333333333333333cc666ccc0009800000898000
3381f1833381f1833388888333888883338888830000000033726033411111210000000b00003111131100003333377733333333cc666ccc0089800000898000
338fff83338fff833381f18333888883338888830000000037422203424444210000000b00331133114000003333777737777733cc666ccc0088800000888000
3388888333f88883338fff8333888883338888830000000034446223244242410000000b03313333144400003377777777777733cc666ccc0024200000242000
33fd8df3338d8d83338888f333888883338888830000000034442220444444420000000b33333003314240003377777777777603cc666ccc0024200000242000
33811183338111f3338d8d8333888883338888830000000044422220442444220000000b33300003310440003777777666776666cc666ccc0002000000020000
333131333331313333f1118333333133333133330000000044422222444442110000000b00000003310424003677776666666666222222220000000000000000
333383333333833333338333333838330090090044444444cccccccc44444421ffffffff00000003310244003366776666666660444444440000000000000000
333888333338883333388833338888830049940022222222cccccccc44444442ffffffff00000003310442003366666666666603444444440000000000000000
333888333338883333388833338888830040040011111111cccccccc44444442ffffffff00000000100222003306666666666633444444440004440000000000
333888333338883333388833338888830044440022222222cccccccc14244241ffffffff00000000102444003336666600666033444444440042442000c00000
3338d8333388d8333388d833338888830040040022222222cccccccc42124421ffffffff000000000042220033330003330003334444444400444420aac56666
3338f333338fd333388df333338888830d4444d022222222cccccccc11211211ffffffff00000000024444203333333333333333444444440044422000c00000
33881333383113333331133333888883dd4dd4dd11111111cccccccc22122121ffffffff00000000442244203333333333333333444444440002220000000000
333313333331313333131333333131330dddddd022222222cccccccc13131130ffffffff00000000024220003333333333333333444444440000000000000000
cccccccc00000000000000000000000000099900000000b2ccccccccbbb2247cccccccc44422bbbb247ccccc247ccccc16666661000000000000000000000000
cccccccc0009900009000aa000880880009aaa90000000b2cccccc7c22224244ccccccc4244422222427cccc247c7ccc1dddddd1000000000000000000000000
c7cccccc0099aaa00990aaa00800800809aa0aa9000000b2cc7ccccc244444222cc2c444244444440247cccc227ccccc16666661000000000818100000000000
ccccc7cc049aaaa0049aaa000800000809aa0aa9000000b2cccccccc4244444242242242442444420246cccc2477cccc1dddddd10000000081ff282000000000
cccccccc044aaaa0044aaa000080008009aaa0a9000000b2cccccccc444444444444424444444444027ccccc042777cc16666661000000002ff2ff1800000000
ccc7cccc0044aa000044a00000080800009aaa90000000b2cc7ccccc444424444444424444424444027ccccc024427761dddddd100000000282ff18200000000
cccccc7c00044000000440000000800000099900000000b2cccccccc444442444242444444222444247ccccc0022474716666661000000000228288200000000
cccccccc00000000000000000000000000000000000000b2ccccccc7444444444444444444444444247ccccc000022421dddddd1000000000022222000000000
11333311111111110000000000000000000000009933339933333333444444444444444444444444444444440000000000000000000000000000000000000000
133333311000000100ffffff0000aa000000cc009333333933333333444444444444444444444444444444440000000000000000000000000000000000000000
333333331000000100ff4fff0000aa00ccc7c7c03333333333333333142442441424424414244244142442440000000000000000000000000000000000000000
33333333100000010f44f4f00800000000c7cc703333333333333333421244244212442442124424421244240000000000000000000000000000000000000000
33333333100000010ffffff008800090000000003333333333333333112112111121121111211211112112110000000000000000000000000000000000000000
33333333100000010ffffff002000990000008003333333333333333221221222212212222122122221221220000000000000000000000000000000000000000
1333333110000001ff444f00000000000900888093333339333333331312112112121121122211311f1f11f10000000000000000000000000000000000000000
11333311111111110fffff0000000000009000009933339933333333332117777777777777774233ffffffff0000000000000000000000000000000000000000
b0b1bbb0bb0000b111bbb10b01b0b10b01b4410b3333333733333333024777cc777ccccccc777423373333333333333300002222222000222422000000000000
0014111111bbbb14441111000001010000444100333333777333333324777cccccccc7cccccc7742707777777777777700244244442222447474220000000000
11444444441111444444441b4144441b4144441b33333777763333332477cccccccccccccccc7742370000000000000002427776624444266772442000000000
b14444244444444444444441044444414444444433333777666333332277ccccccccccccccccc74237000000000000000247777c77777777cc77724000000000
b1442444442444444442441b14424410444244443333777466603333247cccc7ccccccccccccc742370000000000000024276cccc77ccc7cccc6774200000000
b1444441444444444444441b144444104444444033337774466633332277ccccccccc7cccccc774237000000000000002777cccccccccccccccc772200000000
1444441b114441111144241b1140241b1144441b3333777446660333247ccccccccccccccccc77423700000000000000447ccccccccccccccccc774200000000
144444100b111b0b0b144410000001040b0441043337774742260333247cccccccccccccccccc7423700000000000000276cccccccccccccccccc64200000000
1444441b014441b00144444100b111b00000000033374747426223332777cccc00000000ccccc7423700000000000000246cccccccccccccccccc67200000000
b144441bb1424411b1444441b044441000000000333444444226203322277ccc00000000ccccc74237000000000000002477ccccccccccccccccc74400000000
0b144420b14444441444441b1444441b0000000033474444422222030247cccc00000000ccccc77237000000000000002277cccccccccccccccc777200000000
0b144441b14424444442441b4442441b0000000033744444422222030247cccc00000000cccc7720370000000000000024776cccc7ccc77cccc6724200000000
0b144441144444444244441b4244441b0000000034444444222222230247cccc00000000cccc74203700000000000000042777cc77777777c777742000000000
0b14244bb1444444444444114444441100000000344444442222222022477ccc00000000cccc7420370000000000000002442776624444266777242000000000
b144441b00111144111141001111410000000000444444422222222224277ccc00000000ccc77242370000000000000000224747442222444424420000000000
b1444410b01bbb110bbb1b0b0bbb1b0b0000000044444442222222222467cccc00000000cccc7642370000000000000000002242220002222222000000000000
ffffffff000001110011100000111100666666666666665565666666111111110000000000000000000000000000000000000000000000000000000000000000
ffffffff011115651155511111556510666656566566566666666656111511110000000000000000000000000000000000000000000000000000000000000000
fffffeff155565555556555555565510656666666666655565665666155155150000000000000000000000000000000000000000000000000000000000000000
ffffffff165666665656666565666510666666666656665656666666151111550000000000000000000000000000000000000000000000000000000000000000
ffffffff156665666666666666666610566665656666656155566656111551550000000000000000000000000000000000000000000000000000000000000000
ffefffff155666666666665666656551555565556666555111556566151551110000000000000000000000000000000000000000000000000000000000000000
ffffffff015566566565666665666561111555115656511001565565551115510000000000000000000000000000000000000000000000000000000000000000
ffffffff015666666666666666666551000111006665510000115565151151110000000000000000000000000000000000000000000000000000000000000000
ffffffff155666666666651001556666666655105655110000155666111111510000000000000000000000000000000000000000000000000000000000000000
ffffffff165666566566551001566566656665105655651001156565115515550000000000000000000000000000000000000000000000000000000000000000
fffeffff155656666666655101566666666655516656551115556666155111550000000000000000000000000000000000000000000000000000000000000000
ffffffff016666666656665115566666656666516566655516566666111551110000000000000000000000000000000000000000000000000000000000000000
ffffffff015666566666656115666656666665516666666555666566151511550000000000000000000000000000000000000000000000000000000000000000
ffffffff015565555556555115556666666665106665665655566666155115510000000000000000000000000000000000000000000000000000000000000000
fffffeff015655115651111001566656665665106566666666656656111151510000000000000000000000000000000000000000000000000000000000000000
ffffffff001111001110000001556666666655106666665655666666551551110000000000000000000000000000000000000000000000000000000000000000
__gff__
000001000101010000c10101c101010301000083010101000001410181010103010101038141018181010101000100010300010101430341410101010101010380808080800100010001010000010000808080804100000100000100000003000000000000000001010101010000010080810200028000010101010000000000
0000000000000001010180800101010000000000000000010001800001010100000101010101010000000000000000000001010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000000000000000000000000000000000000000007676767676767676767676767676767600000000000000000000000000000000333434343434393a3334343434343434000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000076767676767676767676767676767676000000000000000000000000000000007676292a76767676760a0b7676767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000060606060606066c6c060606060606060000a5a4a4a4a4a4a4a4a4a4a4a600001176393a12767676761a1b7676762476000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000007a7a7a7a7a7a7a6c6c7a7a7a7a7a7a7a0000b4b7a7a7a7a7b7b7b7b7b7b300007676761276767676768376768c8d8e76000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000045454545454545454545000000a0a0a0a0a0a058585858a0a0a0a0a0a00000b4b7b7b7b7b7a7a7a7a7b7b300007676117676767676767676769c9d9e76000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000454d4d4d4d4d4d4d4d45000000a0a0585858a0a05858a058a0a0a0a0a00000b4b7b7a7a7b7b7b7b7a7b7b3000076767676767676767676767676767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000455d5d5d5d5d5d5d5d45000000a0a05858a0a058a058585858585858a00000b4b7a7a7b7a7a7b7b7a7b7b3000006060606066c06060606060606060606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000455d5d5d5d5d5d5d5d45000000585858585858a0a0a0585858a058a0a00000b4a7a7b7a7a7b7b7b7a7b7b3000016161616166c16161616161616161616000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000455d5d5d5d5d5d5d5d45000000a0a0a0a058a0a0a0a0a0a0a0a0a0a0a00000b4a7a7b7a7b7b7b7b7a7b7b3000076767676769076767676767676767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000455d5d5d5d5d5d5d5d45000000a0a0a0a05858585858a0a0a0a058a0a00000b4a7a7b7a7b7b7b7a7a7a7b3000076760a0b769076761276767676767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000455d5d5d5d5d5d5d5d4500000058a0585858a0a0a0a0a0585858a0a0a00000b4b7a7b7a7b7b7a7a7a7a7b3000076761a1b109076767676313334343434000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000455d5d5d5d5d5d5d5d45000000a05858a0a058585858585858a05858580000b4b7a7a7a7b7b7b7b7a7a7b3000081818181818481818181818181818181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000045454545555545454545000000202120212021202120212021202120210000b4b7b7a7a7b7a7b7b7b7b7b3000033343434349076760a2d0b7676767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000045454545000000000000565656565656565656565622565656560000b5a2a2a2a3b7b7a1a2a2a2b60000767676767690762e1a3d1b7676127676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000605656665656225656565656606060660000000000000000000000000000000076767612769181818181819376767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000606666565656565666605660565656660000000000000000000000000000000076767676767676767676767676767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0514151415141500001415141514150476767676767676767676767676767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000000476767676767676767676767676767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000000000000000000000000000004060606060606066c6c06060606060606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050000000000000000000000000000047a7a7a7a7a7a7a6c6c7a7a7a7a7a7a7a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000000000000000000000000000004a0a0a0a0a0a058585858a0a0a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000000000000000000000000000004a0a0585858a0a05858a058a0a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000000000000000000000000000014a0a05858a0a058a058585858585858a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000000000000000000000000000000585858585858a0a0a0585858a058a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000000000000000000000000000000a0a0a0a058a0a0a0a0a0a0a0a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000000000000000000000000000004a0a0a0a05858585858a0a0a0a058a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000000458a0585858a0a0a0a0a0585858a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000000000000000000000000000004a05858a0a058585858585858a0585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050000000000000000000000000000045858a05858585858b058585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000000421202120212021202120212021202120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000000456566656565656606056565656565660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0504050405040500000405040504050422566066562256565660566060565656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
