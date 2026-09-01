using log4net;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
//using MySql.Data.MySqlClient;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web.Configuration;

namespace BPCM
{
    /// <summary>
    /// Represents unified MySqlCommand or SqlCommand
    /// </summary>
    public class UsanCommand : IDisposable
    {
        public static string CONN_STR = WebConfigurationManager.ConnectionStrings["connectionString"].ToString();

        protected ILog log;

        public bool IsMySQL = false;

        //    public DbCommand Command { get; private set; }
        private DbCommand _command;
        private DbTransaction _transaction;

        public DbCommand Command
        {
            get { return this._command; }
        }
        public UsanCommandType CommandType;
        public string TableName;
        public string SecondTableName;
        public int Limit;
        public string Order;
        public bool OrderAsc = true;
        public List<UsanParameter> SimpleParams;
        public List<UsanTableJoin> Joins;
        public string manualParams;
        public string IDColumn;
        public List<string> GroupByList;
        public List<string> SelectVarsList;
        public int Offset;
        public int FetchNext;
        public string DB_NAME;
        public string NOW_DATE = "GETDATE()";
        public bool SelectDistinct = false;
        private bool disposedValue;

        public UsanCommand(string tableName, UsanCommandType type, string secondTable = "")
        {
            log = LogManager.GetLogger(GetType());
            EstablishConnection(CONN_STR, tableName, type, secondTable);
        }

        private void EstablishConnection(string conn, string tableName, UsanCommandType type, string secondTable = "")
        {
            // is it MySQL?
            var dbKey = "";
            this.IsMySQL = DBTools.IsMySQL();
            /*if (this.IsMySQL)
            {
                dbKey = "database";
                _command = new MySqlCommand();
            }
            else
            {*/
            dbKey = "initial catalog";
            _command = new SqlCommand();
            //}

            // is it extdb?
            DbConnectionStringBuilder cns = new DbConnectionStringBuilder();
            cns.ConnectionString = conn.ToString();
            foreach (var key in cns.Keys)
            {
                if (key.ToString().ToLowerInvariant().Trim() == dbKey)
                {
                    DB_NAME = cns[key.ToString()].ToString();
                    break;
                }
            }

            if (type == UsanCommandType.MANUAL)
            {
                this.TableName = "";
                this.CommandText = tableName;
            }

            this.TableName = tableName;
            this.SecondTableName = secondTable;
            this.CommandType = type;
            SimpleParams = new List<UsanParameter>();
            Joins = new List<UsanTableJoin>();



            GroupByList = new List<string>();
            SelectVarsList = new List<string>();

            // create connection
            /*if (this.IsMySQL)
            {
                this.Connection = new MySqlConnection(conn.ToString());

            }
            else
            {*/
            // MSSQL
            this.Connection = new SqlConnection(conn.ToString());
            //}
        }

        public void CloseConnection()
        {
            try
            {
                this.Connection.Close();
                this.Connection.Dispose();
            }
            catch (Exception ex)
            {
                log.Error("Error in UsanCommand.CloseConnection: " + ex);
            }
        }

        public DbTransaction BeginTransaction()
        {
            try
            {
                if (this.Connection.State != ConnectionState.Open)
                {
                    this.Connection.Open();
                }
            }
            catch (Exception ex)
            {
                log.Error("Error in UsanCOmmand.BeginTransaction: " + ex);
            }

            return this.Connection.BeginTransaction();
        }

        public DbTransaction Transaction
        {
            get
            {
                return this._transaction;
            }

            set
            {
                this._command.Transaction = value;
                _transaction = value;
            }
        }

        public string CommandText
        {
            get
            {
                return this._command.CommandText;
            }

            set
            {
                _command.CommandText = value;
            }
        }

        public DbConnection Connection
        {
            get
            {
                return this._command.Connection;
            }

            set
            {
                _command.Connection = value;
            }
        }
        public void AddGroupByField(string groupBy)
        {
            GroupByList.Add(groupBy);
        }

        // solves the problem with repeat parameter name
        public UsanParameter EnsureUniqueParameter(UsanParameter param)
        {
            // do we have a parameter with the same name?
            var repeatFound = false;
            for (var a = 0; a < SimpleParams.Count; a++)
            {
                if (SimpleParams[a].ParamName == param.ParamName)
                {
                    param.ParamName = param.ParamName + "1";
                    repeatFound = true;
                }
            }
            if (repeatFound)
            {
                return EnsureUniqueParameter(param);
            }
            return param;
        }
        public void AddSearchParameter(UsanParameter param)
        {

            param = EnsureUniqueParameter(param);

            SimpleParams.Add(param);
            bool skipAddingParam = false;
            if (param.ParamType == UsanParameterType.LIKE_ALL)
            {
                param.ParamValue = "%" + param.ParamValue + "%";
            }
            else if (param.ParamType == UsanParameterType.LIKE_END)
            {
                param.ParamValue = param.ParamValue + "%";
            }
            else if (param.ParamType == UsanParameterType.LIKE_START)
            {
                param.ParamValue = "%" + param.ParamValue;
            }
            else if (param.ParamType == UsanParameterType.IN_ARRAY)
            {
                skipAddingParam = true;
                List<string> list = ((string)param.ParamValue).Split(',').ToList();
                string paramValue = "";
                for (int a = 0; a < list.Count; a++)
                {
                    string paramName = param.ParamName + a;
                    if (a > 0) paramValue = paramValue + ",";
                    paramValue = paramValue + "@" + paramName;
                    AddParameter(paramName, list[a]);
                }
                param.ParamValue = paramValue;
            }

            if (!skipAddingParam)
            {
                AddParameter(param.ParamName, param.ParamValue);
            }

        }

        public void AddParameterList(List<UsanParameter> parameters)
        {
            foreach (var param in parameters)
            {
                AddSearchParameter(param);
            }
        }

        public void AddJoin(UsanTableJoin join)
        {
            Joins.Add(join);
        }

        public void AddParameter(string name, object value)
        {
            if (!name.StartsWith("@"))
            {
                name = "@" + name;
            }
            if (value == null)
            {
                value = "";
            }
                /*if (this.IsMySQL)
                {
                    ((MySqlCommand)_command).Parameters.AddWithValue(name, value);
                }
                else
                {*/
                ((SqlCommand)_command).Parameters.AddWithValue(name, value);
            //}
        }


        public void AddParameter(string name, object value, string type, SqlDbType sqlDbType)
        {
            if (!name.StartsWith("@"))
            {
                name = "@" + name;
            }

            SqlParameter sqlParam = ((SqlCommand)_command).Parameters.AddWithValue(name, value);
            sqlParam.SqlDbType = sqlDbType;

            sqlParam.TypeName = type;
        }

        public void AddParameter(SqlParameter sqlParam)
        {

            ((SqlCommand)_command).Parameters.Add(sqlParam);
        }


        public string BuildQuery()
        {
            StringBuilder sb = new StringBuilder();
            if (CommandType == UsanCommandType.SELECT)
            {
                // figure out the Limit / Top
                string limitStr = "";
                string topStr = "";

                if (Limit > 0)
                {
                    if (IsMySQL)
                    {
                        limitStr = "LIMIT " + Limit;
                    }
                    else
                    {
                        topStr = "TOP " + Limit;
                    }
                }

                var offsetFetchStr = "";
                if (FetchNext > 0)
                {
                    if (IsMySQL)
                    {
                        //todo implement for mysql <- not sure if this works
                        limitStr = "LIMIT " + Offset + "," + FetchNext + " ";
                    }
                    else
                    {
                        offsetFetchStr = " OFFSET " + Offset + " ROWS FETCH NEXT " + FetchNext + " ROWS ONLY ";
                    }
                }
                string leftSeparator = "[";
                string rightSeparator = "]";
                if (IsMySQL)
                {
                    leftSeparator = "`";
                    rightSeparator = "`";
                }
                string selectVars = "*";
                if (SelectVarsList.Count > 0)
                {
                    selectVars = "";
                    for (var a = 0; a < SelectVarsList.Count; a++)
                    {
                        if (a > 0)
                        {
                            selectVars += ",";
                        }

                        var thisVar = SelectVarsList[a];
                        if (thisVar.Contains("(") || thisVar.Contains("*"))
                        {
                            selectVars += thisVar;
                        }
                        else if (thisVar.Contains("."))
                        {
                            var split = thisVar.Split('.');
                            if (split.Length == 2)
                            {
                                selectVars += split[0] + "." + leftSeparator + split[1] + rightSeparator;
                            }
                            else
                            {
                                selectVars += thisVar;
                            }
                        }
                        else
                        {
                            selectVars += leftSeparator + thisVar + rightSeparator;
                        }
                        //selectVars = leftSeparator + SelectVarsList.Join(rightSeparator + "," + leftSeparator) + rightSeparator;
                    }
                }

                if (SelectDistinct)
                {
                    sb.AppendFormat("SELECT DISTINCT {0} {1} FROM {2} ", topStr, selectVars, TableName);
                }
                else
                {
                    sb.AppendFormat("SELECT {0} {1} FROM {2} ", topStr, selectVars, TableName);
                }


                for (int a = 0; a < Joins.Count; a++)
                {
                    var thisJoin = Joins[a];
                    var joinTypeStr = "";
                    switch (thisJoin.JoinType)
                    {
                        case UsanJoinType.INNER:
                            joinTypeStr = "INNER";
                            break;
                        case UsanJoinType.FULL_OUTER:
                            joinTypeStr = "FULL OUTER";
                            break;
                        case UsanJoinType.LEFT_OUTER:
                            joinTypeStr = "LEFT OUTER";
                            break;
                        case UsanJoinType.RIGHT_OUTER:
                            joinTypeStr = "RIGHT OUTER";
                            break;
                        case UsanJoinType.CROSS:
                            joinTypeStr = "CROSS";
                            break;
                    }
                    if (thisJoin.SubQuery == null)
                    {
                        sb.AppendFormat("{0} JOIN {1} on {1}.{2} = {3}.{4} ", joinTypeStr, thisJoin.JoinTable, thisJoin.JoinColumn, thisJoin.MainTable, thisJoin.MainColumn);
                    }
                    else
                    {
                        // gotta move parameters from subquery into the main query
                        for (int t = 0; t < thisJoin.SubQuery.SimpleParams.Count; t++)
                        {
                            AddParameter(thisJoin.SubQuery.SimpleParams[t].ParamName, thisJoin.SubQuery.SimpleParams[t].ParamValue);
                        }
                        sb.AppendFormat("{0} JOIN ({1}) as {2} on {2}.{3} = {4}.{5} ", joinTypeStr, thisJoin.SubQuery.BuildQuery(), thisJoin.JoinTable, thisJoin.JoinColumn, thisJoin.MainTable, thisJoin.MainColumn);
                    }

                }

                // figure out parameters
                if (!string.IsNullOrEmpty(manualParams))
                {
                    sb.Append(manualParams);
                }
                else
                {
                    if (SimpleParams.Count > 0)
                    {
                        sb.Append(" WHERE ");
                        for (int a = 0; a < SimpleParams.Count; a++)
                        {
                            var param = SimpleParams[a];
                            string andStr = "";
                            if (a > 0) andStr = " AND ";
                            sb.AppendFormat("{0} {1}", andStr, getParamString(param));
                        }
                    }
                }

                // any group by
                if (GroupByList.Count > 0)
                {
                    sb.Append(" GROUP BY ");
                    for (int a = 0; a < GroupByList.Count; a++)
                    {
                        if (a > 0)
                        {
                            sb.Append(",");
                        }
                        sb.Append(GroupByList[a]);
                    }
                }


                // figure out the order
                string orderStr = "";
                if (!string.IsNullOrEmpty(Order))
                {
                    orderStr = "order by " + Order;
                    if (OrderAsc)
                    {
                        orderStr = orderStr + " ASC";
                    }
                    else
                    {
                        orderStr = orderStr + " DESC";
                    }
                    sb.Append(" " + orderStr);
                }

                if (!string.IsNullOrEmpty(offsetFetchStr))
                {
                    sb.Append(offsetFetchStr);
                }

                // finish
                sb.Append(" " + limitStr);
            }
            else if (CommandType == UsanCommandType.INSERT)
            {
                string paramNames = "";
                string values = "";
                if (SimpleParams.Count > 0)
                {
                    for (int a = 0; a < SimpleParams.Count; a++)
                    {
                        var param = SimpleParams[a];
                        if (a > 0)
                        {
                            paramNames = paramNames + ",";
                            values = values + ",";
                        }
                        paramNames = paramNames + "[" + param.ColumnName + "]";
                        values = values + " " + printParamValue(param);
                    }

                }
                else
                {
                    throw new Exception("Missing parameters");
                }

                if (string.IsNullOrEmpty(IDColumn))
                {
                    sb.AppendFormat("INSERT INTO {0} ({1}) VALUES ({2})", TableName, paramNames, values);
                }
                else
                {
                    if (IsMySQL)
                    {
                        sb.AppendFormat("INSERT INTO {0} ({1}) VALUES ({2}); SELECT LAST_INSERT_ID();", TableName, paramNames, values);
                    }
                    else
                    {
                        sb.AppendFormat("INSERT INTO {0} ({1}) OUTPUT INSERTED.{2} VALUES ({3})", TableName, paramNames, IDColumn, values);
                    }
                }
            }
            else if (CommandType == UsanCommandType.PROCEDURE)
            {
                string values = "";
                if (SimpleParams.Count > 0)
                {
                    for (int a = 0; a < SimpleParams.Count; a++)
                    {
                        var param = SimpleParams[a];
                        if (a > 0)
                        {
                            values = values + ",";
                        }
                        values = values + " " + printParamValue(param);
                    }
                }
                // Comment this back in when done, every SP will have params most likely...
                //else
                //{
                //    //if (!allowNoSimpleParams)
                //    throw new Exception("Missing parameters");
                //}

                if (this.IsMySQL)
                {
                    sb.AppendFormat("CALL `{0}` ({1})", TableName, values);
                }
                else
                {
                    sb.AppendFormat("EXEC {0} {1}", TableName, values);
                }

            }
            else if (CommandType == UsanCommandType.DROP)
            {
                sb.AppendFormat("DROP TABLE {0}", TableName);
            }
            else if (CommandType == UsanCommandType.RENAME)
            {
                sb.AppendFormat("RENAME TABLE {0} TO {1}", TableName, SecondTableName);
            }
            else if (CommandType == UsanCommandType.MANUAL)
            {
                sb.AppendFormat("{0}", CommandText);
            }
            else if (CommandType == UsanCommandType.DELETE)
            {
                StringBuilder searchParams = new StringBuilder();
                if (SimpleParams.Count > 0)
                {
                    for (int a = 0; a < SimpleParams.Count; a++)
                    {
                        var param = SimpleParams[a];
                        string andStr = "";
                        if (a > 0) andStr = " AND ";
                        searchParams.AppendFormat("{0} {1}", andStr, getParamString(param));
                    }

                }
                else
                {
                    throw new Exception("Missing set parameters");
                }

                sb.AppendFormat("DELETE FROM {0} WHERE {1}", TableName, searchParams.ToString());
            }
            else if (CommandType == UsanCommandType.UPDATE)
            {
                string setValues = "";
                string whereValues = "";
                if (SimpleParams.Count > 0)
                {
                    for (int a = 0; a < SimpleParams.Count; a++)
                    {
                        var param = SimpleParams[a];
                        //                    if (param.ParamName != IDColumn)
                        if (param.ParamAction == UsanParameterAction.SET)
                        {
                            if (!string.IsNullOrEmpty(setValues))
                            {
                                setValues = setValues + ", ";
                            }
                            setValues = setValues + "[" + param.ColumnName + "] = " + printParamValue(param);
                        }
                        else
                        {
                            if (!string.IsNullOrEmpty(whereValues))
                            {
                                whereValues = whereValues + " AND ";
                            }
                            whereValues = whereValues + "[" + param.ColumnName + "] = " + printParamValue(param);

                        }

                    }

                }
                else
                {
                    throw new Exception("Missing set parameters");
                }
                if (string.IsNullOrEmpty(whereValues))
                {
                    throw new Exception("Update querty is missing an ID column");
                }

                //IDColumn remove and fix all errors
                sb.AppendFormat("UPDATE {0} SET {1} WHERE {2}", TableName, setValues, whereValues);
            }

            if (this.IsMySQL)
            {

                sb = sb.Replace("[", "`");
                sb = sb.Replace("]", "`");
                sb = sb.Replace("GETDATE()", "NOW()");
                sb = sb.Replace("IDENTITY", "AUTO_INCREMENT");
            }
            return sb.ToString();
        }

        public string printParamValue(UsanParameter param)
        {
            if (param.ParamValue is string && ((string)param.ParamValue) == "GETDATE()")
            {
                if (this.IsMySQL)
                {
                    param.ParamValue = "NOW()";
                }
                return (string)param.ParamValue;
            }
            return "@" + param.ParamName;
        }

        public string printParamName(string name)
        {
            var dotIndex = name.IndexOf(".");
            if (dotIndex > 0 && dotIndex < name.Length - 1)
            {
                return name.Substring(0, dotIndex) + ".[" + name.Substring(dotIndex + 1) + "]";
            }
            return "[" + name + "]";
        }

        public string getParamString(UsanParameter param)
        {
            string paramString = "";
            string paramName = param.ColumnName;
            if (!string.IsNullOrEmpty(param.TableName))
            {
                paramName = param.TableName + "." + paramName;
            }
            if (param.ParamType == UsanParameterType.EQUAL)
            {
                paramString = printParamName(paramName) + " = " + printParamValue(param);
            }
            else if (param.ParamType == UsanParameterType.LIKE_IGNORECASE)
            {
                paramString = "upper(" + paramName + ") LIKE upper(@" + param.ParamName + ")";
            }
            else if (param.ParamType == UsanParameterType.LIKE_ALL)
            {
                paramString = printParamName(paramName) + " LIKE @" + param.ParamName;
            }
            else if (param.ParamType == UsanParameterType.NOT_LIKE_ALL)
            {
                paramString = printParamName(paramName) + "NOT LIKE @" + param.ParamName;
            }

            else if (param.ParamType == UsanParameterType.LIKE_END)
            {
                paramString = printParamName(paramName) + " LIKE @" + param.ParamName;
            }
            else if (param.ParamType == UsanParameterType.LIKE_START)
            {
                paramString = printParamName(paramName) + " LIKE @" + param.ParamName;
            }
            else if (param.ParamType == UsanParameterType.NOT_EQUAL)
            {
                paramString = printParamName(paramName) + " != @" + param.ParamName;
            }
            else if (param.ParamType == UsanParameterType.IN_ARRAY)
            {
                paramString = printParamName(paramName) + " IN (" + param.ParamValue + ")";
            }
            else if (param.ParamType == UsanParameterType.EQUAL_OR_NULL)
            {
                paramString = "(" + printParamName(paramName) + " = @" + param.ParamName + " OR " + paramName + " IS NULL)";
            }
            else if (param.ParamType == UsanParameterType.IS_NOT_NULL)
            {
                paramString = "(" + printParamName(paramName) + " IS NOT NULL)";
            }
            else if (param.ParamType == UsanParameterType.IS_NULL)
            {
                paramString = "(" + printParamName(paramName) + " IS NULL)";
            }
            else if (param.ParamType == UsanParameterType.LESS_THAN_EQUAL)
            {
                paramString = printParamName(paramName) + " <= " + printParamValue(param);
            }
            else if (param.ParamType == UsanParameterType.GREATER_THAN_EQUAL)
            {
                paramString = printParamName(paramName) + " >= " + printParamValue(param);
            }
            return paramString;
        }

        public DataTable GetDBTable(bool keepConnection = false)
        {
            try
            {
                if (this.Connection.State != ConnectionState.Open)
                {
                    this.Connection.Open();
                }

                var reader = this.ExecuteReader();
                var dt = new DataTable();
                dt.Load(reader);
                reader.Close();
                return dt;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (!keepConnection)
                {
                    this.Connection.Close();
                    this.Connection.Dispose();
                }
            }
        }

        public int GetDBScalar(bool keepConnection = false)
        {
            try
            {
                if (this.Connection.State != ConnectionState.Open)
                {
                    this.Connection.Open();
                }
                var obj = this.ExecuteScalar();

                return Convert.ToInt32(obj);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (!keepConnection)
                {
                    this.Connection.Close();
                    this.Connection.Dispose();
                }
            }
        }

        internal DbDataReader ExecuteReader()
        {
            if (this.Connection.State != ConnectionState.Open)
            {
                this.Connection.Open();
            }
            Command.CommandText = BuildQuery();
            //AUTools.WriteTestLog("   -sql(reader): " + Command.CommandText);
            /*if (this.IsMySQL)
            {
                return ((MySqlCommand)_command).ExecuteReader();
            }
            else
            {*/
            return ((SqlCommand)_command).ExecuteReader();
            //}
        }

        internal object ExecuteScalar()
        {
            Command.CommandText = BuildQuery();
            //AUTools.WriteTestLog("   -sql(scalar): " + Command.CommandText);
            /*if (this.IsMySQL)
            {
                return ((MySqlCommand)_command).ExecuteScalar();
            }
            else
            {*/
            return ((SqlCommand)_command).ExecuteScalar();
            //}
        }

        public int ExecuteNonQuery()
        {
            try
            {
                if (this.Connection.State != ConnectionState.Open)
                {
                    this.Connection.Open();
                }

                Command.CommandText = BuildQuery();
                //AUTools.WriteTestLog("   -sql(non-query): " + Command.CommandText);
                //if (DBTools.IsMySQL())
                /*{
                    // MySQL
                    ((MySqlCommand)_command).ExecuteNonQuery();
                }
                else
                {*/
                // MSSQL
                return ((SqlCommand)_command).ExecuteNonQuery();
                //}
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ExecuteNonQuery(bool keepConnection = false)
        {
            try
            {
                if (this.Connection.State != ConnectionState.Open)
                {
                    this.Connection.Open();
                }
                Command.CommandText = BuildQuery();
                //AUTools.WriteTestLog("   -sql(non-query): " + Command.CommandText);
                //if (DBTools.IsMySQL())
                /*{
                    // MySQL
                    ((MySqlCommand)_command).ExecuteNonQuery();
                }
                else
                {*/
                // MSSQL
                ((SqlCommand)_command).ExecuteNonQuery();
                //}
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (!keepConnection)
                {
                    this.Connection.Close();
                    this.Connection.Dispose();
                }
            }
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    // TODO: dispose managed state (managed objects)
                    this.CloseConnection();
                }

                // TODO: free unmanaged resources (unmanaged objects) and override finalizer
                // TODO: set large fields to null
                disposedValue = true;
            }
        }

        // // TODO: override finalizer only if 'Dispose(bool disposing)' has code to free unmanaged resources
        // ~UsanCommand()
        // {
        //     // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
        //     Dispose(disposing: false);
        // }

        public void Dispose()
        {
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }
    }

    public enum UsanCommandType
    {
        SELECT = 1,
        INSERT = 2,
        UPDATE = 3,
        DELETE = 4,
        PROCEDURE = 5,
        DROP = 6,
        RENAME = 7,
        MANUAL = 8
    }

    public class UsanTransaction
    {

    }
}