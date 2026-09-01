using System;

/// <summary>
/// Summary description for ObjectHistory
/// </summary>
public class ObjectHistory
{
    public int auditId;
    public int affectedUserId;
    public string affectedUserName;
    public int performerUserId;
    public string performerUserName;
    public int actionId;
    public string action;
    public DateTime actionTime;
    public string afterValue;

    public ObjectHistory()
    {

    }
}