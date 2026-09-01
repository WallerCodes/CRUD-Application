using BPCM;
using System.Web;
using System.Web.SessionState;

public class RestoreUser : AjaxHandler
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
            log.Info("User: " + user.userName + " failed trying to restore userId " + requestedUserID);
            context.Response.ContentType = "text/plain";
            context.Response.Write("{\"error\":\"Cannot update or delete your user\"}");
            return false;
        }
        DUser u = new DUser();
        u.id = requestedUserID;
        u.isDeleted = false;

        DUser temp = DBTools.GetFullUserById(requestedUserID);

        DBTools.UpdateUser(u, UserUpdateType.DELETED);

        //DBTools.UserAudit(user, u, "1", "0", UserAuditAction.RESTORE_USER);

        log.Info("User: " + user.userName + " has restored User: " + temp.userName);

        context.Response.ContentType = "text/plain";
        context.Response.Write("{\"success\":true}");

        return true;
    }
}