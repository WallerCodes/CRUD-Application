using BPCM;
using System.Web;
using System.Web.SessionState;

public class DeleteUser : AjaxHandler
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
        int requestedUserID = parseSingleParameter<int>(request, "userId", true);

        if (requestedUserID == user.id)
        {
            //IsSuccess = false;
            log.Info("User: " + user.userName + " attempted to delete their own user");
            context.Response.ContentType = "text/plain";
            context.Response.Write("{\"error\":\"Cannot update or delete your user\"}");
            return false;
        }

        if (!user.isSuperAdmin)
        {
            //IsSuccess = false;
            log.Info("User: " + user.userName + " attempted to delete a user but not super admin");
            context.Response.ContentType = "text/plain";
            context.Response.Write("{\"error\":\"You do not have permissions to delete users\"}");
            return false;
        }

        // mark deleted
        DUser u = new DUser();
        u.id = requestedUserID;
        u.isDeleted = true;

        DUser temp = DBTools.GetFullUserById(requestedUserID);

        DBTools.UpdateUser(u, UserUpdateType.DELETED);

        log.Info("User: " + user.userName + " deleted User: " + temp.userName);

        u = DBTools.GetFullUserById(requestedUserID);

        DBTools.UserAudit(user, u, "0", "1", UserAuditAction.DELETE_USER);

        context.Response.ContentType = "text/plain";
        context.Response.Write("{\"success\":true}");

        return true;
    }
}