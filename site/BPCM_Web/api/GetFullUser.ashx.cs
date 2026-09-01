using BPCM;
using Newtonsoft.Json;
using System;
using System.Web;
using System.Web.SessionState;

public class GetFullUser : AjaxHandler
{
    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context)
    {
        string lookupUserName = parseSingleParameter<string>(request, "lookupUserName", false);
        DUser lookupUser = new DUser();

        string json = "";

        try
        {
            lookupUser = DBTools.GetFullUser(lookupUserName);

            json = JsonConvert.SerializeObject(lookupUser);

            context.Response.ContentType = "text/plain";

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