--!strict

export type Comparable =
	number
	| typeof(setmetatable(
		{} :: { [any]: any },
		{} :: {
			__eq: (Comparable, Comparable) -> boolean,
			__lt: (Comparable, Comparable) -> boolean,
			__le: (Comparable, Comparable) -> boolean,
			[any]: any,
		}
	))

return {}
