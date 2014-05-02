require! {
	EE: \events .EventEmitter
	Buffer: './buffer'
	Cursor: './cursor'
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
			@active-buffer = buffer
		else
			throw new Error("Bad Buffer (Not in list)")

	remove-buffer: (buffer) ~>
		if ~@buffers.index-of(buffer)
			@buffers.splice @buffers.index-of(buffer), 1
			if buffer is @active-buffer and buffer.index > 0
				@active-buffer = @buffers[buffer.index - 1] or @create-buffer!

			@_recalc-last-buffer-index!

	_recalc-last-buffer-index: ~>
		last = -1

		for buffer, i in @buffers
			if buffer
				last = i

		@_last-buffer-index = last + 1

	@Buffer = Buffer
	@Cursor = Cursor


exports = module.exports = Poke