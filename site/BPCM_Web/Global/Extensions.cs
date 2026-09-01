using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace BPCM_Web.Global
{
    public static class Extensions
    {
        public static string NullIfWhiteSpace(this string value)
        {
            if (String.IsNullOrWhiteSpace(value)) { return null; }
            return value;
        }
    }
}