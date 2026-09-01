using BPCM;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.SessionState;

public class GetApplications : AjaxHandler
{
    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context)
    {
        string allowedAppsStr = parseSingleParameter<string>(request, "allowedApps", true); // Allowed apps here should be from the view list
        List<string> allowedApps = allowedAppsStr?.Split(',').ToList();
        List<ObjectApplication> results = new List<ObjectApplication>();

        context.Response.ContentType = "text/plain";

        try
        {
            results = DBTools.GetApplications(allowedAppsStr, false);

            string json = JsonConvert.SerializeObject(results);

            context.Response.Write(json);
        }
        catch (Exception e)
        {
            log.Error("Got exception processing request " + request.RawUrl + ": " + e.Message, e);
            context.Response.Write("Got exception processing request " + request.RawUrl + ": " + e.Message);
        }

        return context;
    }
}