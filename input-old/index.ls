/*

*/

class InputManager
	~>
		@mode-stack = [] # List[List[Symbol]]
		@_rules = []

	import: (rules) ~>
		remaining = [[[], rules]]

		for frame in remaining
			for rule in frame[1]
				if typeof! rule.selector is "Array"
					selector = frame[0].concat(rule.selector)

					if selector.length == 1 and selector[0][0] isnt "!"
						(@_modeRules[selector[0]] or= []).push rule

					@_rules.push rule

					if typeof! rule.subrules is "Array"
						remaining.push [ selector, rule.subrules ]

	rules: ~> @_rules
	mode: ~> @mode-stack[@mode-stack.length - 1]

exports = module.exports = InputManager