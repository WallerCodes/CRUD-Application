using System;
//using MySql.Data.MySqlClient;

/// <summary>
/// Holds query parameter information
/// </summary>
public class UsanParameter
{
    public string TableName;
    public string ParamName;
    public string ColumnName;
    public object ParamValue;
    public UsanParameterAction ParamAction;
    public UsanParameterType ParamType;


    public UsanParameter(string name, object value, UsanParameterType type = UsanParameterType.EQUAL, string tableName = "", UsanParameterAction action = UsanParameterAction.WHERE)
    {

        this.ParamName = name;
        this.ColumnName = name;
        if (name == "index")
        {
            this.ParamName = "index2";
        }
        var dotIndex = name.IndexOf(".");
        if (dotIndex > 0 && dotIndex < name.Length - 1)
        {
            this.ParamName = name.Substring(dotIndex + 1);
        }
        if (value is bool)
        {
            bool bitValue = (bool)value;
            if (bitValue)
            {
                this.ParamValue = 1;
            }
            else
            {
                this.ParamValue = 0;
            }
        }
        else
        {
            // is nullable?
            if (value != null)
            {
                var valType = value.GetType();
                if (Nullable.GetUnderlyingType(valType) != null)
                {
                    // It's nullable
                    if (value == null)
                    {
                        this.ParamValue = DBNull.Value;
                    }
                    else
                    {
                        this.ParamValue = value;
                    }
                }
                else
                {
                    this.ParamValue = value;
                }
            }
            else
            {
                this.ParamValue = DBNull.Value;
            }


        }

        this.ParamType = type;
        this.TableName = tableName;
        this.ParamAction = action;
    }
}

public enum UsanParameterAction
{
    WHERE = 0,
    SET = 1
}
public enum UsanParameterType
{
    NOT_EQUAL = 0,
    EQUAL = 1,
    LIKE_ALL = 2,
    LIKE_START = 3,
    LIKE_END = 4,
    IN_ARRAY = 5,
    EQUAL_OR_NULL = 6,
    EQUAL_AND_NOTNULL = 7,
    LIKE_IGNORECASE = 8,
    LESS_THAN_EQUAL = 9,
    GREATER_THAN_EQUAL = 10,
    NOT_LIKE_ALL = 11,
    IS_NOT_NULL = 12,
    IS_NULL = 13
}

public enum UsanJoinType
{
    INNER = 0,
    FULL_OUTER = 1,
    LEFT_OUTER = 2,
    RIGHT_OUTER = 3,
    CROSS = 4
}