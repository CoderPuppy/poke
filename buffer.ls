require! {
	Cursor: "./cursor"
}

class Buffer
	(@poke, @index, @_name, @lines = [""]) ~>
		@cursors = [ Cursor(this, 1, 1) ]

	name: ~> @_name or @lines[0]
	line: (i) ~> @lines[i] or ""

	_parse-pos: (x, y) ~>
		if y is \end
			y = @lines.length - 1

		if y is \home
			y = 0

		if y < 0
			y += @lines.length

		if x is \end
			x = @lines[y].length

		if x is \home
			x = 0

		if x < 0
			x += @lines[y].length

		[ x, y ]

	insert: (x, y, text) ~>
		[x, y]  = @_parse-pos(x, y)

		lines = text.split(/[\n\r]/g)
		text = lines[0]
		line = @lines[y]
		@lines[y] = line.substr(0, x) + text
		if lines.length > 1
			lines[1] += line.substr(x)
		else
			@lines[y] += line.substr(x)

		@lines.splice(y + 1, 0, ...lines.slice(1))

		this

	delete: (x, y, length = 1) ~>
		[x, y] = @_parse-pos(x, y)

		if length is \all
			length = Infinity

		while length > 0
			line = @lines[y]
			# console.log "x: %d, y: %d, length: %d, line: %j, lines: %j", x, y, length, line, @lines

			if length > line.length - x and @lines.length - 1 > y
				length -= line.length - x + 1
				@lines[y] = line.substr(0, x) + @lines[y + 1]
				@lines.splice(y + 1, 1)
			else
				@lines[y] = line.substr(0, x) + line.substr(x + length)
				length = 0

		line = @lines[y]
		@lines[y] = line.substr(0, x) + line.substr(x + length)

		this

	#mode: -> Mode

exports = module.exports = Buffer