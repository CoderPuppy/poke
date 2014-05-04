require! {
	EE: \events .EventEmitter
	Selection: "./selection"
	OP: "./ops"
}

class TBuffer extends EE
	(@poke, @index) ~>
		@selections = [ Selection(this, 1, 1) ]
		@history = []
		@history-index = -1
		@commits = [@history]
		@commit-index = 0

	line: (i) ~> @lines![i] or ""

	offset-pos: (x, y, ox, oy) ~>
		if typeof oy isnt \number
			offset = ox

			lines = @lines!

			while offset > 0
				if y >= lines.length or y <= 0
					break

				line = lines[y]
				if x >= line.length
					y += 1
				else if x <= 0
					y -= 1
				else if offset < 0
					x -= 1
					offset -= 1
				else
					x += 1
					offset += 1

			[ x, y ]
		else
			[ x + ox, y + oy ]

	_parse-pos: (x, y) ~>
		lines = @lines!

		if y is \end
			y = lines.length - 1

		if y is \home
			y = 0

		if y < 0
			y += lines.length

		if x is \end
			x = lines[y].length

		if x is \home
			x = 0

		if x < 0
			x += lines[y].length

		[ x, y ]

	apply: (op, hist = true) ~>
		@emit \apply, op
		data = op.apply this
		if hist
			@history.push [ op, data ]
			@history-index += 1
		this

	undo: ~>
		if @history.length <= 0 or @history-index < 0
			if @commit-index < 1
				throw new Error("Nothing to undo")

			@commit-index -= 1
			commit = @commits[@commit-index]

			@history = commit
			@history-index = commit.length - 1

			while @history-index > -1
				@undo!
		else
			hist = @history[@history-index]
			hist[0].unapply this, hist[1]
			@history-index -= 1

		this

	_redo: ~>
		if @history-index >= @history.length - 1
			throw new Error("Nothing to redo")

		@history-index += 1
		@apply @history[@history-index][0], false

	redo: ~>
		if @commit-index >= @commits.length - 1
			@_redo!
		else
			if @commit-index >= @commits.length - 1
				throw new Error("Nothing to redo")

			while @history-index < (@history.length - 1)
				@_redo!

			@commit-index += 1
			@history = @commits[@commit-index]
			@history-index = -1

		this

	full-history: ~>
		[op for commit in @commits for op in commit]

	commit: ~>
		@history = []
		@history-index = -1
		@commits.push @history
		@commit-index += 1
		this

	insert: (x, y, text) ~>
		if typeof x is \string and not (y? and text?)
			text = x
			for selection in @selections
				selection.insert text
		else
			@apply OP.insert(x, y, text)

	delete: (x, y, length) ~>
		if typeof x is \string and not (y? and text?)
			text = x
			for selection in @selections
				selection.delete text
		else
			@apply OP.delete(x, y, length)

	#insert-impl: (x, y, lines) ~>
	#delete-impl: (x, y, length) ~> deleted: String

	#mode: -> Mode

exports = module.exports = TBuffer