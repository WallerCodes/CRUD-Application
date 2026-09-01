using BPCM;
using Newtonsoft.Json;
using System;
using System.Web;
using System.Web.SessionState;

public class RemoveConfiguration : AjaxHandler
{
    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser dUser, HttpContext context)
    {
        ObjectConfiguration result = new ObjectConfiguration();

        string configurationId = parseSingleParameter<string>(request, "configurationId", true);
        string email = parseSingleParameter<string>(context.Request, "performerUserEmail", false);

        string json = "";

        DUser user = DBTools.GetFullUser(email);

        try
        {
            ObjectDataTableResponse<ObjectBypassRecord> dataTableResponse = new ObjectDataTableResponse<ObjectBypassRecord>();

            result = DBTools.RemoveConfiguration(configurationId);

            dataTableResponse.success = true;

            json = JsonConvert.SerializeObject(dataTableResponse);

            context.Response.ContentType = "text/plain";

            context.Response.Write(json);
        }
        catch (Exception e)
        {
            log.Error("Got exception processing request " + request.RawUrl + ": " + e.Message, e);
            context.Response.Write("Got exception processing request " + request.RawUrl + ": " + e.Message);
        }

        DBTools.UserAudit(user, user, "", "Delete Configuration", UserAuditAction.DELETE_CONFIGURATION);

        return context;
    }
}