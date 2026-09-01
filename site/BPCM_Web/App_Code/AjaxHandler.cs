using log4net;
using System;
using System.Collections.Generic;
using System.Security;
using System.Web;
using System.Web.SessionState;

namespace BPCM
{
    public abstract class AjaxHandler : IHttpHandler, IRequiresSessionState
    {
        protected ILog log;

        public AjaxHandler()
        {
            log = LogManager.GetLogger(GetType());
        }

        public virtual void ProcessRequest(HttpContext context)
        {
            HttpRequest request = context.Request;
            HttpResponse response = context.Response;
            HttpSessionState session = context.Session;
            Dictionary<string, object> requestContext = new Dictionary<string, object>();

            string performerUserEmail = parseSingleParameter<string>(request, "performerUserEmail");

            try
            {
                BeforeProcessRequest(session, request, requestContext);

                DUser user = DBTools.GetFullUser(performerUserEmail);

                ProcessRequest(session, request, user, context);
            }
            catch (ArgumentException ae)
            {
                log.Error("Got exception processing request parameters " + request.RawUrl + ": " + ae.Message, ae);
                context.Response.StatusCode = 400;
                response.Write("Got exception processing request parameters " + request.RawUrl + ": " + ae.Message);
            }
            catch (SecurityException se)
            {
                log.Error("Got exception processing request " + request.RawUrl + ": " + se.Message, se);
                context.Response.StatusCode = 401;
                response.Write("Got exception processing request " + request.RawUrl + ": " + se.Message);
            }
            catch (Exception e)
            {
                log.Error("Got exception processing request " + request.RawUrl + ": " + e.Message, e);
                context.Response.StatusCode = 500;
                response.Write("Got exception processing request " + request.RawUrl + ": " + e.Message);
            }
            finally
            {
                AfterDataWritten(session, request, requestContext);
            }
        }

        protected virtual void AfterDataWritten(HttpSessionState session, HttpRequest request, Dictionary<string, object> context)
        {
        }

        protected virtual void BeforeProcessRequest(HttpSessionState session, HttpRequest request, Dictionary<string, object> context)
        {
        }

        public abstract object ProcessRequest(HttpSessionState session, HttpRequest request, DUser user, HttpContext context);



        public virtual bool IsReusable
        {
            get
            {
                return true;
            }
        }

        protected bool parseFlag(HttpRequest request, string name)
        {
            string value = request.Params[name];

            return (!string.IsNullOrEmpty(value) &&
               (value == "1" ||
               StringComparer.OrdinalIgnoreCase.Compare(value, "true") == 0 ||
               StringComparer.OrdinalIgnoreCase.Compare(value, "yes") == 0));
        }

        protected T parseSingleParameter<T>(HttpRequest request, string name, int maxLength)
        {
            return parseSingleParameter<T>(request, name, false, maxLength);
        }

        protected T parseSingleParameter<T>(HttpRequest request, string name)
        {
            return parseSingleParameter<T>(request, name, false, -1);
        }

        protected T parseSingleParameter<T>(HttpRequest request, string name, bool required)
        {
            return parseSingleParameter<T>(request, name, required, -1);
        }

        protected T parseSingleParameter<T>(HttpRequest request, string name, bool required, int maxLength)
        {
            T val = default(T);
            string value = request.Params[name];

            if (value != null)
            {

                try
                {
                    if (typeof(T).IsGenericType && typeof(T).GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
                    {
                        val = (T)Convert.ChangeType(value, typeof(T).GetGenericArguments()[0]);
                    }
                    else
                    {
                        val = (T)Convert.ChangeType(value, typeof(T));
                    }
                    if (maxLength >= 0 && val.ToString().Length > maxLength)
                    {
                        throw new ArgumentException("Request parameter " + name + " ('" + value + "') exceeds maximum allowed length " + maxLength + ".");
                    }
                }
                catch (InvalidCastException)
                {
                    throw new ArgumentException("Request parameter " + name + " ('" + value + "') contains an invalid value.");
                }
            }
            else if (required)
            {
                throw new ArgumentException("Request parameter " + name + " is required.");
            }

            return val;
        }

        protected List<T> parseParameter<T>(HttpRequest request, string name)
        {
            return parseParameter<T>(request, name, false, -1);
        }

        protected List<T> parseParameter<T>(HttpRequest request, string name, int maxLength)
        {
            return parseParameter<T>(request, name, false, maxLength);
        }

        protected List<T> parseParameter<T>(HttpRequest request, string name, bool required)
        {
            return parseParameter<T>(request, name, required, -1);
        }

        protected List<T> parseParameter<T>(HttpRequest request, string name, bool required, int maxLength)
        {
            List<T> values = new List<T>();
            string value = request.Params[name];

            if (value != null)
            {
                string[] els = value.Split(",".ToCharArray());
                foreach (string el in els)
                {
                    try
                    {
                        T v = (T)Convert.ChangeType(el, typeof(T));
                        values.Add(v);
                        if (maxLength >= 0 && v.ToString().Length > maxLength)
                        {
                            throw new ArgumentException("Request parameter " + name + " ('" + value + "') exceeds maximum allowed length " + maxLength + ".");
                        }
                    }
                    catch (InvalidCastException)
                    {
                        throw new ArgumentException("Request parameter " + name + " ('" + value + "') contains an invalid value ('" + el + "')");
                    }
                }
            }
            else if (required)
            {
                throw new ArgumentException("Request parameter " + name + " is required.");
            }

            return values;
        }

        protected void LogRequest(HttpRequest request)
        {
            log.Info("Got request: " + request.Path);
        }

        protected void logParameter(string name, string value)
        {
            if (name.ToLower().Contains("password"))
            {
                value = "{hidden}";
            }
            log.Debug(name + "=" + value);
        }

        protected virtual bool checkSecurity(DUser user)
        {
            return true;
        }

        public static string ReplaceFirstOccurrence(string Source, string Find, string Replace)
        {
            int Place = Source.IndexOf(Find);
            string result = Source.Remove(Place, Find.Length).Insert(Place, Replace);
            return result;
        }
    }
}