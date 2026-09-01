using BPCM;
using BPCM_Web.Global;
using Newtonsoft.Json;
using System;
using System.Web;
using System.Web.SessionState;

public class UpdateConfiguration : AjaxHandler
{
    protected override bool checkSecurity(DUser user)
    {
        // This might need to be changed to be less restrictive. Should be user.isEdit?
        if (user == null || user.isSuperAdmin == false)
        {
            return false;
        }
        return true;
    }

    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser dUser, HttpContext context)
    {
        ObjectConfiguration result = new ObjectConfiguration();

        string configurationId = parseSingleParameter<string>(request, "configurationId", true);
        string application = parseSingleParameter<string>(request, "application", true);
        string language = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "language", true));
        string dnis = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "dnis", false));
        string destination = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "destination", false));
        string peg = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "peg", false));
        string rank = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "rank", false));
        string offerId = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "offerId", false));
        string offerType = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "offerType", false));

        string skillName = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "skillName", false));
        string skillId = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "skillId", false));
        string agentsAvailableStr = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "agentsAvailable", false));
        string medInSecondsStr = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "medInSeconds", false));

        string overflowSkillName = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "overflowSkillName", false));
        string overflowSkillId = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "overflowSkillId", false));
        string overflowAgentsAvailableStr = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "overflowAgentsAvailable", false));
        string overflowMedStr = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "overflowMed", false));

        string lastModifiedBy = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "lastModifiedUserName", true));
        string email = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "performerUserEmail", true));

        string json = "";

        DUser user = DBTools.GetFullUser(email);

        ObjectDataTableResponse<ObjectConfiguration> dataTableResponse = new ObjectDataTableResponse<ObjectConfiguration>();

        try
        {
            result = DBTools.UpdateConfiguration(
                configurationId,
                application,
                language,
                dnis,
                destination,
                peg,
                rank,
                offerId,
                offerType,
                skillId,
                skillName,
                agentsAvailableStr,
                medInSecondsStr,
                overflowSkillId,
                overflowSkillName,
                overflowAgentsAvailableStr,
                overflowMedStr,
                lastModifiedBy
            );

            dataTableResponse.success = true;
            json = JsonConvert.SerializeObject(dataTableResponse);
            context.Response.ContentType = "text/plain";
            context.Response.Write(json);
        }
        catch (Exception e)
        {
            log.Error("Got exception processing request " + request.RawUrl + ": " + e.Message, e);
            if (e.Message.Contains("duplicate"))
            {
                dataTableResponse.message = "Duplicate row. Language, DNIS, Destination, Rank, Offer ID, and Offer Type combination must be unique.";
            }
            else
            {
                dataTableResponse.message = $"An {e.GetType().Name} occurred";
            }

            dataTableResponse.success = false;
            json = JsonConvert.SerializeObject(dataTableResponse);
            context.Response.ContentType = "text/plain";
            context.Response.Write(json);
        }

        DBTools.UserAudit(user, user, "", "Update Configuration", UserAuditAction.DELETE_CONFIGURATION);

        return context;
    }
}