namespace CRUD_Backend.Models.DbEntities;

using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

/// <summary>
/// Note: 
/// User properties (getters and setters) rather than fields. 
/// Serializer will not pick up fields by default -> empty objects will be returned from API calls
/// </summary>
[Serializable]
[Table("users", Schema = "crud")]
public class DUsers
{
    public static readonly string USER_SESSION_KEY = "user_object";

    [Key]
    [Column("userId")]
    public int UserId { get; set; }

    public string Username { get; set; }

    [Column("password")]
    public string Password { get; set; }

    [Column("deleted")]
    public bool IsDeleted { get; set; }

    [Column("disabled")]
    public bool Disabled { get; set; }

    [Column("isSuperAdmin")]
    public bool IsSuperAdmin { get; set; }

    [Column("isUsanUser")]
    public bool IsUsanUser { get; set; }

    [Column("locked")]
    public bool IsLocked { get; set; }

    [Column("failedLoginAttempts")]
    public short FailedLoginAttempts { get; set; }

    [Column("forceChangePassword")]
    public bool ForceChangePassword { get; set; }

    [Column("lastLoginDate")]
    public DateTime? LastLoginDate { get; set; }

    [Column("lastPasswordChangeDate")]
    public DateTime? LastPasswordChangeDate { get; set; }

    [Column("dateAdded")]
    public DateTime? DateAdded { get; set; }

    public DUsers()
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

