require! {
	OP: "./"
}

class InsertOP
	(@x, @y, @lines) ~>
		if typeof @lines is \string
			@lines .= split(/[\n\r]/g)

	apply: (buffer) ~>
		[x, y] = buffer._parse-pos(@x, @y)
		buffer.insert-impl x, y, @lines.concat([])
		[ x, y ]

	unapply: (buffer, [x, y]) ~>
		buffer.apply OP.delete(x, y, @lines.join("\n").length), false

exports = module.exports = InsertOP