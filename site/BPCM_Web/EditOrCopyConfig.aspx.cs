using Newtonsoft.Json;
using System;

public partial class EditOrCopyConfig : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session[DUser.USER_SESSION_KEY] == null)
        {
            Response.Redirect("Login.tsx");
        }
        else
        {
            DUser user = JsonConvert.DeserializeObject<DUser>(Session[DUser.USER_SESSION_KEY].ToString());

            user.userRoles = DBTools.GetUserRoles(user.id);

            bool canEditApps = false;

            foreach (var app in user.userRoles)
            {
                if (app.accessLevelEdit == true)
                {
                    // edit access for at least 1 app so cut short
                    canEditApps = true;
                    break;
                }
            }

            if (canEditApps == false)
            {
                //Response.Redirect("Login.tsx"); // Take care of permissions later
            }
        }
    }
}