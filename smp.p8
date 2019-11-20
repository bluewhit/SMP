pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- initialize
-- whitney 

t = true
f = false 

rx = 15 
ry = 15

rooms = {}
rm = {

	max_goal = 4,
	max_exit = 2,

} 

elems = {} 

types = {"forest","town","beach", "mountain", "cave", "home"}
	 
function _init()
	spawn()
	gen_room() 
	
	show = f
	diag = ""
	d_tick = 0
	input = f 
	
	plr = {
		pnme = "",
		x=8,
		y=8,
		
		moving = f,
		
		inven = {},
		sp = {64,65,66,67,80,81,82}
	} 
 
 box = {
		sp=112,
		x=8,
		y=16,
		w=8,
		h=8
	}
	
end
	

 

-->8
-- gen

function spawn() 
	
	rm.type = types[flr(rnd(6))+1]
	
	rm.type = "forest" 
	
	--if statement to allow what elements
	--can be in each room
	--forest 
	if rm.type == "forest" then 
		
		--potential items to be spawned
		rm.pot_elms = {1,2,3,16,
		17,18,36,50,51,52}
		
		--goals and exits 
		rm.pot_goals = {53,54,55,35,19}
		rm.pot_exits = {12} 
		
		--how many slopes 
		rm.max_slope = 2 
	
	--beach 
	elseif rm.type == "beach" then
		
		rm.pot_elms = {16,13,14,17,28,36,
		39,40,73}
		
		rm.pot_goals = {15,19,48,54,63,94,
		37}
		rm.pot_exits = {12,9}
		 
		rm.max_slope = 1 
	end 

end

-- generate the room
-- tiles, exits, and goals 
function gen_room()
	
	--tiles for the room
	rm.tiles = {} 
	
	--build the goals and exits 
	rm.num_goals = flr(rnd(rm.max_goal)+1)
	rm.goals = {} --store the goals
	
	rm.num_exits = flr(rnd(rm.max_exits)+1)
	rm.exits = {}
	
	--how many placed so far 
	cgoal = 1
	cexit = 1 
	
	-- length of potential elements
	e_length = #rm.pot_elms 
	
	
	--gets our specifics goals 
	-- and exits for room 	
	for i=0, rm.num_goals do 
		goal = rm.pot_goals[flr(rnd(#rm.pot_goals)+1)]	 
		add(rm.goals, goal)
		
		ex = rm.pot_exits[flr(rnd(#rm.pot_exits)+1)]
		add(rm.exits, ex)
	end 
	
	--places tiles randomly 	  
	for i = 1, rx-1 do 
		for j = 1, ry-1 do  
			--pick a random element
			rand_elm = rm.pot_elms[flr(rnd(e_length)+1)]
			temp = {}
			
			temp.x = i
			temp.y = j
			temp.s = 0  
			
			if i == 1 and j == 1 then
				temp.x = i 
				temp.y = j
				temp.s = 131
				 
				mset(i,j,temp.s)
			
			elseif rnd(10)+1 > 8 then
				temp.x = i
				temp.y = j
				temp.s = rand_elm
				temp.need_path = f
				 
				mset(i,j,temp.s)
				
			--add our goals
			elseif rnd(10)+1 < 4 and cgoal < rm.max_goal and i > 2 and j > 3  then 
					temp.x = i 
					temp.y = j 
					temp.s = rm.goals[cgoal]
					temp.need_path = t 
					cgoal += 1
				
				mset(i,j,temp.s) 
				
			elseif rnd(10)+1 < 4 and cexit < rm.max_exit and i > 3 and j > 4 then
				temp.x = i
				temp.y = j
				temp.s = rm.exits[cexit]
				temp.need_path = f 
				cexit += 1
				
				mset(i,j,temp.s) 
		end 
		
		add(rm.tiles, temp)
		
		end 
	end  
	
	lim = #rm.goals + #rm.exits
	
--	findpaths(rm.px,rm.py,lim)	
	
end

function findpaths(x,y,lim,ac,at)  
	
	-- basically i want to get from the players
	-- spawn to the exit and goals. this will
	-- make a path that i can then carve out from tiles
	
	--paths is a table that stores a path table
	--each path will lead from the spawn to the extis, and goals 
 
	local targets = {} -- list od coordinates {x}{y} as result of this function
	local visited = {}

	local stack = {}
	local read = 0
	local write = 0
	write=write + 1  stack[write] = {x,y} -- push
	visited[x..","..y] = true
	local dir={{x=-1,y=0},{x=1,y=0},{x=0,y=-1},{x=0,y=1} }
	
	while write > read do 
	
		read = read + 1 
		local coord = stack[read]
		
		local vx = coord[1]
		local vy = coord[2]
		
		--position match
		if accept_target(vx,vy) then 
			add(targets,{x=vx, y=vy })
			if #targets==limit then
				return targets
			end
		end

		-- go visit neighboars
		for d in all(dir) do

			-- child position
			local cx = (vx+d.x)%48 -- map wrap
			local cy = (vy+d.y)%48
			if not visited[cx..","..cy] then
				visited[cx..","..cy]=true
				if accept_child(cx,cy) then
					write=write + 1  stack[write] = { cx, cy } -- push
				end
			end
		end
	end

	return targets
end
	 	
-->8
-- collision
map_tile=0
flag_tile=0
 


function getitem(item)
		
		d = "picked up a"
		
		if item == 35 then 
			d = d.."n" 
			o = {n="apple",sp=35}
		elseif item == 19 then 
			o = {n="potion",sp=19}
		elseif item == 31 then
			o = {n="gem",sp=31}
		elseif item == 53 then 
			o ={n="mushroom",sp=53}
		elseif item == 54 then 
			o ={n="nugget",sp = 54}
		else
			o ={n="unknown item",0} 
		end 
		
		show = t
		d = d.." "..o.n.."."
		
		if #plr.inven < 8 then 
		
			add(inven, o)
		
			for i in all(rm.tiles) do 
				if i.x == grid_x and i.y == grid_y then
					del(rm.tiles,i)
				end 
			end 
			mset(grid_x,grid_y, 0)
		
		else
			d = d.."\n... but i can't pick it up."
		end  		
end 


-->8
-- dialoge 

show = f 
function trigger()
	
	if fget(map_tile,1) then 
		getitem(map_tile)
	elseif fget(map_tile) then
		print("trigger")
	end  
	 
end

function draw_dia()
	
	if show == t then 
		draw_box() 
		print(sub(d,1,flr(d_tick+6/3)),8,107)
		d_tick+=1
		if d_tick > 90 and input == false then
			show = false
			d = ""
			d_tick = 0
		end
	end 
	 
end 

function draw_box()
	
	for i=8, 112,8 do
	 for j=112, 128,8 do 
			spr(139,i,104)
			spr(83,i,j)
		end 
	end
	
	--corner
	spr(138,0,104)
	spr(138,120,104,1,1,t,f)
	
	--side, left
	spr(154,0,112,1,1)
	spr(154,0,120,1,1)
	
	--side, right 
	spr(154, 120,112,1,1,t)
	spr(154, 120,120,1,1,t)

end 

-->8
-- update & draw

function _update()
	move_plr()
	 
	grid_x = flr(box.x/8)
	grid_y = flr(box.y/8)
	
	map_tile = mget(grid_x,grid_y)
	
	if btn(5) then 
		trigger()
	end 
	
	if btn(4) then 
		menu()
	end 
	
end  


-- spr( n, x, y, [w,] [h,] [flip_x,] [flip_y] )

 
function _draw()
	cls(3)
	
	
	for i in all(rm.tiles) do
		
		if fget(i.s, 7) then 
			palt(0, f)
			palt(3, t)
			spr(i.s,i.x*8,i.y*8)
		else 
			palt(0,t)
			spr(i.s,i.x*8,i.y*8)
		end
		
	end 
	
	palt(0,f)
	
	draw_bar()
	draw_dia()
	
	palt(0,f)
	palt(3, t)
	
	
	
	--plr
	spr(64,plr.x,plr.y)
	spr(box.sp, box.x, box.y)
	
	print(map_tile,6,13,7)
	print("player"..flr(plr.x/8)..","..flr(plr.y/8),5,20)
	print(grid_x..","..grid_y,5,5,7)
end
-->8
-- player functions 

function move_plr()
	
	if (btn(0)) then
			plr.x -= 1
			plr.move = "l"
			plr.moving = t
			aim("l") 
	end
	
	if (btn(1)) then 
		plr.x +=  1
		plr.move = "r"
		plr.moving = t
		aim("r")
	end 
	
	if (btn(2)) then 
		plr.y -= 1
		plr.move = "u"
		plr.moving = t
		aim("u")
	end 
	
	if (btn(3)) then 
		plr.y += 1
		plr.move = "d"
		plr.moving = t
		aim("d")
	end 
	 
end

function aim(b)
	if b == "l" then
		box.x = flr(plr.x)-8
		box.y = plr.y
	elseif b == "r" then
		box.x = plr.x+7
		box.y = plr.y
	elseif b == "u" then
		box.x = plr.x
		box.y = plr.y-7
	elseif b == "d" then
		box.x = plr.x
		box.y = plr.y+8
	end
end

function draw_bar()
	
	for i = 4, 12 do 
		spr(113,i*8,120)
	end 
	
end 
__gfx__
0000000000000000000b000000000000000000bbbbbb1000bbbbbbbb000000000000b00b42000024000000000000000033333333000001110011100000000000
000000000000000000bb0b0000000bb0000bbbbbbbbb3100111111120b0b1bbbbb0000b140000004002222222222220033900933011115651155511100666610
000000000000000000bbbbb00bb88bbb00bbbbbbbbbbb310221222240001411111bbbb1420000002028888888888882030955903155565555556555566000055
0000000000bb0b000bbbb8b000b82b110bbbbbbbbbb3b33142224424011444444411114420000002888888888888888805999950165666665656666506666651
000000000bbbbbb00b8bbbb00bbbbbb0bbbbbbbbbbbb3331442444440b1444424444444440000004888888888888888800400400156665666666666606666651
000000000bb11bb00bbb8b10b111bbb0bbbbbbbbbbb3b331444442440b1442444424444440000004882ee222222ee28800000000155666666666665606666551
000000000b1000b001bbbb10100011b01b13bbbbb3b33331424444240b1444444444444440000004ee111111111111ee30000003015566566565666601665510
00000000000000000000000000000000013133bbbb33131044424424b14444444444424420000002111111111111111133333333015666666666666600111100
333333330666000000009000334443330011113b3131311044444444b14444444444444400000000116122215166651100000000344444430400004000000000
33333333066660660009a900330203330001111111111100444444440b144444444444240000000016122222115651610000000044003344044774400f00f000
3343344301111011000090003303033300000111111000001424424400b144424424444400156000151222226615166100666500400b2204047777400fe0f0f0
44424333000000000000000030373033000000242200000042124424b0b144444444444400615000111222225651611106766650444b4444048888400ee0eee0
2444442360066006000000900878820300000024420000001121121100b144444442444400665000161222291511516156666665400000040888888000feefef
1122444410666600090009a90888220300000214242000002212212200b142444444444400516000151222225115161156666665480010340888888000fefee0
33111422006661009a900090308220330000211122122000131311310b144444424442440011100011122222561165110566665048991234088888800eefee00
333334116601106009000000330003330000000020000000333333330b1444444444444400000000111111111111111100000000444444440880088000000000
00000000000022222220002200000000333333330000000000044000300333333003333300000000000000000077077022222222000000000000000000000000
00000777002442444422224400010000333663330000000009444490042033330420333300000000b0000000c77c777742224242222222220009000000033000
770077cc0242777662444426028122003066666304244240044aa44004200000042033330000000bb000000077c7c7c742422242888888880088800000bbb300
c7777ccc0247777c7777777728e8881006666110244444422000000204204444042033330000000bbb0000000cccc7c04442422288888888000200000bbbb330
cc77cccc24276cccc77ccc7c28888810666666119aaaaaa9400000040420222204203333000000bbbbb000000cccc7c042424244888888880b0b0b0000003330
ccccccc72777cccccccccccc02888100166611112449944224499442042000000420333300000bbbbbb000000c7cccc0424442242222222200bbb00000033330
77cc77cc447ccccccccccccc0021100001111110224224222242242204203333042033330000bbbbbbbb00000c7cccc02442442411111111000b000000333300
cc7ccccc276ccccccccccccc0000000030000003022222200222222032233333322333330001bbb3b333b0000cccc7c022424242111111110000000000000000
000000e000000000000000000000000000bbbb000088820000000000000009000009000001113b33bb311b000cccccc000000000656665660066600000999900
00000ef00b0b0bb00800000000bbbbb00bbbbbb008e888200000000000a0900000000090000113313b1100000ccc7cc000000000115651650666660009000090
000eeef00bbb0b00888000000bbbbbbbbbbbbbbb88888882000a9000000909000000900000013311131110000ccc7cc00444444016151651062f260009000090
0eefffe0013bb310098b00000bbbbbbbbbbbbbbb2882282200aaa9000089a9800089a9000011111111111100077cccc0044444401651611600fff0009a9009a9
e22effe0122222218080b0000bbbbbbbbbbbbbbb0222222000aa99000089a9800089a980011110211210111077cc7c70002992001511566100ccc00009a99a90
e222ef00144442210000b0000bbbbbb11bbbbbb1000fe00000099000044448000444480000100024242000000777c77700222200611516160c9c9c000a9aa9a0
ee22ee00014422100bb0b00001bbbb1111bbbb1100ffe00000000000422024444220244400002244141200007777777000200200561165150c777c0000a99a00
0eeee00000142100000b0000001111100111111000fe000000000000000002400000024000000021002000000000700700000000155155510c666c0000000000
33383833333838333338383333383833333333373333333333360333b000000b0000000b000bbbbb00bbbb333333333333333333cc666ccc0080000000080000
338888833388888333888883338888833333337773333333337660331bbbbbb10000000b0000bbbbbbbb33303333333333333333cc666ccc0009800000898000
3380f0833380f0833388888333888883333337777633333333726033411111210000000b0000b3333b3300003333377733333333cc666ccc0089800000898000
338fff83338fff833388888333888883333337776663333337422203424444210000000b00bb33bb334000003333777737777733cc666ccc0088800000888000
3388888333f888833388888333888883333377746660333334446223244242410000000b0bb3bbbb344400003377777777777733cc666ccc0024200000242000
33fd8df3338d8d833388888333888883333377744666333334442220444444420000000bbbbbb00bb34240003377777777777603cc666ccc0024200000242000
33811183338111f33388888333888883333377744666033344422220442444220000000bbbb0000bb30440003777777666776666cc666ccc0002000000020000
3331313333313333333d3d33333d3333333777474226033344422222444442110000000b0000000bb30424003677776666666666cc666ccc0000000000000000
333383333333833333338333000000003337474742622333cccccccc44444421000000000000000bb30244003366776666666660111111110000000000000000
333888333338883333388833000000003334444442262033cccccccc44444442000000000000000bb30442003366666666666603111111110000000000000000
333888333338883333388833000000003347444442222203cccccccc444444420000000000000000300222003306666666666633111111110004440000000000
333888333338883333388833000000003374444442222203cccccccc142442410000000000000000302444003336666600666033111111110040442000000000
3338d8333388d8333388d833000000003444444422222223cccccccc421244210000000000000000004222003333000333000333111111110044442000c00000
3338f333338fd333338df333000000003444444422222220cccccccc1121121100000000000000000244442033333333333333331111111100444220aac56666
338813333831133338311333000000004444444222222222cccccccc221221210000000000000000442244203333333333333333111111110002220000c00000
333113333331313333131333000000004444444222222222cccccccc131311300000000000000000024220003333333333333333111111110000000000000000
cccccccc00000000000000000000000000099900000000b200000000bbb2247cccccccc44422bbbb247ccccc247ccccc166666610b14444441b0000000000000
cccccccc0009900009000aa000880880009aaa90000000b20000000022224244ccccccc4244422222427cccc247c7ccc1dddddd10b14244441b0000000000000
c7cccccc0099aaa00990aaa00800800809aa0aa9000000b200000000244444222cc2c444244444440247cccc227ccccc1666666100b14444241b000000000000
ccccc7cc049aaaa0049aaa000800000809aa0aa9000000b2000000004244444242242242442444420246cccc2477cccc1dddddd1b0b14444441b000000000000
cccccccc044aaaa0044aaa000080008009aaa0a9000000b200000000444444444444424444444444027ccccc042777cc1666666100b14244441b000000000000
ccc7cccc0044aa000044a00000080800009aaa90000000b200000000444424444444424444424444027ccccc024427761dddddd100b14444421b000000000000
cccccc7c00044000000440000000800000099900000000b200000000444442444242444444222444247ccccc00224747166666610b14444241b0b00000000000
cccccccc00000000000000000000000000000000000000b200000000444444444444444444444444247ccccc000022421dddddd10b12444441b0000000000000
113333111111111100000000000000000000000000000000000000004444444444444444444444440000000000000000000000000b14444411b0000000000000
1333333110000001000000000000000000000000000000000000000044444444444444444444444400000000000000000000000000b11111bb00000000000000
33333333100000010000000000000000000000000000000000000000142442441424424414244244000000000000000000000000000bbbbb0000000000000000
33333333100000010000000000000000000000000000000000000000421244244212442442124424000000000000000000000000000000000000000000000000
33333333100000010000000000000000000000000000000000000000112112111121121111211211000000000000000000000000000000000000000000000000
33333333100000010000000000000000000000000000000000000000221221222212212222122122000000000000000000000000000000000000000000000000
13333331100000010000000000000000000000000000000000000000131211211212112112221131000000000000000000000000000000000000000000000000
11333311111111110000000000000000000000000000000000000000332117777777777777774233000000000000000000000000000000000000000000000000
b0b1bbb0bb0000b111bbb10b01b0b10b000000000000000000000000024777cc777ccccccc777423373333333333333300000000000000000000000000000000
0014111111bbbb14441111000001010000000000000000000000000024777cccccccc7cccccc7742707777777777777700000000000000000000000000000000
11444444441111444444441b4144441b0000000000000000000000002477cccccccccccccccc7742370000000000000000000000000000000000000000000000
b14444244444444444444441044444410000000000000000000000002277ccccccccccccccccc742370000000000000000000000000000000000000000000000
b1442444442444444442441b14424410000000000000000000000000247cccc7ccccccccccccc742370000000000000000000000000000000000000000000000
b1444441444444444444441b144444100000000000000000000000002277ccccccccc7cccccc7742370000000000000000000000000000000000000000000000
1444441b114441111144241b1140241b000000000000000000000000247ccccccccccccccccc7742370000000000000000000000000000000000000000000000
144444100b111b0b0b14441000000104000000000000000000000000247cccccccccccccccccc742370000000000000000000000000000000000000000000000
1444441b014441b001444441000000000000000000000000000000002777cccc00000000ccccc742370000000000000000000000000000000000000000000000
b144441bb1424411b14444410000000000000000000000000000000022277ccc00000000ccccc742370000000000000000000000000000000000000000000000
0b144420b14444441444441b000000000000000000000000000000000247cccc00000000ccccc772370000000000000000000000000000000000000000000000
0b144441b14424444442441b000000000000000000000000000000000247cccc00000000cccc7720370000000000000000000000000000000000000000000000
0b144441144444444244441b000000000000000000000000000000000247cccc00000000cccc7420370000000000000000000000000000000000000000000000
0b14244bb1444444444444110000000000000000000000000000000022477ccc00000000cccc7420370000000000000000000000000000000000000000000000
b144441b00111144111141000000000000000000000000000000000024277ccc00000000ccc77242370000000000000000000000000000000000000000000000
b1444410b01bbb110bbb1b0b000000000000000000000000000000002467cccc00000000cccc7642370000000000000000000000000000000000000000000000
__gff__
0000010001010100000001018001010081000083010101000001010100010103010101038100008181010101000100010300010101030301010101010101010300000000000000010001010000000000000000000000000100000100000000000000000000000001010101010000000000010000000000010101000000000000
0000000000000001010100000000000000000000000000010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000040500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000141500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
