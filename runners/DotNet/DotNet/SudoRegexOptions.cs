using System;

namespace DotNet
{
	[Flags]
	public enum SudoRegexOptions
	{
		None = 0,
		Literal = 1,
		Global = 2,
		Compiled = 4
	}
}
