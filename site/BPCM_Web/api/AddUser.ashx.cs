using BPCM;
using BPCM_Web.Global;
using System;
using System.Web;
using System.Web.SessionState;

public class AddUser : AjaxHandler
{
    protected override bool checkSecurity(DUser user)
    {
        if (user == null || user.isSuperAdmin == false)
        {
            return false;
        }
        return true;
    }

    public override object ProcessRequest(HttpSessionState session, HttpRequest request, DUser dUser, HttpContext context)
    {
        string userNameToAdd = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "userName", true));
        string passwordToAdd = Extensions.NullIfWhiteSpace(parseSingleParameter<string>(request, "password", true));
        bool isSuperAdmin = parseSingleParameter<bool>(request, "isSuperAdmin", false);

        string email = parseSingleParameter<string>(request, "performerUserEmail", true);

        DUser performingUser = DBTools.GetFullUser(email);

        if (userNameToAdd != "" && userNameToAdd != "" && passwordToAdd != "" && userNameToAdd.Length > 0 && passwordToAdd.Length > 0)
        {
            var existingUser = DBTools.GetFullUser(userNameToAdd);
            if (!String.IsNullOrEmpty(existingUser.userName) && existingUser.isDeleted)
            {
                existingUser.isDeleted = false;
                existingUser.password = passwordToAdd;
                existingUser.isSuperAdmin = isSuperAdmin;

                DBTools.UpdateUser(existingUser, UserUpdateType.DELETED);
                DBTools.UpdateUser(existingUser, UserUpdateType.PASSWORD);
                DBTools.UpdateUser(existingUser, UserUpdateType.ADMIN);

                DBTools.UserAudit(performingUser, existingUser, "", "", UserAuditAction.CREATE_USER);

                log.Info($"User: {performingUser.userName} created New User with previously Deleted UserName (userNameToAdd: {existingUser.userName})");

                context.Response.ContentType = "text/plain";
                context.Response.Write("{\"success\":true}");
                return existingUser;
            }
            else if (!String.IsNullOrEmpty(existingUser.userName))
            {
                log.Info($"User: {performingUser.userName} attempted to Add User (userNameToAdd: {existingUser.userName}) but failed.");
                context.Response.ContentType = "text/plain";
                context.Response.Write("{\"error\":\"User with that User Name already exists\"}");
                return "User with that User Name already exists";
            }
            else
            {
                DUser newUser = new DUser();
                newUser.isSuperAdmin = isSuperAdmin;
                newUser.userName = userNameToAdd;
                newUser.isDeleted = false;
                newUser.password = passwordToAdd;
                newUser.userName = userNameToAdd;

                var results = DBTools.AddUser(newUser);

                //populate the new userId
                newUser = DBTools.GetFullUser(newUser.userName);

                DBTools.UserAudit(performingUser, newUser, "", "", UserAuditAction.CREATE_USER);

                log.Info($"User: {performingUser.userName} created New User (userNameToAdd: {newUser.userName})");

                context.Response.ContentType = "text/plain";
                context.Response.Write("{\"success\":true}");
                return results;
            }
        }
        else
        {
            //IsSuccess = false;
            log.Info($"User: {performingUser.userName} attempted to Add User (userNameToAdd: " + userNameToAdd + ") but failed.");
            context.Response.ContentType = "text/plain";
            context.Response.Write("{\"error\":\"Missing performingUser name or passwordToAdd\"}");
            return "Missing User Name or Password";
        }

    }
}