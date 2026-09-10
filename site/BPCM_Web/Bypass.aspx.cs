using Newtonsoft.Json;
using System;

public partial class Bypass : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session[DUser.USER_SESSION_KEY] == null)
        {
            System.Diagnostics.Debug.WriteLine("User session was null...");
            Response.Redirect("Login.tsx");
        }
        else
        {
            DUser user = JsonConvert.DeserializeObject<DUser>(Session[DUser.USER_SESSION_KEY].ToString());
        }
    }
}