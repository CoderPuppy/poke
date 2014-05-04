require! {
	charms: charm
	keypress
	ansirecover: 'ansi-recover'
}

tuil = class TUIL
	(@def) ~>
		ansirecover { -cursor, +mouse }
		@charm = charms(process.stdin, process.stdout)
		@charm.reset!
		@width = process.stdout.columns
		@height = process.stdout.rows
		@update true
		@redraw!
		process.stdout.on \resize ~>
			@width = process.stdout.columns
			@height = process.stdout.rows
			@update true
			@redraw!

	cursor: (cb) ~> @charm.position cb

	redraw: (x = true, y) ~>
		if typeof x is \number and typeof y is \number
			@charm.position x, y
			@charm.write ' '

			for obj in @objs when x >= obj._x and y >= obj._y and x <= obj._x + obj.width and y <= obj._y + obj.height
				obj.redraw!

		else
			clear = x
			if clear
				@charm.erase \screen
			for obj in @objs
				obj.redraw clear, not clear

		this

	update: (redef = false) ~>
		if redef
			@objs = []
			@def.call null, (x, y, text) ~>
				obj = new TUIL.Obj(this, x, y, text)
				@objs.push obj
				obj
		else
			for obj in @objs
				obj.update!

		this

	class @Obj
		(@ui, @x, @y, @text) ~>
			@_old-lines = []
			@update!

		redraw: (force = false, clear = true) ~>
			if force or (@_old-x isnt @_x or @_old-y isnt @_y or @_old-width isnt @width or @_old-height isnt @height or @_old-text isnt @_text)
				if clear and (@_old-x? and @_old-y?)
					for line, i in @_old-lines when line isnt @_lines[i] or @_old-x isnt @_x or @_old-y isnt @_y
						@ui.charm.position @_old-x, @_old-y + i
						@ui.charm.write " " * (Math.min line.length, @ui.width - @_x)

				for line, i in @_lines when line isnt @_old-lines[i] or force or @_old-x isnt @_x or @_old-y isnt @_y
					@ui.charm.position @_x, @_y + i
					@ui.charm.write line.substr(0, @ui.width - @_x)

				@_old-x = @_x
				@_old-y = @_y
				@_old-width = @width
				@_old-height = @height
				@_old-lines = @_lines.slice(0)
				@_old-text = @_text

			this

		update: ~>
			if typeof @x is \function
				@_x = @x!
			else
				@_x = @x

			if typeof @y is \function
				@_y = @y!
			else
				@_y = @y

			if typeof @text is \function
				@_text = @text!
			else
				@_text = @text.to-string!

			if typeof! @_text is \Array
				@_lines = @_text
				@_text = @_lines.join('\n')
			else
				@_lines = @_text.split /[\n\r]/g

			@width = Math.max ...@_lines.map (.length)
			@height = @_lines.length

			this

class TermUI
	(@poke, @styles) ~>
		rs = process.stdin
		ws = process.stdout

		@ui = tuil (def) ~>
			@title-ui = def 1 1 ~> " -- #{@poke.active-buffer.name!}"
			@text-ui = def 1 2 ~> @poke.active-buffer.lines!.map((line, i) -> "  #i #line")

		buffer-apply-handler = ~>
			@ui.update!
			@ui.redraw false

		@poke.on \switch-buffer (new-buffer, old-buffer) ~>
			old-buffer.off \apply buffer-apply-handler
			new-buffer.on \apply buffer-apply-handler

		@poke.active-buffer.on \apply buffer-apply-handler

		@width = ws.columns
		@height = ws.rows

		@text-x = 1
		@text-y = 1

		@scroll-v = 0
		@scroll-h = 0

		keypress rs
		keypress.enable-mouse ws
		rs.set-raw-mode on
		rs.resume!

		rs.on \keypress (ch, key) ~>
			# console.log "key: ", key

			if key?
				switch
				case key.ctrl and key.name is \c
					rs.pause!
					process.exit!
				case ch?
					try
						@poke.active-buffer.insert ch
					catch e
						# TODO: handle this better
						throw e

			cx, cy <~ @ui.cursor!
			@ui.redraw cx - 1, cy

		rs.on \mousepress (mouse) ~>
			@ui.redraw!

		rs.on \end ~>
			keypress.disable-mouse ws

		@ui.redraw!
		# @redraw!

		# @charm.position @text-x + @poke.cursor-x, @text-y + @poke.cursor-y

		# @poke.on \cursor, (x, y) ~>
		# 	@charm.position @text-x + x, @text-y + y

	_set-style: (style) ~>
		@charm.display \reset
		@charm.foreground style.foreground if style.foreground?
		@charm.background style.background if style.background?
		for disp in style.display
			@charm.display disp

	redraw: ~>
		@charm.reset!

		buffer = @poke.active-buffer

		# do
		# 	@charm.position 1 1
		# 	@_set-style @styles.title

		# 	title = " -- #{buffer.name!}"
		# 	@charm.write title
		# 	@charm.write " " * (@width - title.length)

		gutter = [ (line + 1).to-string! for line from @scroll-v to (@height - @text-y - 1 + @scroll-v) ]
		gutter-width = Math.max(...gutter.map (.length)) + 2

		for i from @scroll-v to (@height - @text-y - 1 + @scroll-v)
			@charm.position @text-x, i + @text-y

			if buffer.lines[i]?
				@_set-style @styles.gutter-linenum
				@charm.write " " * (gutter-width - gutter[i].length - 1)
				@charm.write gutter[i] + " "
			else
				@_set-style @styles.gutter-noline
				@charm.write "~"
				@charm.write " " * (gutter-width - 1)

			@_set-style @styles.text
			@charm.write buffer.line(i).substr(@scroll-h)

exports = module.exports = TermUI