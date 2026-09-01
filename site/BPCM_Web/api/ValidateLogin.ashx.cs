using BPCM;
using Newtonsoft.Json;
using System;
using System.Web;
using System.Web.SessionState;

public class ValidateLogin : AjaxHandler
{
    override public object ProcessRequest(HttpSessionState session, HttpRequest request, DUser duser, HttpContext context)
    {
        string email = parseSingleParameter<string>(context.Request, "performerUserEmail", false);
        string password = parseSingleParameter<string>(context.Request, "password", false);

        bool success = false;
        string json = "[]";

        DUser user = DBTools.GetFullUser(email);


        if (user.id < 1)
        {
            log.Info("User login failed, email does not exist: " + email);
            context.Response.Write("{\"success\":false,\"error\":\"Email or Password is incorrect! Please try again.\"}");
            return user;
        }

        if (user.isDeleted == true)
        {
            DBTools.UserAudit(user, user, "", "Failed Login - Deleted User", UserAuditAction.FAILED_LOGIN);

            log.Info("User login failed, user deleted: " + email);
            context.Response.Write("{\"success\":false,\"error\":\"User is deleted. Please contact your supervisor.\"}");
            return user;
        }

        if (user.isLocked == true)
        {
            DBTools.UserAudit(user, user, "", "Failed Login - Locked User", UserAuditAction.FAILED_LOGIN);

            log.Info("User login failed, user is locked out: " + email);
            context.Response.Write("{\"success\":false,\"error\":\"User is locked. Please contact your supervisor.\"}");
            return user;
        }

        if (user.password == password)
        {
            success = true;
            string prevLogin = user.lastLogin.ToString();
            user.lastLogin = DateTime.Parse("1/1/1753 12:00:00 AM"); // Indicates to the DB SP to get the current date 


            session[DUser.USER_SESSION_KEY] = JsonConvert.SerializeObject(user);
            //session.Timeout = int.Parse(WebConfigurationManager.AppSettings["SessionTimeout"]);

            DBTools.UpdateUser(user, UserUpdateType.LAST_LOGIN);

            DBTools.UserAudit(user, user, prevLogin, user.lastLogin.ToString(), UserAuditAction.LOGIN);
        }
        else
        {
            DBTools.UserAudit(user, user, "", "Failed Login", UserAuditAction.FAILED_LOGIN);
        }

        context.Response.ContentType = "text/plain";
        user.success = success;

        // clear out the pw hash from the user obj being sent in response
        user.password = null;

        json = JsonConvert.SerializeObject(user);


        if (success == true)
        {
            log.Info("User login success: " + email);
        }
        else
        {
            log.Info("User login failed: " + email);
        }

        context.Response.Write(json);

        return user;
    }
}
