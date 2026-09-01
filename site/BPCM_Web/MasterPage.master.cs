using Newtonsoft.Json;
using System;
using System.Web.Optimization;

public partial class MasterPage : System.Web.UI.MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Code that runs on application startup
        BundleConfig.RegisterBundles(BundleTable.Bundles);

        if (Session[DUser.USER_SESSION_KEY] == null)
        {
            //Response.Redirect("Bypass.aspx");
        }
        else
        {
            DUser user = JsonConvert.DeserializeObject<DUser>(Session[DUser.USER_SESSION_KEY].ToString());
            //TODO maybe...
        }
    }
}
