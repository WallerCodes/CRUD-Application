public class ObjectUserRoles
{
    public static readonly string None = "None";
    public static readonly string Read = "View";
    public static readonly string Edit = "Edit";
    public static readonly string Admin = "Update Users";

    public string userName;
    public string application;
    public bool accessLevelNone;
    public bool accessLevelRead;
    public bool accessLevelEdit;
    public bool accessLevelAdmin;

    public ObjectUserRoles()
    {
        accessLevelNone = true;
    }
}
