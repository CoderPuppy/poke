require! {
	TBuffer: "./tbuffer"
}

class Buffer extends TBuffer
	(poke, index, @_name, @_lines = [""]) ~>
		super(poke, index)

	name: ~> @_name or @_lines[0]
	lines: ~> @_lines

	insert-impl: (x, y, lines) ~>
		text = lines[0]
		line = @line(y)
		@_lines[y] = line.substr(0, x) + text

		if lines.length > 1
			lines[1] += line.substr(x)
		else
			@_lines[y] += line.substr(x)

		@_lines.splice(y + 1, 0, ...lines.slice(1))

	delete-impl: (x, y, length) ~>
		deleted = ""

		while length > 0
			line = @line(y)

			if length > line.length - x and @_lines.length - 1 > y
				length -= line.length - x + 1
				deleted += line.substr(x) + "\n"
				@_lines[y] = line.substr(0, x) + buffer.lines[y + 1]
				@_lines.splice(y + 1, 1)
			else
				deleted += line.substr(x, x + length)
				@_lines[y] = line.substr(0, x) + line.substr(x + length)
				length = 0

		line = @_lines[y]
		@_lines[y] = line.substr(0, x) + line.substr(x + length)

		deleted

exports = module.exports = Buffer