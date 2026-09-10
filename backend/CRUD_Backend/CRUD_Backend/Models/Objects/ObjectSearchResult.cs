using System.Collections.Generic;

/// <summary>
/// Summary description for ObjectSearchResult
/// </summary>
public class ObjectSearchResult<T>
{
    public List<T> rows;
    public int total;

    public ObjectSearchResult()
    {

    }
}