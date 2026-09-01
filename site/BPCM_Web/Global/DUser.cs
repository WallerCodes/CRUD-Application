using System;
using System.Collections.Generic;

/// <summary>
/// Summary description for AUUser
/// </summary>

[Serializable]
public class DUser
{
    public static readonly string USER_SESSION_KEY = "user_object";

    public int id;
    public string userName;
    public string password;
    public bool isDeleted;
    public bool isDisabled;
    public bool isSuperAdmin;
    public bool isUsanUser;
    public DateTime lastLogin;
    public bool isLocked;  // account locked out

    public int failedLoginAttempts;
    public DateTime lastPasswordChangeDate;
    public bool forceChangePassword;
    public DateTime dateAdded;

    public bool success; // was the user action successful or not
    public List<ObjectUserRoles> userRoles;

    public DUser()
    {

    }
}

public enum UserUpdateType
{
    LAST_LOGIN = 1,
    PASSWORD = 2,
    ADMIN = 3,
    DELETED = 4,
    LOCKED = 5,
    ROLES = 6,
    USAN_USER = 7
}

public enum UserAuditAction
{
    CREATE_USER = 1,
    DELETE_USER = 2,
    UPDATE_USER = 3,

    FAILED_LOGIN = 7,
    LOGIN = 8,
    CHANGE_USER_ROLE = 9,
    CREATE_CONFIGURATION = 10,
    EDIT_CONFIGURATION = 11,
    COPY_CONFIGURATION = 12,
    DELETE_CONFIGURATION = 13,

    UPDATE_CONFIGURATION_ORDER = 14,

    CHANGE_PASSWORD = 15,
    RESET_PASSWORD = 16
}