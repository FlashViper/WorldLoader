@tool
extends Control

func display(level: LevelFile) -> void:
	%LevelName.text = level.name if level.name != "" else "Untitled Level"
	%LevelSize.text = "
		%s[color=darkgrey] by [/color]%s[color=darkgrey] tiles
	" % [level.size.x, level.size.y]
	
	if level.size.x > 1 and level.size.y > 1:
		var img := Image.create(
			level.size.x, 
			level.size.y, 
			false, 
			Image.FORMAT_RGB8
		)
		
		if level.tileData.size() > 0:
			var index := 0
			for y in level.size.y:
				for x in level.size.x:
					if level.tileData[index] != 0:
						img.set_pixel(x,y, Color.WHITE)
					index += 1
		
		var tex := ImageTexture.create_from_image(img)
		%Bitmask.texture = tex
	else:
		pass
