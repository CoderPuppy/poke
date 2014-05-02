require! {
	charms: charm
	keypress
}

class TermUI
	(@poke, @styles, @readable, @writable) ~>
		@charm = charms(@readable, @writable)
		@charm.reset!
		@charm.position 1 1

		@width = @writable.columns
		@height = @writable.rows

		@text-x = 1
		@text-y = 1

		@scroll-v = 0
		@scroll-h = 0

		@redraw!

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