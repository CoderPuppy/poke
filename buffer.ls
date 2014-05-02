require! {
	Cursor: "./cursor"
	OP: "./ops"
}

class Buffer
	(@poke, @index, @_name, @lines = [""]) ~>
		@cursors = [ Cursor(this, 1, 1) ]
		@history = []
		@history-index = -1
		@commits = [@history]
		@commit-index = 0

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

	apply: (op) ~>
		@history.push [ op, op.apply this ]
		@history-index += 1
		this

	undo: ~>
		if @history.length <= 0 or @history-index < 0
			@uncommit!
			
			while @history-index > -1
				@undo!
		else
			hist = @history[@history-index]
			hist[0].unapply this, hist[1]
			@history-index -= 1

		this

	full-history: ~>
		@history ++ [op for commit in @commits for op in commit]

	commit: ~>
		@history = []
		@history-index = -1
		@commits.push @history
		@commit-index += 1
		this

	uncommit: ~>
		while @history-index > -1
			@undo!

		if @commit-index < 1
			throw new Error("No commit to uncommit")

		@commit-index -= 1
		commit = @commits[@commit-index]

		@history = commit
		@history-index = commit.length - 1

		this

	insert: (x, y, text) ~>
		@apply OP.insert(x, y, text)

	delete: (x, y, length) ~>
		@apply OP.delete(x, y, length)

	#mode: -> Mode

exports = module.exports = Buffer