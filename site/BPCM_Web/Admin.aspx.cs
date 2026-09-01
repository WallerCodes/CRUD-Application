using Newtonsoft.Json;
using System;

public partial class Admin : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session[DUser.USER_SESSION_KEY] == null)
        {
            Response.Redirect("Login.aspx");
        }
        else
        {
            DUser user = JsonConvert.DeserializeObject<DUser>(Session[DUser.USER_SESSION_KEY].ToString());

            user.userRoles = DBTools.GetUserRoles(user.id);

            bool appAdmin = false;

            foreach (var app in user.userRoles)
            {
                if (app.accessLevelAdmin == true)
                {
                    // admin for at least 1 app so cut short
                    appAdmin = true;
                    break;
                }
            }

            if (user.isSuperAdmin == false && appAdmin == false)
            {
                Response.Redirect("Login.aspx");
            }
        }
    }
}