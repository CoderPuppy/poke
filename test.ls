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
i buffer.lines

buffer.commit!

buffer.delete \end 0 \all
i buffer.lines

buffer.commit!

buffer.undo!
i buffer.lines

# i poke.create-buffer!