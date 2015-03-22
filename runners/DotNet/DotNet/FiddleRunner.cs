using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace DotNet
{
	public class FiddleRunner
	{
		private static readonly Regex LitreralPattern = new Regex( "^\\/[^\\/]+\\/\\w*", RegexOptions.Multiline );
		private static readonly Regex CorpusTestPattern = new Regex( "^#(\\+|\\-)", RegexOptions.Multiline );

		public static bool IsCorpusTest( string corpus )
		{
			return CorpusTestPattern.IsMatch( corpus );
		}

		public static bool IsLiteralPattern( string pattern )
		{
			return LitreralPattern.IsMatch( pattern );
		}

		public object Match( string pattern, string corpus )
		{
			var parsedPattern = this.ParsePattern( pattern );
			if( parsedPattern == null || corpus == null )
			{
				return null;
			}
			if( IsCorpusTest( corpus ) )
			{
				return this.MatchCorpusTests( parsedPattern, corpus );
			}
			return this.MatchWholeCorpus( parsedPattern, corpus );
		}

		public object Replace( string pattern, string corpus, string replace )
		{
			var dictionary = new Dictionary<string, string> {
			                                                	{
			                                                		"replace",
			                                                		corpus
			                                                		}
			                                                };
			var parsedPattern = this.ParsePattern( pattern );
			if( parsedPattern == null || corpus == null || replace == null )
			{
				return dictionary;
			}
			if( IsCorpusTest( corpus ) )
			{
				var stringBuilder = new StringBuilder( corpus.Length );
				var array = corpus.Split( new[] { '\n' } );

				for( var i = 0; i < array.Length; i++ )
				{
					var input = array[ i ];
					stringBuilder.AppendLine( parsedPattern.Pattern.Replace( input, replace,
					                                                         ( ( parsedPattern.Options & SudoRegexOptions.Global ) ==
					                                                           SudoRegexOptions.None )
					                                                         	? 1
					                                                         	: 2147483647 ) );
					dictionary[ "replace" ] = stringBuilder.ToString();
				}
			}
			else
			{
				var value = parsedPattern.Pattern.Replace( corpus, replace,
				                                           ( ( parsedPattern.Options & SudoRegexOptions.Global ) ==
				                                             SudoRegexOptions.None )
				                                           	? 1
				                                           	: 2147483647 );
				dictionary[ "replace" ] = value;
			}
			return dictionary;
		}

		private Dictionary<string, object> MatchWholeCorpus( ParsedPattern parsedPattern, string corpus )
		{
			var dictionary = new Dictionary<string, object>();
			var matchCollection = parsedPattern.Pattern.Matches( corpus );
			if( ( parsedPattern.Options & SudoRegexOptions.Global ) == SudoRegexOptions.None )
			{
				if( matchCollection.Count >= 1 )
				{
					dictionary[ "0" ] = this.HashMatch( matchCollection[ 0 ] );
				}
			}
			else
			{
				foreach( Match match in parsedPattern.Pattern.Matches( corpus ) )
				{
					dictionary[ match.Index.ToString() ] = this.HashMatch( match );
				}
			}
			dictionary[ "matchSummary" ] = new {
			                                   	total = dictionary.Count
			                                   };
			return dictionary;
		}

		private Dictionary<string, object> MatchCorpusTests( ParsedPattern parsedPattern, string corpus )
		{
			var summary = new Dictionary<string, object> {
			                                             	{ "total", 0 },
			                                             	{ "tests", true },
			                                             	{ "passed", 0 },
			                                             	{ "failed", 0 }
			                                             };
			var results = new Dictionary<string, object> {
			                                             	{ "matchSummary", summary }
			                                             };

			Action<string, int, bool> addMatch = delegate( string line, int offset, bool passed ) {
			                                     	summary[ "total" ] = (int) summary[ "total" ] + 1;
			                                     	var key = passed ? "passed" : "failed";
			                                     	summary[ key ] = (int) summary[ key ] + 1;
			                                     	results[ offset.ToString() ] = new object[] {
			                                     	                                            	offset,
			                                     	                                            	line.Length,
			                                     	                                            	passed ? "match" : "nomatch"
			                                     	                                            };
			                                     };
			Action<string, int> nothingMatcher = delegate { };
			Action<string, int> positiveMatcher =
				delegate( string line, int offset ) { addMatch( line, offset, parsedPattern.Pattern.IsMatch( line ) ); };
			Action<string, int> negativeMatcher =
				delegate( string line, int offset ) { addMatch( line, offset, !parsedPattern.Pattern.IsMatch( line ) ); };
			Func<string, Action<string, int>> func = delegate( string line ) {
			                                         	if( line.Length <= 1 )
			                                         	{
			                                         		return nothingMatcher;
			                                         	}
			                                         	if( line[ 1 ] == '+' )
			                                         	{
			                                         		return positiveMatcher;
			                                         	}
			                                         	if( line[ 1 ] == '-' )
			                                         	{
			                                         		return negativeMatcher;
			                                         	}
			                                         	return nothingMatcher;
			                                         };
			var action = nothingMatcher;
			var num = 0;
			var array = corpus.Split( new[] {
			                                	'\n'
			                                } );
			for( var i = 0; i < array.Length; i++ )
			{
				var text = array[ i ];
				if( text.Length > 1 && text[ 0 ] == '#' )
				{
					action = func( text );
				}
				else if( text.Length > 0 )
				{
					action( text, num );
				}
				num += text.Length + 1;
			}
			return results;
		}

		private object HashMatch( Match match )
		{
			return new[] {
			             	match.Index,
			             	match.Length
			             };
		}

		private ParsedPattern ParsePattern( string pattern )
		{
			var regexOptions = RegexOptions.None;
			var sudoRegexOptions = SudoRegexOptions.None;
			if( pattern == null )
			{
				return null;
			}
			if( !IsLiteralPattern( pattern ) )
			{
				return new ParsedPattern {
				                         	Pattern = new Regex( pattern, regexOptions ),
				                         	Options = sudoRegexOptions
				                         };
			}
			sudoRegexOptions |= SudoRegexOptions.Literal;
			var num = pattern.LastIndexOf( "/" );
			var text = pattern.Substring( num + 1 );
			pattern = pattern.Substring( 1, num - 1 );
			var text2 = text;
			var i = 0;
			while( i < text2.Length )
			{
				var c = text2[ i ];
				var c2 = c;
				if( c2 <= 'i' )
				{
					switch( c2 )
					{
						case 'a':
							regexOptions |= RegexOptions.ECMAScript;
							break;
						case 'b':
							goto IL_115;
						case 'c':
							sudoRegexOptions |= SudoRegexOptions.Compiled;
							break;
						default:
							switch( c2 )
							{
								case 'g':
									sudoRegexOptions |= SudoRegexOptions.Global;
									break;
								case 'h':
									goto IL_115;
								case 'i':
									regexOptions |= RegexOptions.IgnoreCase;
									break;
								default:
									goto IL_115;
							}
							break;
					}
				}
				else
				{
					switch( c2 )
					{
						case 'm':
							regexOptions |= RegexOptions.Multiline;
							break;
						case 'n':
							regexOptions |= RegexOptions.ExplicitCapture;
							break;
						default:
							switch( c2 )
							{
								case 's':
									regexOptions |= RegexOptions.Singleline;
									break;
								case 't':
									goto IL_115;
								case 'u':
									regexOptions |= RegexOptions.CultureInvariant;
									break;
								default:
									if( c2 != 'x' )
									{
										goto IL_115;
									}
									regexOptions |= RegexOptions.IgnorePatternWhitespace;
									break;
							}
							break;
					}
				}
				i++;
				continue;
				IL_115:
				return null;
			}
			return new ParsedPattern {
			                         	Pattern = new Regex( pattern, regexOptions ),
			                         	Options = sudoRegexOptions
			                         };
		}
	}
}