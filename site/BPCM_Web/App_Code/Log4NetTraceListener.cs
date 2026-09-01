using log4net;
using System.Diagnostics;

/// <summary>
/// Summary description for Log4NetTraceListener
/// </summary>
namespace BPCM
{
    public class Log4NetTraceListener : TraceListener
    {
        private ILog log = LogManager.GetLogger("DebugTrace");

        public override void Write(string message)
        {
            //log.Debug(message);
        }

        public override void WriteLine(string message)
        {
            log.Debug(message);
        }
    }
}