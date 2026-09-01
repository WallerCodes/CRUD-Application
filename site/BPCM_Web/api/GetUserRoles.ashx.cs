using BPCM;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.SessionState;

public class GetUserRoles : AjaxHandler
{
    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context)
    {
        int userId = parseSingleParameter<int>(request, "userId", false);
        string allowedAppsStr = parseSingleParameter<string>(request, "allowedApps", false);
        List<string> allowedApps = allowedAppsStr?.Split(',').ToList();

        List<ObjectUserRoles> results = new List<ObjectUserRoles>();

        List<ObjectUserRoles> allowedResults = new List<ObjectUserRoles>();

        string json = "";

        try
        {
            results = DBTools.GetUserRoles(userId);

            // super admin can update any app
            if (user.isSuperAdmin)
            {
                allowedResults = results;
            }
            else
            {
                foreach (ObjectUserRoles role in results)
                {
                    foreach (string app in allowedApps)
                    {
                        if (role.application == app)
                        {
                            allowedResults.Add(role);
                        }
                    }
                }
            }


            ObjectDataTableResponse<ObjectUserRoles> dataTableResponse = new ObjectDataTableResponse<ObjectUserRoles>();

            dataTableResponse.success = true;
            dataTableResponse.recordsTotal = allowedResults.Count.ToString();
            dataTableResponse.recordsFiltered = allowedResults.Count.ToString();
            dataTableResponse.data = allowedResults;

            json = JsonConvert.SerializeObject(dataTableResponse);

            context.Response.ContentType = "text/plain";

            context.Response.Write(json);
        }
        catch (Exception e)
        {
            log.Error("Got exception processing request " + request.RawUrl + ": " + e.Message, e);
            context.Response.Write("Got exception processing request " + request.RawUrl + ": " + e.Message);
        }
        return context;
    }
}