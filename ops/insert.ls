require! {
	OP: "./"
}

class InsertOP
	(@x, @y, @lines) ~>
		if typeof @lines is \string
			@lines .= split(/[\n\r]/g)

	apply: (buffer) ~>
		[x, y] = buffer._parse-pos(@x, @y)

		lines = @lines ++ []

		text = lines[0]
		line = buffer.lines[y]
		buffer.lines[y] = line.substr(0, x) + text

		if lines.length > 1
			lines[1] += line.substr(x)
		else
			buffer.lines[y] += line.substr(x)

		buffer.lines.splice(y + 1, 0, ...@lines.slice(1))

		[ x, y ]

	unapply: (buffer, [x, y]) ~>
		OP.delete(x, y, @lines.join("\n").length).apply(buffer)

exports = module.exports = InsertOP