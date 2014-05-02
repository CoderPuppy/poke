require! {
	TBuffer: "./tbuffer"
}

class Buffer extends TBuffer
	(poke, index, @_name, @lines = [""]) ~>
		super(poke, index)

	name: ~> @_name or @lines[0]

	insert-impl: (x, y, lines) ~>
		text = lines[0]
		line = @lines[y]
		@lines[y] = line.substr(0, x) + text

		if lines.length > 1
			lines[1] += line.substr(x)
		else
			@lines[y] += line.substr(x)

		@lines.splice(y + 1, 0, ...lines.slice(1))

	delete-impl: (x, y, length) ~>
		deleted = ""

		while length > 0
			line = @lines[y]

			if length > line.length - x and @lines.length - 1 > y
				length -= line.length - x + 1
				deleted += line.substr(x) + "\n"
				@lines[y] = line.substr(0, x) + buffer.lines[y + 1]
				@lines.splice(y + 1, 1)
			else
				deleted += line.substr(x, x + length)
				@lines[y] = line.substr(0, x) + line.substr(x + length)
				length = 0

		line = @lines[y]
		@lines[y] = line.substr(0, x) + line.substr(x + length)

		deleted

exports = module.exports = Buffer