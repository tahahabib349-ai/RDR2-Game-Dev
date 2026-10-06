class_name TerrainView
extends TileMapLayer
## Generated placeholder diamonds, not final art. Walkability lives in MapModel.

func build(map: MapModel, projection: IsoProjection) -> void:
	z_index = -1
	var tiles := TileSet.new()
	tiles.tile_size = map.config.tile_size
	tiles.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tiles.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	var atlas := TileSetAtlasSource.new()
	atlas.texture_region_size = map.config.tile_size
	var image := Image.create(map.config.tile_size.x * 3, map.config.tile_size.y, false, Image.FORMAT_RGBA8)
	var colors := [Color(0.31, 0.34, 0.35), Color(0.18, 0.21, 0.24), Color(0.42, 0.4, 0.31)]
	for variant in range(3):
		for y in range(map.config.tile_size.y):
			for x in range(map.config.tile_size.x):
				var distance := absf((x + 0.5) / map.config.tile_size.x * 2 - 1) + absf((y + 0.5) / map.config.tile_size.y * 2 - 1)
				if distance <= 1:
					image.set_pixel(x + variant * map.config.tile_size.x, y, colors[variant] * (0.8 if distance > 0.92 else 1.0))
	atlas.texture = ImageTexture.create_from_image(image)
	for variant in range(3):
		atlas.create_tile(Vector2i(variant, 0))
	tiles.add_source(atlas, 0)
	tile_set = tiles
	# TileMap cell origin is centered; logical cells cover [x,x+1] × [y,y+1].
	position = projection.to_iso(Vector2(0.5, 0.5)) - map_to_local(Vector2i.ZERO)
	for y in range(map.config.size.y):
		for x in range(map.config.size.x):
			var cell := Vector2i(x, y)
			var variant := 1 if not map.passable(cell) else (2 if map.is_ore(cell) else 0)
			set_cell(cell, 0, Vector2i(variant, 0))
