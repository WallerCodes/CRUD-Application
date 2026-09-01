using BPCM;
using System.Collections.Generic;
using System.Web;
using System.Web.SessionState;

public class AdminUpdateUser : AjaxHandler
{
    protected override bool checkSecurity(DUser user)
    {
        if (user == null)
        {
            return false;
        }
        return true;
    }

    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context)
    {
        int affectedUserId = parseSingleParameter<int>(request, "affectedUser", true);
        string applicationName = parseSingleParameter<string>(request, "application", true);
        string accessLevel = parseSingleParameter<string>(request, "accessLevel", true);
        bool isLocked = parseSingleParameter<bool>(request, "isLocked", false);
        bool prevSetting = false; // = parseSingleParameter<bool>(request, "roleSetting", false);
        bool isSuperAdmin = parseSingleParameter<bool>(request, "isSuperAdmin", false);

        bool accessNone = parseSingleParameter<bool>(request, "accessLevelNone", false);
        bool accessRead = parseSingleParameter<bool>(request, "accessLevelRead", false);
        bool accessEdit = parseSingleParameter<bool>(request, "accessLevelEdit", false);
        bool accessAdmin = parseSingleParameter<bool>(request, "accessLevelAdmin", false);

        string json = "";


        // get the affected user
        var testUser = DBTools.GetFullUserById(affectedUserId);

        if (testUser.userName == null || testUser.userName.Length == 0)
        {
            log.Info("UpdateUser failed trying because performing user invalid. affectedUser is missing!");
            //log.Info("userName: " + userName + " failed trying to update isSuperAdmin for userName: " + userName + ", isSuperAdmin: " + tempInverseAuth);
            context.Response.ContentType = "text/plain";
            context.Response.Write("{\"error\":\"Missing Info\"}");
            return false;
        }


        if (testUser.userName == user.userName)
        {
            //IsSuccess = false;
            context.Response.ContentType = "text/plain";
            context.Response.Write("{\"error\":\"Cannot update or delete your user\"}");
            return false;
        }

        //string prevLocked = testUser.isLocked.ToString();

        if (!string.IsNullOrEmpty(applicationName) && !string.IsNullOrEmpty(accessLevel))
        {
            testUser.userRoles = new List<ObjectUserRoles>();

            ObjectUserRoles tempRole = new ObjectUserRoles();

            tempRole.application = applicationName;

            tempRole.accessLevelRead = accessRead;
            tempRole.accessLevelEdit = accessEdit;
            tempRole.accessLevelAdmin = accessAdmin;
            tempRole.accessLevelNone = accessNone;

            if (accessLevel == ObjectUserRoles.None)
            {
                prevSetting = !accessNone;

                if (accessNone)
                {
                    tempRole.accessLevelNone = true;
                }
            }

            if (accessLevel == ObjectUserRoles.Read)
            {
                prevSetting = !accessRead;

                if (accessRead)
                {
                    tempRole.accessLevelRead = true;
                    tempRole.accessLevelNone = false;
                }
                else
                {
                    tempRole.accessLevelRead = false;
                    tempRole.accessLevelEdit = false;
                    tempRole.accessLevelAdmin = false;
                }

            }

            if (accessLevel == ObjectUserRoles.Edit)
            {
                prevSetting = !accessEdit;

                if (accessEdit)
                {
                    tempRole.accessLevelRead = true;
                    tempRole.accessLevelEdit = true;
                    tempRole.accessLevelNone = false;
                }
                else
                {
                    tempRole.accessLevelEdit = false;
                    tempRole.accessLevelAdmin = false;
                }

            }

            if (accessLevel == ObjectUserRoles.Admin)
            {
                prevSetting = !accessAdmin;

                if (accessAdmin)
                {
                    tempRole.accessLevelRead = true;
                    tempRole.accessLevelEdit = true;
                    tempRole.accessLevelAdmin = true;
                    tempRole.accessLevelNone = false;
                }
                else
                {
                    tempRole.accessLevelAdmin = false;
                }

            }

            testUser.userRoles.Add(tempRole);

            DBTools.UpdateUserRoles(testUser);

            DBTools.UserAudit(user, testUser, accessLevel + " - " + applicationName + " " + (prevSetting == false ? "false" : "true"), accessLevel + " - " + applicationName + " " + (prevSetting == false ? "true" : "false"), UserAuditAction.CHANGE_USER_ROLE);

            log.Info($"User: {user.userName} updated Access Level \'{accessLevel}\' of User: {testUser.userName} from {prevSetting} to {!prevSetting}");
            json = "{\"success\":true}";
            context.Response.Write(json);
            return true;
        }


        // isSuperAdmin
        /*if (isSuperAdmin != null && isSuperAdmin.Length > 0)
        {
           testUser.isSuperAdmin = isSuperAdmin == "false" ? false : true;
           DBTools.UpdateUser(testUser, UserUpdateType.ADMIN);

           DBTools.UserAudit(user, testUser, tempInverseAuth, tempAuth, UserAuditAction.UPDATE_USER);

           log.Info("User: " + user.userName + " updated isSuperAdmin of User: " + testUser.userName + " from " + tempInverseAuth + " to " + tempAuth);
           json = "{\"success\":true}";
           context.Response.Write(json);
           return true;
        }*/


        // isLocked
        /*if (isLocked != null && isLocked.Length > 0)
        {
           testUser.isLocked = isLocked == "false" ? false : true;

           DBTools.UpdateUser(testUser, UserUpdateType.LOCKED);
           DBTools.UserAudit(user, testUser, prevLocked, testUser.isLocked.ToString(), UserAuditAction.UNLOCK_USER);

           log.Info("User: " + user.userName + " updated isLPAdmin of User: " + testUser.userName + " from " + prevLocked + " to " + testUser.isLocked.ToString());
           json = "{\"success\":true}";
           context.Response.Write(json);
           return true;
        }*/

        json = "{\"success\":false, \"error\":\"There was an error updating user\"}";
        context.Response.Write(json);
        return false;
    }
}