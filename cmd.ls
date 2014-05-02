require! {
	Poke: './index'
	TermUI: './termui'
}

poke = new Poke!
poke.active-buffer.insert 0 0 "Hello World!"
ui = new TermUI poke, process.stdin, process.stdout