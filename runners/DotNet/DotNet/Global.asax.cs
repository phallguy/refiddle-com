using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;

namespace DotNet
{
	public class Global : HttpApplication
	{
		public static void RegisterRoutes(RouteCollection routes)
		{
			routes.IgnoreRoute("{resource}.axd/{*pathInfo}");
			routes.MapRoute("runner", "regex/{action}/{flavor}/{format}", new
			                                                              {
			                                                              	controller = "Regex",
			                                                              	action = "Evaluate",
			                                                              	flavor = ".net",
			                                                              	format = "html"
			                                                              });
			routes.MapRoute("Default", "{id}", new
			                                   {
			                                   	controller = "Home",
			                                   	action = "Index",
			                                   	id = UrlParameter.Optional
			                                   });
		}

		protected void Application_Start()
		{
			AreaRegistration.RegisterAllAreas();
			RegisterRoutes(RouteTable.Routes);
		}
	}
}