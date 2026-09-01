using BPCM;
using Newtonsoft.Json;
using System;
using System.Web;
using System.Web.SessionState;

public class GetHistoryResults : AjaxHandler
{
    protected override bool checkSecurity(DUser user)
    {
        if (user == null || !user.isSuperAdmin)
        {
            return false;
        }
        return true;
    }

    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context)
    {
        string requestedActionID = parseSingleParameter<string>(request, "actionName", false);
        string requestedAffectedUserID = parseSingleParameter<string>(request, "affectedUserName", false);
        string requestedPerformerUserID = parseSingleParameter<string>(request, "performerUserName", false);
        int requestedStart = parseSingleParameter<int>(request, "start", false);
        int requestedLimit = parseSingleParameter<int>(request, "length", false);
        string sortOrder = parseSingleParameter<string>(context.Request, "sort", false);
        string sortDir = parseSingleParameter<string>(context.Request, "sortDir", false);

        string userLoginPeformer = parseSingleParameter<string>(request, "userLoginPeformer", false);
        string userLoginAffected = parseSingleParameter<string>(request, "userLoginAffected", false);
        ObjectSearchResult<ObjectHistory> results = new ObjectSearchResult<ObjectHistory>();

        if (requestedLimit <= 0)
        {
            requestedLimit = 10;
        }

        if (requestedStart <= 0)
        {
            //default
            requestedStart = 0;
        }

        string startDate = parseSingleParameter<string>(request, "startDate", false);
        string endDate = parseSingleParameter<string>(request, "endDate", false);
        DateTime requestedStartDate;
        DateTime requestedEndDate;

        if (startDate != null && startDate != " ")
        {
            requestedStartDate = DateTime.Parse(startDate);
        }
        else
        {
            requestedStartDate = System.Data.SqlTypes.SqlDateTime.MinValue.Value;
        }

        if (endDate != null && endDate != " ")
        {
            requestedEndDate = DateTime.Parse(endDate);
        }
        else
        {
            requestedEndDate = System.Data.SqlTypes.SqlDateTime.MaxValue.Value;
        }

        string json = "";

        try
        {
            results = DBTools.GetHistoryResults(requestedStart, requestedLimit, sortOrder, sortDir, requestedPerformerUserID, requestedAffectedUserID, requestedActionID, requestedStartDate, requestedEndDate, user.isUsanUser);

            log.Info("User: " + user.userName + " requested GetHistoryResults(performerUserId: " + requestedPerformerUserID + ", affectedUserId: " + requestedAffectedUserID + ", actionId: " + requestedActionID + ", startDate: " + requestedStartDate + ", endDate: " + requestedEndDate + ", isUsanUser: " + user.isUsanUser.ToString() + ")");

            ObjectDataTableResponse<ObjectHistory> dataTableResponse = new ObjectDataTableResponse<ObjectHistory>();

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