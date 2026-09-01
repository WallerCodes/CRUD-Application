using System.Collections.Generic;
using System.Web.Optimization;

public class BundleConfig
{
    public static void RegisterBundles(BundleCollection bundles)
    {
        var cssBundleDefs = new Dictionary<string, List<string>>();
        var jsBundleDefs = new Dictionary<string, List<string>>();


        // Master
        cssBundleDefs.Add("master", new List<string> { "~/public/css/admin/overrides.css" });

        cssBundleDefs.Add("libs", new List<string> { "~/public/css/libs/materialize.min.css", "~/public/css/libs/fa_all.css", "~/public/libs/datatables/datatables.css" });

        jsBundleDefs.Add("master", new List<string> { "~/public/js/global.js" });

        jsBundleDefs.Add("libs", new List<string> { "~/public/js/sha256.js", "~/public/js/libs/materialize.js", "~/public/libs/datatables/datatables.js" });

        // Admin
        cssBundleDefs.Add("admin", new List<string> { "~/public/css/admin/admin.css" });
        jsBundleDefs.Add("admin", new List<string> { "~/public/js/bypass-admin.js" });

        // Bypass
        cssBundleDefs.Add("bypass", new List<string> { "~/public/css/admin/admin.css", "~/public/css/bypassPage.css" });
        jsBundleDefs.Add("bypass", new List<string> { "~/public/js/bypassPage.js" });

        // Config
        cssBundleDefs.Add("Config", new List<string> { "~/public/css/admin/admin.css", "~/public/css/configurationPage.css" });
        jsBundleDefs.Add("Config", new List<string> { "~/public/js/bypassConfigurationPage.js" });

        // EditOrCopyConfig
        cssBundleDefs.Add("EditOrCopyConfig", new List<string> { "~/public/css/admin/admin.css", "~/public/css/configurationPage.css" });
        jsBundleDefs.Add("EditOrCopyConfig", new List<string> { "~/public/js/editOrCopyConfiguration.js" });



        // add CSS bundles
        foreach (var pair in cssBundleDefs)
        {
            var bundle = new StyleBundle("~/bundles_css/" + pair.Key);
            for (var a = 0; a < pair.Value.Count; a++)
            {
                bundle.Include(pair.Value[a]);
            }
            bundles.Add(bundle);
        }

        // add JS bundles
        foreach (var pair in jsBundleDefs)
        {
            var bundle = new ScriptBundle("~/bundles_js/" + pair.Key);
            for (var a = 0; a < pair.Value.Count; a++)
            {
                bundle.Include(pair.Value[a]);
            }
            bundles.Add(bundle);
        }


        BundleTable.EnableOptimizations = true;
    }
}