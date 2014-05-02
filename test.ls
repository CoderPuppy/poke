require! {
	Poke: './index'
	TermUI: './termui'
	util
}

function i o
	console.log util.inspect o, colors: true, depth: null

poke = new Poke!

# i poke
buffer = poke.active-buffer

buffer.insert 0 0 "Hello World!\nfoo\nbar\nbaz"
buffer.commit!

ui = new TermUI(poke, {
	title:
		foreground: 0
		background: 15
		display: <[]>

	gutter-linenum:
		foreground: 3
		background: 0
		display: <[ bright ]>

	gutter-noline:
		foreground: 4
		background: 0
		display: <[ bright ]>

	text:
		foreground: 15
		background: 0
		display: <[]>
}, process.stdin, process.stdout)

# buffer.delete \end 0 \all
# buffer.commit!

# i buffer.lines

# buffer.undo!
# i buffer.lines

# buffer.redo!
# i buffer.lines

# i poke.create-buffer!