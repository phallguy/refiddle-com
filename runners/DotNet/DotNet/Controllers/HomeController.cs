using System;
using System.Web.Mvc;
namespace Refiddle.Controllers
{
	[HandleError]
	public class HomeController : Controller
	{
		public ActionResult Index()
		{
			return new RedirectResult("http://refiddle.com");
		}
	}
}
