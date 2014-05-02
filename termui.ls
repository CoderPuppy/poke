require! {
	charms: charm
}

class TermUI
	(@poke, @readable, @writable) ~>
		@charm = charms(@readable, @writable)
		@charm.reset!
		@charm.position 1, 1
		@width = 100
		@height = 30

		@text-x = 2
		@text-y = 2

		@redraw!

		@charm.position @text-x + @poke.cursor-x, @text-y + @poke.cursor-y

		@poke.on \cursor, (x, y) ~>
			@charm.position @text-x + x, @text-y + y

	redraw: ~>
		title = "[=====[#{@poke.constructor.name}]=====]"
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

exports = module.exports = TermUI