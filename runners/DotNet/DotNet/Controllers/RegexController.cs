using System;
using System.Web.Mvc;
using DotNet;

namespace Refiddle.Controllers
{
	public class RegexController : Controller
	{
		[HttpPost]
		[ValidateInput(false)]
		public object Evaluate( string pattern, string corpus_text )
		{
			var fiddleRunner = new FiddleRunner();
			object result;
			try
			{
				var data = fiddleRunner.Match( pattern, corpus_text );
				result = base.Json( data, JsonRequestBehavior.AllowGet );
			}
			catch( Exception ex )
			{
				result = base.Json( new {
				                        	error = ex.Message
				                        }, JsonRequestBehavior.AllowGet );
			}
			return result;
		}

		[HttpPost]
		[ValidateInput(false)]
		public object Replace( string pattern, string corpus_text, string replace_text )
		{
			var fiddleRunner = new FiddleRunner();
			object result;
			try
			{
				var data = fiddleRunner.Replace( pattern, corpus_text, replace_text );
				result = base.Json( data, JsonRequestBehavior.AllowGet );
			}
			catch( Exception ex )
			{
				result = base.Json( new {
				                        	error = ex.Message
				                        }, JsonRequestBehavior.AllowGet );
			}
			return result;
		}
	}
}