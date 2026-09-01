using BPCM;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.SessionState;

public class UpdateConfigurationOrder : AjaxHandler
{
    protected override bool checkSecurity(DUser user)
    {
        // This might need to be changed to be less restrictive. Should be user.isEdit?
        if (user == null || user.isSuperAdmin == false)
        {
            return false;
        }
        return true;
    }

    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser dUser, HttpContext context)
    {
        ObjectConfiguration result = new ObjectConfiguration();

        string configurationOrderListString = parseSingleParameter<string>(request, "configurationOrderList", true);
        string email = parseSingleParameter<string>(request, "performerUserEmail", true);

        DUser user = DBTools.GetFullUser(email);

        List<ObjectConfigurationOrder> configurationOrderList = configurationOrderListString
            .Split(';')
            .Where(pair => !string.IsNullOrWhiteSpace(pair))
            .Select(pair =>
            {
                var parts = pair.Split(',');
                return new ObjectConfigurationOrder(int.Parse(parts[0]), int.Parse(parts[1]));
            })
            .ToList();

        try
        {
            //throw new Exception("Dummy Exception");
            result = DBTools.UpdateConfigurationOrder(
                configurationOrderList
            );

            //string json = JsonConvert.SerializeObject(result);

            //context.Response.Write(json);
            context.Response.ContentType = "text/plain";
            context.Response.Write("{\"success\":true}");
        }
        catch (Exception e)
        {
            log.Error("Got exception processing request " + request.RawUrl + ": " + e.Message, e);
            context.Response.ContentType = "text/plain";
            //context.Response.Write("Got exception processing request " + request.RawUrl + ": " + e.Message);
            context.Response.Write("{\"error\":\"An error was received processing the request.\"}");
        }

        DBTools.UserAudit(user, user, "", "Update Configuration Order", UserAuditAction.UPDATE_CONFIGURATION_ORDER);

        return context;
    }
}