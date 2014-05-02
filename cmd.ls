require! {
	Poke: './index'
	TermUI: './termui'
}

poke = new Poke!
ui = new TermUI poke, process.stdin, process.stdout