
using BPCM;
using System;
using System.Web;
using System.Web.SessionState;

public class ChangePassword : AjaxHandler
{
    protected override bool checkSecurity(DUser user)
    {
        if (user == null)
        {
            return false;
        }
        return true;
    }

    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context)
    {
        string userName = parseSingleParameter<string>(request, "userName", true);
        string newPassword = parseSingleParameter<string>(request, "password", true);

        if (userName != null && newPassword != null && userName.Length > 0 && newPassword.Length > 0)
        {
            if (userName == user.userName)
            {
                log.Info("User: " + user.userName + " attempted to reset their own password.");
                context.Response.ContentType = "text/plain";
                context.Response.Write("{\"error\":\"Cannot update or delete your user\"}");
                return false;

            }
            else if (user.isSuperAdmin == false)
            {
                log.Info("User: " + user.userName + " is not authorized for admin page.");
                context.Response.ContentType = "text/plain";
                context.Response.Write("{\"error\":\"Admin authorization required\"}");
                return false;
            }

            var testUser = DBTools.GetFullUser(userName);
            if (String.IsNullOrEmpty(testUser.userName))
            {
                log.Info("User: " + testUser.userName + "is not found for ChangePassword.");
                context.Response.ContentType = "text/plain";
                context.Response.Write("{\"error\":\"userName not found\"}");
                return false;
            }
            else
            {
                DUser auser = DBTools.GetFullUserById(testUser.id);

                string oldPassword = auser.password;
                auser.password = newPassword;

                DBTools.UpdateUser(auser, UserUpdateType.PASSWORD);

                DBTools.UserAudit(user, auser, oldPassword, newPassword, UserAuditAction.RESET_PASSWORD);

                log.Info("User: " + user.userName + " reset password for User: " + auser.userName);


                context.Response.ContentType = "text/plain";
                context.Response.Write("{\"success\":true}");

                return true;
            }
        }
        else
        {
            //IsSuccess = false;
            log.Info("User: " + user.userName + " attempted to reset a password but info is missing...userName: " + userName + ", New Password: " + newPassword);
            context.Response.ContentType = "text/plain";
            context.Response.Write("{\"error\":\"Missing User Name or Password\"}");
            return false;
        }
    }
}