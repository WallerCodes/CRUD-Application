using System;
using System.Collections.Generic;

public class ObjectDataTableResponse<T>
{
    public bool success;
    public string recordsTotal;
    public string recordsFiltered;
    public string message;
    public Exception exception;
    public List<T> data;

    public ObjectDataTableResponse()
    {

    }
}
