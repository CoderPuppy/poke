require! {
	Poke: './index'
	util
}

function i o
	console.log util.inspect o, colors: true, depth: null

poke = new Poke

# i poke
buffer = poke.active-buffer

buffer.insert 0 0 "Hello World!\nfoo\nbar\nbaz"
buffer.commit!

buffer.delete \end 0 \all
buffer.commit!

i buffer.lines

buffer.undo!
i buffer.lines

buffer.redo!
i buffer.lines

# i poke.create-buffer!