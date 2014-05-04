require! {
	EE: \events .EventEmitter
	Buffer: './buffer'
	Selection: './selection'
}

class Poke extends EE
	~>
		@buffers = []
		@_recalc-last-buffer-index!
		@active-buffer = @create-buffer!

	create-buffer: ~>
		buffer = new Buffer(this, @_last-buffer-index)
		@buffers[buffer.index] = buffer
		@_recalc-last-buffer-index!
		buffer

	switch-buffer: (buffer) ~>
		if ~@buffers.index-of(buffer)
			old-buffer = @active-buffer
			@active-buffer = buffer
			@emit \switch-buffer buffer, old-buffer
		else
			throw new Error("Bad Buffer (Not in list)")

		this

	remove-buffer: (buffer) ~>
		if ~@buffers.index-of(buffer)
			@buffers.splice @buffers.index-of(buffer), 1
			if buffer is @active-buffer and buffer.index > 0
				@switch-buffer @buffers[buffer.index - 1] or @create-buffer!

			@_recalc-last-buffer-index!

	_recalc-last-buffer-index: ~>
		last = -1

		for buffer, i in @buffers
			if buffer
				last = i

		@_last-buffer-index = last + 1

	@Buffer = Buffer
	@Selection = Selection


exports = module.exports = Poke