extends TextureRect

@export var level : LevelFile

func update_texture() -> void:
	if level == null:
		return
	
	if level.size.x < 2 and level.size.y < 2:
		texture = null
		return
	
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
	
	if level.world_settings:
		var tile_size := level.world_settings.tile_size
		
		for r in level.respawn_points:
			var world_pos := level.respawn_points[r] as Vector2
			if Rect2(Vector2(), level.size * level.world_settings.tile_size).has_point(world_pos):
				var tile_pos := (world_pos / tile_size).floor()
				img.set_pixel(tile_pos.x, tile_pos.y, Color.DARK_OLIVE_GREEN)
	
	texture = ImageTexture.create_from_image(img)
