using BPCM;
using System;
using System.Web;
using System.Web.SessionState;

public class ChangeUserAuth : AjaxHandler
{
    protected override bool checkSecurity(DUser user)
    {
        if (user == null || user.isSuperAdmin == false)
        {
            return false;
        }
        return true;
    }

    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context)
    {
        string affectedUser = parseSingleParameter<string>(request, "affectedUser", true);
        string tempSuperAdmin = parseSingleParameter<string>(request, "isSuperAdmin", false);
        string tempIsUsanUser = parseSingleParameter<string>(request, "isUsanUser", false);

        if (affectedUser == user.userName)
        {
            //IsSuccess = false;
            context.Response.ContentType = "text/plain";
            context.Response.Write("{\"error\":\"Cannot update or delete your user\"}");
            return false;
        }

        if (affectedUser != null && affectedUser.Length > 0)
        {
            var testUser = DBTools.GetFullUser(affectedUser);
            if (String.IsNullOrEmpty(testUser.userName))
            {
                log.Info("User Name: " + affectedUser + " was not found");
                //IsSuccess = false;
                context.Response.ContentType = "text/plain";
                context.Response.Write("{\"error\":\"User Name not found\"}");
                return false;
            }
            else
            {
                if (!string.IsNullOrEmpty(tempSuperAdmin))
                {
                    testUser.isSuperAdmin = tempSuperAdmin == "true" ? true : false;

                    string tempInverseAuth = testUser.isSuperAdmin == false ? "true" : "false";
                    string tempAuth = testUser.isSuperAdmin == false ? "false" : "true";

                    DBTools.UpdateUser(testUser, UserUpdateType.ADMIN);

                    DBTools.UserAudit(user, testUser, "Super Admin " + tempInverseAuth, "Super Admin " + tempAuth, UserAuditAction.UPDATE_USER);


                    log.Info("User: " + user.userName + " updated isSuperAdmin of User: " + testUser.userName + " from " + tempInverseAuth + " to " + tempAuth);
                }

                if (!string.IsNullOrEmpty(tempIsUsanUser))
                {
                    testUser.isUsanUser = tempIsUsanUser == "true" ? true : false;

                    string tempInverseAuth = testUser.isUsanUser == false ? "true" : "false";
                    string tempAuth = testUser.isUsanUser == false ? "false" : "true";

                    DBTools.UpdateUser(testUser, UserUpdateType.USAN_USER);

                    DBTools.UserAudit(user, testUser, "Usan User " + tempInverseAuth, "Usan User " + tempAuth, UserAuditAction.UPDATE_USER);


                    log.Info("User: " + user.userName + " updated isUsanUser of User: " + testUser.userName + " from " + tempInverseAuth + " to " + tempAuth);
                }




                string json = "{\"success\":true}";
                context.Response.Write(json);
                return true;
            }

        }
        else
        {
            //IsSuccess = false;
            log.Info("User Name: " + user.userName + " failed trying to update isSuperAdmin for user: " + affectedUser + ", isSuperAdmin: " + tempSuperAdmin);
            context.Response.ContentType = "text/plain";
            context.Response.Write("{\"error\":\"Missing user name or Super Admin flag\"}");
            return false;
        }
    }
}