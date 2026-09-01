using BPCM;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.SessionState;

public class GetUsers : AjaxHandler
{
    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context)
    {
        bool showDeleted = parseSingleParameter<bool>(request, "showDeleted", false);
        string lookupUserName = parseSingleParameter<string>(request, "lookupUserName", false);
        string sortOrder = parseSingleParameter<string>(context.Request, "sort", false);
        string sortDir = parseSingleParameter<string>(context.Request, "sortDir", false);
        List<DUser> results = new List<DUser>();

        string json = "";

        try
        {
            results = DBTools.GetUsers(lookupUserName, showDeleted, sortOrder, sortDir, user.isUsanUser);

            log.Info("User: " + user.userName + " requested GetUsers(lookupUserName: " + lookupUserName + ", showDeleted: " + showDeleted.ToString() + ", isUsanUser: " + user.isUsanUser + ")");

            ObjectDataTableResponse<DUser> dataTableResponse = new ObjectDataTableResponse<DUser>();

            dataTableResponse.success = true;
            dataTableResponse.recordsTotal = results.Count.ToString();
            dataTableResponse.recordsFiltered = results.Count.ToString();
            dataTableResponse.data = results;

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