using BPCM;
using Newtonsoft.Json;
using System;
using System.Web;
using System.Web.SessionState;

public class GetUsersTable : AjaxHandler
{
    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context)
    {
        int requestedStart = parseSingleParameter<int>(request, "start", false);
        int requestedLimit = parseSingleParameter<int>(request, "length", false);
        bool showDeleted = parseSingleParameter<bool>(request, "showDeleted", false);
        string lookupUserName = parseSingleParameter<string>(request, "lookupUserName", false);

        string sortOrder = parseSingleParameter<string>(context.Request, "sort", false);
        string sortDir = parseSingleParameter<string>(context.Request, "sortDir", false);

        ObjectSearchResult<DUser> results = new ObjectSearchResult<DUser>();

        if (requestedLimit <= 0)
        {
            requestedLimit = 10;
        }

        if (requestedStart <= 0)
        {
            //default
            requestedStart = 0;
        }

        string json = "";

        try
        {
            results = DBTools.GetUsersTable(requestedStart, requestedLimit, lookupUserName, showDeleted, sortOrder, sortDir, user.isUsanUser);

            log.Info("User: " + user.userName + " requested GetUsers(lookupUserName: " + lookupUserName + ", showDeleted: " + showDeleted.ToString() + ", isUsanUser: " + user.isUsanUser + ")");

            ObjectDataTableResponse<DUser> dataTableResponse = new ObjectDataTableResponse<DUser>();

            dataTableResponse.success = true;
            dataTableResponse.recordsTotal = results.total.ToString();
            dataTableResponse.recordsFiltered = results.total.ToString();
            dataTableResponse.data = results.rows;

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