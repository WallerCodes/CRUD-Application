using BPCM;
using Microsoft.Ajax.Utilities;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices.ComTypes;
using System.Web;
using System.Web.SessionState;

public class GetConfigurations : AjaxHandler
{
    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context)
    {
        List<ObjectBypassRecord> results = new List<ObjectBypassRecord>();

        string userName = parseSingleParameter<string>(request, "userName", true);
        string application = parseSingleParameter<string>(request, "application", true);
        string language = parseSingleParameter<string>(request, "language", true);
        string dnis = parseSingleParameter<string>(request, "dnis", true);
        string destinationPhoneNumber = parseSingleParameter<string>(request, "destinationPhoneNumber", true);
        string peg = parseSingleParameter<string>(request, "peg", true);
        string rank = parseSingleParameter<string>(request, "rank", true);
        string offerId = parseSingleParameter<string>(request, "offerId", true);
        string offerType = parseSingleParameter<string>(request, "offerType", true);
        string lastModifiedBy = parseSingleParameter<string>(request, "lastModifiedBy", true);
        string lastModifiedDate = parseSingleParameter<string>(request, "lastModifiedDate", true);

        //user.userRoles = DBTools.GetUserRoles(user.id);

        //List<string> allowedApps = new List<string>();

        //foreach (var appPerms in user.userRoles)
        //{
        //    if (appPerms.accessLevelRead == true)
        //    {
        //        allowedApps.Add(appPerms.application);
        //    }
        //}


        DateTime? requestedLastModifiedDate;

        if (!lastModifiedDate.IsNullOrWhiteSpace())
        {
            requestedLastModifiedDate = DateTime.Parse(lastModifiedDate);
        }
        else
        {
            requestedLastModifiedDate = null;
        }

        string json = "";

        try
        {
            ObjectDataTableResponse<ObjectBypassRecord> dataTableResponse = new ObjectDataTableResponse<ObjectBypassRecord>();

            results = DBTools.GetConfigurations(
                userName,
                application,
                language,
                dnis,
                destinationPhoneNumber,
                peg,
                rank,
                offerId,
                offerType,
                lastModifiedBy,
                requestedLastModifiedDate
            );

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