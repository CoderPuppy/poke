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
		if length < 0
			[x, y] = buffer.offset-pos(x, y, length)
			length = -length
		[ x, y, buffer.delete-impl x, y, @length ]

	unapply: (buffer, [ x, y, deleted ]) ~>
		buffer.insert-impl x, y, deleted.split("\n")

exports = module.exports = DeleteOP