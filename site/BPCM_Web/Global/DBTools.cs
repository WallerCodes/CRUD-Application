using BPCM;
using Microsoft.Ajax.Utilities;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;

/// <record>
/// Summary description for DBTools
/// </record>
public class DBTools
{
    public static List<ObjectApplication> GetApplications(string allowedApps, bool superAdminOverride)
    {
        using (UsanCommand cmd = new UsanCommand("bypass.GetApplications", UsanCommandType.PROCEDURE))
        {
            //if (!superAdminOverride)
            //{
            //   cmd.AddSearchParameter(new UsanParameter("application", allowedApps, UsanParameterType.IN_ARRAY));
            //}
            //cmd.AddSearchParameter(new UsanParameter("application", allowedApps));
            cmd.OrderAsc = true;
            DataTable table = cmd.GetDBTable();
            List<ObjectApplication> results = new List<ObjectApplication>();

            // shared logic
            for (var a = 0; a < table.Rows.Count; a++)
            {
                var row = table.Rows[a];
                ObjectApplication field = new ObjectApplication();
                field.applicationId = Int32.Parse(row["applicationId"].ToString());
                field.applicationName = row["application"].ToString();
                results.Add(field);
            }

            return results;
        }
    }

    public static List<ObjectLanguage> GetLanguages()
    {
        using (UsanCommand cmd = new UsanCommand("bypass.GetLanguages", UsanCommandType.PROCEDURE))
        {
            cmd.OrderAsc = true;
            DataTable table = cmd.GetDBTable();
            List<ObjectLanguage> results = new List<ObjectLanguage>();

            // shared logic
            for (var a = 0; a < table.Rows.Count; a++)
            {
                var row = table.Rows[a];
                ObjectLanguage field = new ObjectLanguage();
                field.languageId = Int32.Parse(row["languageId"].ToString());
                field.languageName = row["language"].ToString();
                results.Add(field);
            }

            return results;
        }
    }

    public static ObjectConfiguration AddConfiguration(
        string application,
        string language,
        string dnis,
        string destination,
        string peg,
        string rank,
        string offerId,
        string offerType,
        string skillId,
        string skillName,
        string agentsAvailableStr,
        string medInSecondsStr,
        string overflowSkillId,
        string overflowSkillName,
        string overflowAgentsAvailableStr,
        string overflowMedStr,
        string lastModifiedBy
)
    {

        using (UsanCommand cmd = new UsanCommand("bypass.AddConfiguration", UsanCommandType.PROCEDURE))
        {
            cmd.AddSearchParameter(new UsanParameter("applicationName", application));
            cmd.AddSearchParameter(new UsanParameter("languageName", language));
            cmd.AddSearchParameter(new UsanParameter("dnis", dnis));
            cmd.AddSearchParameter(new UsanParameter("destination", destination));
            cmd.AddSearchParameter(new UsanParameter("rank", rank));
            cmd.AddSearchParameter(new UsanParameter("offerId", offerId));
            cmd.AddSearchParameter(new UsanParameter("offerType", offerType));
            cmd.AddSearchParameter(new UsanParameter("peg", peg));
            cmd.AddSearchParameter(new UsanParameter("skillId", skillId));
            cmd.AddSearchParameter(new UsanParameter("skillName", skillName));
            cmd.AddSearchParameter(new UsanParameter("agentsAvailable", string.IsNullOrEmpty(agentsAvailableStr) ? (int?)null : int.Parse(agentsAvailableStr)));
            cmd.AddSearchParameter(new UsanParameter("med", string.IsNullOrEmpty(medInSecondsStr) ? (int?)null : int.Parse(medInSecondsStr)));
            cmd.AddSearchParameter(new UsanParameter("overflowSkillId", overflowSkillId));
            cmd.AddSearchParameter(new UsanParameter("overflowSkillName", overflowSkillName));
            cmd.AddSearchParameter(new UsanParameter("overflowAgentsAvailable", string.IsNullOrEmpty(overflowAgentsAvailableStr) ? (int?)null : int.Parse(overflowAgentsAvailableStr)));
            cmd.AddSearchParameter(new UsanParameter("overflowMed", string.IsNullOrEmpty(overflowMedStr) ? (int?)null : int.Parse(overflowMedStr)));
            cmd.AddSearchParameter(new UsanParameter("lastModifiedUserName", lastModifiedBy));
            cmd.AddSearchParameter(new UsanParameter("order", null));

            DataTable table = cmd.GetDBTable();

            ObjectConfiguration results = new ObjectConfiguration();

            //var row = table.Rows[0]; // SP only returns a single row

            ObjectConfiguration configuration = new ObjectConfiguration();

            return configuration;
        }
    }

    public static ObjectConfiguration UpdateConfiguration(
        string configurationId,
        string application,
        string language,
        string dnis,
        string destination,
        string peg,
        string rank,
        string offerId,
        string offerType,
        string skillId,
        string skillName,
        string agentsAvailableStr,
        string medInSecondsStr,
        string overflowSkillId,
        string overflowSkillName,
        string overflowAgentsAvailableStr,
        string overflowMedStr,
        string lastModifiedBy
)
    {

        using (UsanCommand cmd = new UsanCommand("bypass.UpdateConfiguration", UsanCommandType.PROCEDURE))
        {
            cmd.AddSearchParameter(new UsanParameter("configurationId", configurationId));
            cmd.AddSearchParameter(new UsanParameter("applicationName", application));
            cmd.AddSearchParameter(new UsanParameter("languageName", language));
            cmd.AddSearchParameter(new UsanParameter("dnis", dnis));
            cmd.AddSearchParameter(new UsanParameter("destination", destination));
            cmd.AddSearchParameter(new UsanParameter("rank", rank));
            cmd.AddSearchParameter(new UsanParameter("offerId", offerId));
            cmd.AddSearchParameter(new UsanParameter("offerType", offerType));
            cmd.AddSearchParameter(new UsanParameter("peg", peg));
            cmd.AddSearchParameter(new UsanParameter("skillId", skillId));
            cmd.AddSearchParameter(new UsanParameter("skillName", skillName));
            cmd.AddSearchParameter(new UsanParameter("agentsAvailable", string.IsNullOrEmpty(agentsAvailableStr) ? (int?)null : int.Parse(agentsAvailableStr)));
            cmd.AddSearchParameter(new UsanParameter("med", string.IsNullOrEmpty(medInSecondsStr) ? (int?)null : int.Parse(medInSecondsStr)));
            cmd.AddSearchParameter(new UsanParameter("overflowSkillId", overflowSkillId));
            cmd.AddSearchParameter(new UsanParameter("overflowSkillName", overflowSkillName));
            cmd.AddSearchParameter(new UsanParameter("overflowAgentsAvailable", string.IsNullOrEmpty(overflowAgentsAvailableStr) ? (int?)null : int.Parse(overflowAgentsAvailableStr)));
            cmd.AddSearchParameter(new UsanParameter("overflowMed", string.IsNullOrEmpty(overflowMedStr) ? (int?)null : int.Parse(overflowMedStr)));
            cmd.AddSearchParameter(new UsanParameter("lastModifiedUserName", lastModifiedBy));
            cmd.AddSearchParameter(new UsanParameter("order", null));

            DataTable table = cmd.GetDBTable();

            //var row = table.Rows[0]; // SP only returns a single row

            ObjectConfiguration configuration = new ObjectConfiguration();

            //configuration.ConfigurationId = Convert.ToInt32(row["bypassConfigurationId"]);
            //configuration.Order = Convert.ToInt32(row["order"]);
            //configuration.ApplicationId = Convert.ToInt32(row["applicationId"]);
            //configuration.LanguageId = Convert.ToInt32(row["languageId"]);
            //configuration.Dnis = row["dnis"].ToString();
            //configuration.Destination = row["destination"].ToString();
            //configuration.Rank = row["rank"].ToString();
            //configuration.OfferId = row["offerId"].ToString();
            //configuration.OfferType = row["offerType"].ToString();

            //configuration.Peg = row["peg"].ToString();

            //configuration.SkillId = row["skillId"].ToString();
            //configuration.SkillName = row["skillName"].ToString();

            //configuration.AgentsAvailable = Convert.ToInt32(row["agentsAvailable"]);
            //configuration.MedInSeconds = Convert.ToInt32(row["med"]);

            //configuration.OverflowSkillId = row["overflowSkillId"].ToString();
            //configuration.OverflowSkillName = row["overflowSkillName"].ToString();
            //configuration.OverflowAgentsAvailable = Convert.ToInt32(row["overflowAgentsAvailable"]);
            //configuration.OverflowMed = Convert.ToInt32(row["overflowMed"]);

            //configuration.LastModifiedBy = row["lastModifiedUserId"].ToString();
            //configuration.LastModifiedDate = row["lastModifiedDateTime"].ToString();

            return configuration;
        }
    }

    public static List<ObjectBypassRecord> GetConfigurations(
    string userName,
    string application,
    string language,
    string dnis,
    string destinationPhoneNumber,
    string peg,
    string rank,
    string offerId,
    string offerType,
    string lastModifiedBy,
    DateTime? lastModifiedDate
)
    {
        List<ObjectBypassRecord> records = new List<ObjectBypassRecord>();

        using (UsanCommand cmd = new UsanCommand("bypass.GetConfigurations", UsanCommandType.PROCEDURE))
        {
            cmd.AddSearchParameter(new UsanParameter("userName", userName));
            cmd.AddSearchParameter(new UsanParameter("application", application.IsNullOrWhiteSpace() ? null : application));
            cmd.AddSearchParameter(new UsanParameter("language", language.IsNullOrWhiteSpace() ? null : language));
            cmd.AddSearchParameter(new UsanParameter("dnis", dnis.IsNullOrWhiteSpace() ? null : dnis));
            cmd.AddSearchParameter(new UsanParameter("destinationPhoneNumber", destinationPhoneNumber.IsNullOrWhiteSpace() ? null : destinationPhoneNumber));
            cmd.AddSearchParameter(new UsanParameter("peg", peg.IsNullOrWhiteSpace() ? null : peg));
            cmd.AddSearchParameter(new UsanParameter("rank", rank.IsNullOrWhiteSpace() ? null : rank));
            cmd.AddSearchParameter(new UsanParameter("offerId", offerId.IsNullOrWhiteSpace() ? null : offerId));
            cmd.AddSearchParameter(new UsanParameter("offerType", offerType.IsNullOrWhiteSpace() ? null : offerType));
            cmd.AddSearchParameter(new UsanParameter("lastModifiedBy", lastModifiedBy.IsNullOrWhiteSpace() ? null : lastModifiedBy));
            cmd.AddSearchParameter(new UsanParameter("lastModifiedDate", lastModifiedDate));

            //if (!lastModifiedDate.IsNullOrWhiteSpace())
            //{
            //    string inputDateString = lastModifiedDate;
            //    string inputFormat = "MMM dd, yyyy";
            //    string outputFormat = "yyyy-MM-dd";

            //    if (DateTime.TryParseExact(inputDateString, inputFormat, CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime parsedDate))
            //    {
            //        string outputDateString = parsedDate.ToString(outputFormat);
            //        cmd.AddSearchParameter(new UsanParameter("lastModifiedDate", outputDateString));

            //        Console.WriteLine($"Input: {inputDateString}, Output: {outputDateString}"); // Output: Input: may 01, 2025, Output: 2025-05-01
            //    }
            //    else
            //    {
            //        Console.WriteLine($"Failed to parse the date string: {inputDateString}");
            //    }
            //}

            var reader = cmd.ExecuteReader();

            var recordTable = new DataTable();
            recordTable.Load(reader);

            for (var a = 0; a < recordTable.Rows.Count; a++)
            {
                var row = recordTable.Rows[a];
                ObjectBypassRecord record = new ObjectBypassRecord();

                record.bypassConfigurationId = row["bypassConfigurationId"].ToString();
                record.application = row["application"].ToString();
                record.language = row["language"].ToString();
                record.dnis = row["dnis"].ToString();
                record.destination = row["destination"].ToString();
                record.rank = row["rank"].ToString();
                record.offerId = row["offerId"].ToString();
                record.offerType = row["offerType"].ToString();
                record.peg = row["peg"].ToString();
                record.skillId = row["skillId"].ToString();
                record.skillName = row["skillName"].ToString();
                record.agentsAvailable = row["agentsAvailable"].ToString();
                record.med = row["med"].ToString();
                record.overflowSkillId = row["overflowSkillId"].ToString();
                record.overflowSkillName = row["overflowSkillName"].ToString();
                record.overflowAgentsAvailable = row["overflowAgentsAvailable"].ToString();
                record.overflowMed = row["overflowMed"].ToString();
                record.lastModifiedUserName = row["lastModifiedUserName"].ToString();
                record.lastModifiedDate = DateTime.Parse(row["lastModifiedDateTime"].ToString()).ToString("MM/dd/yy");
                record.order = row["order"].ToString(); // Order property helps us maintain row integrity when sorting (headers don't shift)

                records.Add(record);
            }

            records = records.OrderBy(obj => obj.application).ToList();

            int i = 0;
            string previousApp = "";
            while (i < records.Count)
            {
                if (previousApp != records[i].application)
                {
                    previousApp = records[i].application;
                    records.Insert(i, new ObjectBypassRecord() { application = previousApp, language = previousApp, isHeader = true, order = "0" });
                    i++;
                }
                else
                {
                    i++;
                }
            }

            return records;
        }
    }

    public static ObjectConfiguration UpdateConfigurationOrder(List<ObjectConfigurationOrder> configurationOrderList)
    {
        using (SqlCommand cmd = new SqlCommand("bypass.UpdateConfigurationOrder", new SqlConnection(UsanCommand.CONN_STR)))
        {
            cmd.CommandType = CommandType.StoredProcedure;

            // Create the DataTable for the Table-Valued Parameter
            DataTable configOrderTable = new DataTable();
            configOrderTable.Columns.Add("configurationId", typeof(int));
            configOrderTable.Columns.Add("order", typeof(int));

            foreach (var configOrder in configurationOrderList)
            {
                configOrderTable.Rows.Add(configOrder.configurationId, configOrder.order);
            }

            // Create the SqlParameter for the Table-Valued Parameter
            SqlParameter sqlParam = new SqlParameter("@ConfigurationOrderList", configOrderTable);
            sqlParam.SqlDbType = SqlDbType.Structured;
            sqlParam.TypeName = "bypass.ConfigurationOrderList"; // Ensure this matches the SQL Server type

            // Add the parameter to the SqlCommand
            cmd.Parameters.Add(sqlParam);

            cmd.Connection.Open();
            cmd.ExecuteNonQuery();

            return new ObjectConfiguration();
        }
    }

    public static ObjectConfiguration RemoveConfiguration(string configurationId)
    {
        List<ObjectBypassRecord> records = new List<ObjectBypassRecord>();

        using (UsanCommand cmd = new UsanCommand("bypass.RemoveConfiguration", UsanCommandType.PROCEDURE))
        {
            cmd.AddSearchParameter(new UsanParameter("bypassConfigurationId", configurationId));
            var reader = cmd.ExecuteReader();

            var recordTable = new DataTable();
            recordTable.Load(reader);

            ObjectConfiguration configuration = new ObjectConfiguration();

            return configuration;
        }
    }

    private static bool getBoolValue(object v)
    {
        var str = v.ToString().ToLowerInvariant();
        if (str == "1" || str == "true")
        {
            return true;
        }

        return false;
    }


    /* USERS */
    public static DUser GetFullUser(string login)
    {
        using (UsanCommand cmd = new UsanCommand("bypass.users", UsanCommandType.SELECT))
        {

            cmd.AddSearchParameter(new UsanParameter("userName", login, action: UsanParameterAction.WHERE));
            DUser user = new DUser();

            DataTable table = cmd.GetDBTable();

            // shared logic
            if (table.Rows.Count == 1)
            {
                var row = table.Rows[0];
                user.id = Int32.Parse(row["userId"].ToString());
                System.Diagnostics.Debug.WriteLine($"userId retrieved from DB: {user.id} ");
                user.userName = row["userName"].ToString();
                user.password = row["password"].ToString();
                user.isDeleted = getBoolValue(row["deleted"]);
                user.isDisabled = getBoolValue(row["disabled"]);
                user.isSuperAdmin = getBoolValue(row["isSuperAdmin"]);
                user.isUsanUser = getBoolValue(row["isUsanUser"]);
                user.isLocked = getBoolValue(row["locked"]);
                user.forceChangePassword = getBoolValue(row["forceChangePassword"]);

                user.failedLoginAttempts = Int32.Parse(row["failedLoginAttempts"].ToString());


                user.lastPasswordChangeDate = new DateTime(1900, 1, 1);
                var lastPasswordChangeDate = row["lastPasswordChangeDate"].ToString();
                if (lastPasswordChangeDate != null && lastPasswordChangeDate.Length > 0)
                {
                    user.lastPasswordChangeDate = DateTime.Parse(lastPasswordChangeDate);
                }

                user.lastLogin = new DateTime(1900, 1, 1);
                var lastLogin = row["lastLoginDate"].ToString();
                if (lastLogin != null && lastLogin.Length > 0)
                {
                    user.lastLogin = DateTime.Parse(lastLogin);
                }
            }

            user.userRoles = GetUserRoles(user.id);

            return user;
        }
    }

    public static DUser GetFullUserById(int userId)
    {
        using (UsanCommand cmd = new UsanCommand("bypass.users", UsanCommandType.SELECT))
        {

            cmd.AddSearchParameter(new UsanParameter("userId", userId, action: UsanParameterAction.WHERE));
            DUser user = new DUser();

            DataTable table = cmd.GetDBTable();
            // shared logic
            if (table.Rows.Count == 1)
            {
                var row = table.Rows[0];
                user.id = Int32.Parse(row["userId"].ToString());
                user.userName = row["userName"].ToString();
                user.password = row["password"].ToString();
                user.isDeleted = getBoolValue(row["deleted"]);
                user.isDisabled = getBoolValue(row["disabled"]);
                user.isSuperAdmin = getBoolValue(row["isSuperAdmin"]);
                user.isUsanUser = getBoolValue(row["isUsanUser"]);
                user.isLocked = getBoolValue(row["locked"]);
                user.forceChangePassword = getBoolValue(row["forceChangePassword"]);

                user.failedLoginAttempts = Int32.Parse(row["failedLoginAttempts"].ToString());


                user.lastPasswordChangeDate = new DateTime(1900, 1, 1);
                var lastPasswordChangeDate = row["lastPasswordChangeDate"].ToString();
                if (lastPasswordChangeDate != null && lastPasswordChangeDate.Length > 0)
                {
                    user.lastPasswordChangeDate = DateTime.Parse(lastPasswordChangeDate);
                }

                user.lastLogin = new DateTime(1900, 1, 1);
                var lastLogin = row["lastLoginDate"].ToString();
                if (lastLogin != null && lastLogin.Length > 0)
                {
                    user.lastLogin = DateTime.Parse(lastLogin);
                }
            }

            return user;
        }
    }

    public static DUser GetUserByName(string lookupUserName)
    {
        DUser user = new DUser();
        using (UsanCommand cmd = new UsanCommand("bypass.users", UsanCommandType.SELECT))
        {
            cmd.AddSearchParameter(new UsanParameter("userName", lookupUserName, action: UsanParameterAction.WHERE));

            DataTable table = cmd.GetDBTable();

            // shared logic
            for (var a = 0; a < table.Rows.Count; a++)
            {

                var row = table.Rows[a];
                user.id = Int32.Parse(row["userId"].ToString());
                user.userName = row["userName"].ToString();
                user.password = row["password"].ToString();
                user.isDeleted = getBoolValue(row["deleted"]);
                user.isDisabled = getBoolValue(row["disabled"]);
                user.isSuperAdmin = getBoolValue(row["isSuperAdmin"]);
                user.isUsanUser = getBoolValue(row["isUsanUser"]);
                user.isLocked = getBoolValue(row["locked"]);
                user.forceChangePassword = getBoolValue(row["forceChangePassword"]);

                user.failedLoginAttempts = Int32.Parse(row["failedLoginAttempts"].ToString());


                user.lastPasswordChangeDate = new DateTime(1900, 1, 1);
                var lastPasswordChangeDate = row["lastPasswordChangeDate"].ToString();
                if (lastPasswordChangeDate != null && lastPasswordChangeDate.Length > 0)
                {
                    user.lastPasswordChangeDate = DateTime.Parse(lastPasswordChangeDate);
                }

                user.lastLogin = new DateTime(1900, 1, 1);
                var lastLogin = row["lastLoginDate"].ToString();
                if (lastLogin != null && lastLogin.Length > 0)
                {
                    user.lastLogin = DateTime.Parse(lastLogin);
                }
            }
            //users.Sort((x, y) => x.userName.CompareTo(y.userName));

            return user;
        }
    }

    public static List<DUser> GetUsers(string lookupUserName, bool showDeleted, string sortOrder, string sortDir, bool isUsanUser)
    {
        List<DUser> users = new List<DUser>();
        using (UsanCommand cmd = new UsanCommand("bypass.users", UsanCommandType.SELECT))
        {

            if (!showDeleted)
            {
                cmd.AddSearchParameter(new UsanParameter("deleted", 0, action: UsanParameterAction.WHERE));
            }
            else
            {
                cmd.AddSearchParameter(new UsanParameter("deleted", 1, action: UsanParameterAction.WHERE));
            }

            if (!isUsanUser)
            {
                cmd.AddSearchParameter(new UsanParameter("isUsanUser", 0, action: UsanParameterAction.WHERE));
            }

            if (lookupUserName != null && lookupUserName != "")
            {
                cmd.AddSearchParameter(new UsanParameter("userName", lookupUserName, action: UsanParameterAction.WHERE));
            }

            cmd.Order = sortOrder;
            cmd.OrderAsc = sortDir == "asc" ? true : false;

            DataTable table = cmd.GetDBTable();

            // shared logic
            for (var a = 0; a < table.Rows.Count; a++)
            {
                DUser user = new DUser();
                var row = table.Rows[a];
                user.id = Int32.Parse(row["userId"].ToString());
                user.userName = row["userName"].ToString();
                user.password = row["password"].ToString();
                user.isDeleted = getBoolValue(row["deleted"]);
                user.isDisabled = getBoolValue(row["disabled"]);
                user.isSuperAdmin = getBoolValue(row["isSuperAdmin"]);
                user.isUsanUser = getBoolValue(row["isUsanUser"]);
                user.isLocked = getBoolValue(row["locked"]);
                user.forceChangePassword = getBoolValue(row["forceChangePassword"]);

                user.failedLoginAttempts = Int32.Parse(row["failedLoginAttempts"].ToString());


                user.lastPasswordChangeDate = new DateTime(1900, 1, 1);
                var lastPasswordChangeDate = row["lastPasswordChangeDate"].ToString();
                if (lastPasswordChangeDate != null && lastPasswordChangeDate.Length > 0)
                {
                    user.lastPasswordChangeDate = DateTime.Parse(lastPasswordChangeDate);
                }

                user.lastLogin = new DateTime(1900, 1, 1);
                var lastLogin = row["lastLoginDate"].ToString();
                if (lastLogin != null && lastLogin.Length > 0)
                {
                    user.lastLogin = DateTime.Parse(lastLogin);
                }

                users.Add(user);
            }
            //users.Sort((x, y) => x.userName.CompareTo(y.userName));

            return users;
        }
    }

    public static ObjectSearchResult<DUser> GetUsersTable(int start, int limit, string lookupUserName, bool showDeleted, string sortOrder, string sortDir, bool isUsanUser)
    {
        ObjectSearchResult<DUser> result = new ObjectSearchResult<DUser>();
        List<DUser> users = new List<DUser>();

        using (UsanCommand cmd1 = new UsanCommand("bypass.GetUsersCount", UsanCommandType.PROCEDURE),
              cmd2 = new UsanCommand("bypass.GetUsers", UsanCommandType.PROCEDURE))
        {
            cmd1.AddSearchParameter(new UsanParameter("userName", string.IsNullOrEmpty(lookupUserName) ? null : lookupUserName, action: UsanParameterAction.WHERE));
            cmd2.AddSearchParameter(new UsanParameter("userName", string.IsNullOrEmpty(lookupUserName) ? null : lookupUserName, action: UsanParameterAction.WHERE));

            cmd1.AddSearchParameter(new UsanParameter("deleted", showDeleted, action: UsanParameterAction.WHERE));
            cmd2.AddSearchParameter(new UsanParameter("deleted", showDeleted, action: UsanParameterAction.WHERE));

            cmd1.AddSearchParameter(new UsanParameter("isUsanUser", isUsanUser, action: UsanParameterAction.WHERE));
            cmd2.AddSearchParameter(new UsanParameter("isUsanUser", isUsanUser, action: UsanParameterAction.WHERE));

            DataTable datatable1 = cmd1.GetDBTable();

            for (int a = 0; a < datatable1.Rows.Count; a++)
            {
                var row = datatable1.Rows[a];
                result.total = Int32.Parse(row["userCount"].ToString());
            }

            cmd2.AddSearchParameter(new UsanParameter("start", start));
            cmd2.AddSearchParameter(new UsanParameter("limit", limit));
            cmd2.AddSearchParameter(new UsanParameter("sortOrder", sortOrder));
            cmd2.AddSearchParameter(new UsanParameter("sortDir", sortDir));

            DataTable table = cmd2.GetDBTable();

            // shared logic
            for (var a = 0; a < table.Rows.Count; a++)
            {
                DUser user = new DUser();
                var row = table.Rows[a];
                user.id = Int32.Parse(row["userId"].ToString());
                user.userName = row["userName"].ToString();
                user.password = row["password"].ToString();
                user.isDeleted = getBoolValue(row["deleted"]);
                user.isDisabled = getBoolValue(row["disabled"]);
                user.isSuperAdmin = getBoolValue(row["isSuperAdmin"]);
                user.isUsanUser = getBoolValue(row["isUsanUser"]);
                user.isLocked = getBoolValue(row["locked"]);
                user.forceChangePassword = getBoolValue(row["forceChangePassword"]);

                user.failedLoginAttempts = Int32.Parse(row["failedLoginAttempts"].ToString());


                user.lastPasswordChangeDate = new DateTime(1900, 1, 1);
                var lastPasswordChangeDate = row["lastPasswordChangeDate"].ToString();
                if (lastPasswordChangeDate != null && lastPasswordChangeDate.Length > 0)
                {
                    user.lastPasswordChangeDate = DateTime.Parse(lastPasswordChangeDate);
                }

                user.lastLogin = new DateTime(1900, 1, 1);
                var lastLogin = row["lastLoginDate"].ToString();
                if (lastLogin != null && lastLogin.Length > 0)
                {
                    user.lastLogin = DateTime.Parse(lastLogin);
                }

                users.Add(user);
            }
            //users.Sort((x, y) => x.userName.CompareTo(y.userName));
            result.rows = users;

            return result;
        }
    }

    public static List<ObjectUserRoles> GetUserRoles(int userId)
    {
        List<ObjectUserRoles> userRoles = new List<ObjectUserRoles>();

        // get count
        using (UsanCommand cmd = new UsanCommand("bypass.GetUserRoles", UsanCommandType.PROCEDURE))
        {
            cmd.AddSearchParameter(new UsanParameter("userId", userId));

            DataTable table = cmd.GetDBTable();

            // shared logic
            for (var a = 0; a < table.Rows.Count; a++)
            {
                ObjectUserRoles appRoles = new ObjectUserRoles();
                var row = table.Rows[a];

                //appRoles.userName = row["userName"].ToString();
                appRoles.application = row["application"].ToString();

                string[] roles = row["roles"].ToString().Split(',');

                foreach (var role in roles)
                {
                    if (role == ObjectUserRoles.Read)
                    {
                        appRoles.accessLevelRead = true;
                    }

                    if (role == ObjectUserRoles.Edit)
                    {
                        appRoles.accessLevelEdit = true;
                    }

                    if (role == ObjectUserRoles.Admin)
                    {
                        appRoles.accessLevelAdmin = true;
                    }
                }

                if (appRoles.accessLevelRead || appRoles.accessLevelEdit || appRoles.accessLevelAdmin)
                {
                    // its init true
                    appRoles.accessLevelNone = false;
                }

                userRoles.Add(appRoles);
            }

            return userRoles;
        }
    }

    public static int AddUser(DUser user)
    {
        using (UsanCommand cmd = new UsanCommand("bypass.users", UsanCommandType.INSERT))
        {
            cmd.AddSearchParameter(new UsanParameter("userName", user.userName, UsanParameterType.EQUAL));
            cmd.AddSearchParameter(new UsanParameter("password", user.password, UsanParameterType.EQUAL));
            cmd.AddSearchParameter(new UsanParameter("isSuperAdmin", user.isSuperAdmin, UsanParameterType.EQUAL));
            cmd.AddSearchParameter(new UsanParameter("deleted", 0, UsanParameterType.EQUAL));
            cmd.AddSearchParameter(new UsanParameter("locked", 0, UsanParameterType.EQUAL));
            cmd.AddSearchParameter(new UsanParameter("isUsanUser", 0, UsanParameterType.EQUAL));

            cmd.IDColumn = "userId";

            return cmd.GetDBScalar();
        }
    }

    public static void UpdateUser(DUser user, UserUpdateType updateType)
    {
        using (UsanCommand cmd = new UsanCommand("bypass.UpdateUser", UsanCommandType.PROCEDURE))
        //using (UsanCommand cmd = new UsanCommand("bypass.users", UsanCommandType.UPDATE))
        {
            cmd.AddSearchParameter(new UsanParameter("userId", user.id, action: UsanParameterAction.WHERE));
            cmd.AddSearchParameter(new UsanParameter("pwd", user.password, action: UsanParameterAction.SET));
            cmd.AddSearchParameter(new UsanParameter("delete", user.isDeleted, action: UsanParameterAction.SET));
            cmd.AddSearchParameter(new UsanParameter("disable", null, action: UsanParameterAction.SET));
            cmd.AddSearchParameter(new UsanParameter("isSuperAdmin", user.isSuperAdmin, action: UsanParameterAction.SET));
            cmd.AddSearchParameter(new UsanParameter("isUsanUser", user.isUsanUser, action: UsanParameterAction.SET));
            cmd.AddSearchParameter(new UsanParameter("locked", user.isLocked, action: UsanParameterAction.SET));
            cmd.AddSearchParameter(new UsanParameter("forceChangePassword", null, action: UsanParameterAction.SET));
            cmd.AddSearchParameter(new UsanParameter("failedLoginAttempts", null, action: UsanParameterAction.SET));
            cmd.AddSearchParameter(new UsanParameter("lastLoginDate", DateTime.Parse("1/1/1753 12:00:00 AM"), action: UsanParameterAction.SET));

            cmd.ExecuteNonQuery();
        }
    }

    public static void UpdateUserRoles(DUser user)
    {
        ObjectUserRoles newRole = user.userRoles[0];
        using (UsanCommand cmd = new UsanCommand("bypass.UpdateUserRoles", UsanCommandType.PROCEDURE))
        {

            cmd.AddSearchParameter(new UsanParameter("userId", user.id));

            cmd.AddSearchParameter(new UsanParameter("application", newRole.application));
            cmd.AddSearchParameter(new UsanParameter("accessLevelRead", newRole.accessLevelRead));
            cmd.AddSearchParameter(new UsanParameter("accessLevelEdit", newRole.accessLevelEdit));
            cmd.AddSearchParameter(new UsanParameter("accessLevelAdmin", newRole.accessLevelAdmin));
            cmd.AddSearchParameter(new UsanParameter("accessLevelNone", newRole.accessLevelNone));

            cmd.ExecuteNonQuery();
        }
    }

    public static void UserAudit(DUser performerUser, DUser affectedUser, string beforeVal, string afterVal, UserAuditAction userAuditAction)
    {
        using (UsanCommand cmd = new UsanCommand("bypass.AddUserAudit", UsanCommandType.PROCEDURE))
        {

            //cmd.AddSearchParameter(new UsanParameter("auditDate", null, UsanParameterType.EQUAL));
            cmd.AddSearchParameter(new UsanParameter("performerUserId", performerUser.id, UsanParameterType.EQUAL));
            cmd.AddSearchParameter(new UsanParameter("affectedUserId", affectedUser.id, UsanParameterType.EQUAL));
            cmd.AddSearchParameter(new UsanParameter("userAuditActionId", userAuditAction, UsanParameterType.EQUAL));
            cmd.AddSearchParameter(new UsanParameter("beforeValue", beforeVal, UsanParameterType.EQUAL));
            cmd.AddSearchParameter(new UsanParameter("afterValue", afterVal, UsanParameterType.EQUAL));
            cmd.IDColumn = "userAuditId";

            cmd.ExecuteNonQuery();
        }
    }

    public static List<ObjectHistory> GetHistory(int userID)
    {
        List<ObjectHistory> histories = new List<ObjectHistory>();
        using (UsanCommand cmd = new UsanCommand("History", UsanCommandType.SELECT))
        {
            cmd.AddSearchParameter(new UsanParameter("userId", userID));
            cmd.Limit = 100;

            DataTable table = cmd.GetDBTable();
            // shared logic
            for (var a = 0; a < table.Rows.Count; a++)
            {
                ObjectHistory hist = new ObjectHistory();
                var row = table.Rows[a];
                hist.auditId = Int32.Parse(row["userAuditId"].ToString());
                hist.affectedUserId = Int32.Parse(row["affectedUserId"].ToString());
                hist.performerUserId = Int32.Parse(row["performerUserId"].ToString());
                hist.actionId = Int32.Parse(row["userAuditActionId"].ToString());

                hist.actionTime = new DateTime(1900, 1, 1);
                var lastLogin = row["auditDate"].ToString();
                if (lastLogin != null && lastLogin.Length > 0)
                {
                    hist.actionTime = DateTime.Parse(lastLogin);
                }
                histories.Add(hist);
            }

            return histories;
        }
    }

    public static ObjectSearchResult<ObjectHistory> GetHistoryResults(int start, int limit, string sortOrder, string sortDir, string performingUserName, string affectedUserName, string actionName, DateTime startDate, DateTime endDate, bool isUsanUser)
    {
        ObjectSearchResult<ObjectHistory> result = new ObjectSearchResult<ObjectHistory>();
        List<ObjectHistory> histories = new List<ObjectHistory>();

        // get count
        using (UsanCommand cmd1 = new UsanCommand("bypass.GetUserAuditHistoryCount", UsanCommandType.PROCEDURE),
              cmd2 = new UsanCommand("bypass.GetUserAuditHistory", UsanCommandType.PROCEDURE))
        {
            cmd1.AddSearchParameter(new UsanParameter("affectedUserName", affectedUserName));
            cmd1.AddSearchParameter(new UsanParameter("performerUserName", performingUserName));
            cmd1.AddSearchParameter(new UsanParameter("userAuditActionName", actionName));
            cmd1.AddSearchParameter(new UsanParameter("startDate", startDate));
            cmd1.AddSearchParameter(new UsanParameter("endDate", endDate));
            cmd1.AddSearchParameter(new UsanParameter("isUsanUser", isUsanUser));

            DataTable datatable1 = cmd1.GetDBTable();

            for (int a = 0; a < datatable1.Rows.Count; a++)
            {
                var row = datatable1.Rows[a];
                result.total = Int32.Parse(row["historyCount"].ToString());
            }

            cmd2.AddSearchParameter(new UsanParameter("start", start));
            cmd2.AddSearchParameter(new UsanParameter("limit", limit));
            cmd2.AddSearchParameter(new UsanParameter("affectedUserName", affectedUserName));
            cmd2.AddSearchParameter(new UsanParameter("performerUserName", performingUserName));
            cmd2.AddSearchParameter(new UsanParameter("userAuditActionName", actionName));
            cmd2.AddSearchParameter(new UsanParameter("startDate", startDate));
            cmd2.AddSearchParameter(new UsanParameter("endDate", endDate));
            cmd2.AddSearchParameter(new UsanParameter("isUsanUser", isUsanUser));
            cmd2.AddSearchParameter(new UsanParameter("sortOrder", sortOrder));
            cmd2.AddSearchParameter(new UsanParameter("sortDir", sortDir));

            DataTable datatable2 = cmd2.GetDBTable();

            for (int a = 0; a < datatable2.Rows.Count; a++)
            {
                ObjectHistory hist = new ObjectHistory();
                var row = datatable2.Rows[a];
                hist.auditId = Int32.Parse(row["userAuditId"].ToString());
                hist.affectedUserId = Int32.Parse(row["affectedUserId"].ToString());
                hist.affectedUserName = row["affectedUserName"].ToString();
                hist.performerUserId = Int32.Parse(row["performerUserId"].ToString());
                hist.performerUserName = row["performerUserName"].ToString();
                hist.actionId = Int32.Parse(row["userAuditActionId"].ToString());
                hist.action = row["auditDescription"].ToString();
                hist.afterValue = row["afterValue"].ToString();

                hist.actionTime = new DateTime(1900, 1, 1);
                var lastLogin = row["auditDate"].ToString();
                if (lastLogin != null && lastLogin.Length > 0)
                {
                    hist.actionTime = DateTime.Parse(lastLogin);
                }
                histories.Add(hist);
            }

            result.rows = histories;

            return result;
        }
    }

    public static List<ObjectAction> GetHistoryActions()
    {
        List<ObjectAction> actions = new List<ObjectAction>();
        using (UsanCommand cmd = new UsanCommand("bypass_static.userAuditActions", UsanCommandType.SELECT))
        {
            // hiding these audit actions to not be searchable
            // Add Role, Delete Role, Update Role, Failed Login
            cmd.AddSearchParameter(new UsanParameter("userAuditActionId", "4", action: UsanParameterAction.WHERE, type: UsanParameterType.NOT_EQUAL));
            cmd.AddSearchParameter(new UsanParameter("userAuditActionId", "5", action: UsanParameterAction.WHERE, type: UsanParameterType.NOT_EQUAL));
            cmd.AddSearchParameter(new UsanParameter("userAuditActionId", "6", action: UsanParameterAction.WHERE, type: UsanParameterType.NOT_EQUAL));
            cmd.AddSearchParameter(new UsanParameter("userAuditActionId", "7", action: UsanParameterAction.WHERE, type: UsanParameterType.NOT_EQUAL));

            DataTable table = cmd.GetDBTable();
            for (var a = 0; a < table.Rows.Count; a++)
            {
                ObjectAction action = new ObjectAction();
                var row = table.Rows[a];
                action.actionId = Int32.Parse(row["userAuditActionId"].ToString());
                action.action = row["auditDescription"].ToString();
                actions.Add(action);
            }
            //actions.Sort((x, y) => x.action.CompareTo(y.action));
            return actions;
        }
    }

    public static bool IsMySQL()
    {
        return false;
    }
}

