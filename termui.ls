require! {
	charms: charm
	keypress
	ansirecover: 'ansi-recover'
}

twil = class Twil
	(@def) ~>
		@charm = charms(process.stdin, process.stdout)
		@charm.reset!
		@update!
		process.stdout.on \resize, ~>
			@update!
			@redraw!
		ansirecover { -cursor, +mouse }

	cursor: (cb) ~> @charm.position cb

	redraw: (x, y) ~>
		if x? and y?
			@charm.position x, y
			@charm.write ' '

			for obj in @objs when x >= obj._x and y >= obj._y and x <= obj._x + obj.width and y <= obj._y + obj.height
				obj.redraw!

		else
			@charm.erase \screen
			for obj in @objs
				obj.redraw false

	update: ~>
		@objs = []

		@def.call null, (x, y, text) ~>
			@objs.push new Twil.Obj(this, x, y, text)

		for obj in @objs
			obj.update!

		this

	class @Obj
		(@ui, @x, @y, @text) ~>

		redraw: (clear = true) ~>
			if @_old-x isnt @_x or @_old-y isnt @_y or @_old-width isnt @width or @_old-height isnt @height or @_old-text isnt @_text
				if clear and (@_old-width? and @_old-height? and @_old-x? and @_old-y?)
					for y from @_old-y to (@_old-y + @_old-height)
						@ui.charm.position @_old-x y
						@ui.charm.write " " * @_old-width

				@ui.charm.position @_x, @_y
				@ui.charm.write @_text

		update: ~>
			@_old-x = @_x
			@_old-y = @_y
			@_old-width = @width
			@_old-height = @height
			@_old-text = @_text

			if typeof @x == \function
				@_x = @x!
			else
				@_x = @x

			if typeof @y == \function
				@_y = @y!
			else
				@_y = @y

			if typeof @text == \function
				@_text = @text!
			else
				@_text = @text.to-string!

			@width = @_text.length
			@height = @_text.split(/[\n\r]/g).length

			this

class TermUI
	(@poke, @styles) ~>
		rs = process.stdin
		ws = process.stdout

		@ui = twil (def) ~>
			def 1 1 ~> " -- #{@poke.active-buffer.name!}"
			def 1 2 ~> @poke.active-buffer.lines.map((line, i) -> "  #i #line").join('\n')

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

			if key and key.ctrl and key.name is \c
				rs.pause!

			cx, cy <~ @ui.cursor!
			@ui.redraw cx - 1, cy

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