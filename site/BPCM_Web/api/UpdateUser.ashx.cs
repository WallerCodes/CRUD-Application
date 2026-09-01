using BPCM;
using BPCM_Web.Global;
using System.Web;
using System.Web.SessionState;

public class UpdateUser : AjaxHandler
{

    override public object ProcessRequest(HttpSessionState session, HttpRequest request, DUser duser, HttpContext context)
    {
        string userName = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(context.Request, "userName", false));
        string oldPassword = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(context.Request, "oldPassword", false));
        string newPassword = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(context.Request, "newPassword", false));
        bool success = false;

        DUser performingUser = DBTools.GetFullUser(userName);

        if (performingUser.password == oldPassword)
        {
            if (performingUser.password != newPassword)
            {
                performingUser.password = newPassword;
                DBTools.UpdateUser(performingUser, UserUpdateType.PASSWORD);
                DBTools.UserAudit(performingUser, performingUser, oldPassword, newPassword, UserAuditAction.CHANGE_PASSWORD);
                success = true;
            }
            else
            {
                log.Info("User change password failed: " + userName);
                context.Response.ContentType = "text/plain";
                context.Response.Write("{\"error\":\"New password cannot be the same as old password.\"}");
                return context;
            }
        }
        else
        {
            log.Info("User change password failed: " + userName);
            context.Response.ContentType = "text/plain";
            context.Response.Write("{\"error\":\"Old password was incorrect.\"}");
            return context;
        }

            context.Response.ContentType = "text/plain";

        if (success == true)
        {
            log.Info("User change password success: " + userName);
            context.Response.Write("{\"success\":true}");
        }
        else
        {
            log.Info("User change password failed: " + userName);
            context.Response.Write("{\"success\":false}");
        }

        return context;
    }
}
