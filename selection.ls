class Selection
	(@buffer, @x, @y, @length = 0) ~>

	insert: (text) ~>
		if @length > 0
			@delete @length

		@buffer.insert @x, @y, text
		[ @x, @y ] = @buffer.offset-pos @x, @y, text.length

		this

	delete: (length) ~>
		if @length > 0
			@delete @length

		@buffer.delete @x, @y, length
		[ @x, @y ] = @buffer.offset-pos @x, @y, length # TODO: emit \move

		this

exports = module.exports = Selection