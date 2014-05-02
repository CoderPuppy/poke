require! {
	OP: "./"
}

class DeleteOP
	(@x, @y, @length = 1) ~>
		if @length is \all
			@length = Infinity

	apply: (buffer) ~>
		[x, y] = buffer._parse-pos(@x, @y)

		length = @length
		deleted = ""

		while length > 0
			line = buffer.lines[y]

			if length > line.length - x and buffer.lines.length - 1 > y
				length -= line.length - x + 1
				deleted += line.substr(x) + "\n"
				buffer.lines[y] = line.substr(0, x) + buffer.lines[y + 1]
				buffer.lines.splice(y + 1, 1)
			else
				deleted += line.substr(x, x + length)
				buffer.lines[y] = line.substr(0, x) + line.substr(x + length)
				length = 0

		line = buffer.lines[y]
		buffer.lines[y] = line.substr(0, x) + line.substr(x + length)

		[ x, y, deleted ]

	unapply: (buffer, [ x, y, deleted ]) ~>
		OP.insert(x, y, deleted).apply(buffer)

exports = module.exports = DeleteOP