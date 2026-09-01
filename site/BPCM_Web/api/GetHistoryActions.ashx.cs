using BPCM;
using Newtonsoft.Json;
using System;
using System.Web;
using System.Web.SessionState;

public class GetHistoryActions : AjaxHandler
{
    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context)
    {
        var results = DBTools.GetHistoryActions();

        string json = JsonConvert.SerializeObject(results);

        context.Response.ContentType = "text/plain";

        //log.Info("User: " + user.login + " requested GetHistoryActions");

        try
        {
            json = json.Replace("[{", "{\"success\":true, \"data\":[{");
            json += "}";
            context.Response.Write(json);
        }
        catch (Exception e)
        {
            log.Error("User: " + user.userName + " requested GetHistoryActions and failed");
            log.Error("Got exception processing request " + request.RawUrl + ": " + e.Message, e);
            context.Response.Write("Got exception processing request " + request.RawUrl + ": " + e.Message);
        }
        return context;
    }
}
