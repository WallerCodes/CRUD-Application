using BPCM;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.SessionState;

public class GetLanguages : AjaxHandler
{
    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context)
    {
        List<ObjectLanguage> results = new List<ObjectLanguage>();

        context.Response.ContentType = "text/plain";

        try
        {
            results = DBTools.GetLanguages();

            string json = JsonConvert.SerializeObject(results);

            System.Diagnostics.Debug.WriteLine($"json: {json}");

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