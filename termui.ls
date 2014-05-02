require! {
	charms: charm
}

class TermUI
	(@poke, @readable, @writable) ~>
		@charm = charms(@readable, @writable)
		@charm.reset!
		@charm.position 1 1
		@width = 100
		@height = 30

		@text-x = 2
		@text-y = 2

		@redraw!

		# @charm.position @text-x + @poke.cursor-x, @text-y + @poke.cursor-y

		# @poke.on \cursor, (x, y) ~>
		# 	@charm.position @text-x + x, @text-y + y

	redraw: ~>
		@charm.position 1 1

		buffer = @poke.active-buffer

		title = "[=====[#{buffer.name!}]=====]"
		@charm.write "+#{"-" * ((@width - 2 - title.length) / 2)}#title#{"-" * ((@width - 2 - title.length) / 2)}+\n"
		@charm.write "|\n" * (@height - 4)

		command-area = " " * (@width - (6 + 5 * 2))
		@charm.write "+" + ("-" * ((@width - 2 - command-area.length - 4) / 2)) + "[["
		@charm.display \underscore
		@charm.write command-area
		@charm.display \reset
		@charm.write "]]" + ("-" * ((@width - 2 - command-area.length - 4) / 2)) + "+\n"
		
		for i from 2 to (@height - 3)
			@charm.position @width, i
			@charm.write "|"

		for i from 0 to (@height - @text-y - 1)
			@charm.position 2, i + @text-y
			@charm.write buffer.line(i)

exports = module.exports = TermUI