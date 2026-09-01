using BPCM;
using System.Web;
using System.Web.SessionState;

public class Logout : AjaxHandler
{
    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context)
    {
        session[DUser.USER_SESSION_KEY] = null;

        log.Info("User: " + user.userName + " logged out");
        session.Clear();
        return true;
    }
}