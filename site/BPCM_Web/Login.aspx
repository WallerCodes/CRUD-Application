<%@ Page Language="C#" AutoEventWireup="true" Inherits="BPCM.LandingPage" %>

<!DOCTYPE html>

<html>
<head>
    <title>Bypass | USAN</title>
    <link rel="icon" type="image/png" href="./public/images/favicon.ico">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">

    <!-- Library CSS -->
    <!--<script src="sweetalert2.min.js"></script>
    <link rel="stylesheet" href="sweetalert2.min.css"/>-->

    <!-- USAN Custom CSS -->
    <!--<link rel="stylesheet" href="./public/css/allinone-min.css"/>-->

    <link rel="stylesheet" href="./public/css/overrides.css" />
    <link rel="stylesheet" href="./public/css/main.css" />

    <!-- Library JS -->
    <script src="./public/js/jquery.js" type="text/javascript" defer></script>

    <!--script src="./public/js/sweet-alert-min.js"></!--script-->
    <script src="./public/js/sweetalert2.all.min.js"></script>

    <script src="./public/libs/datatables/datatables.js" type="text/javascript" defer></script>
    <script src="./public/js/libs/materialize.js" type="text/javascript" defer></script>
    <!-- USAN JS -->
    <!--<script src="./public/js/allinone-min.js?rnd=001" type="text/babel"></script>-->
    <script src="./public/js/global.js" type="text/javascript" defer></script>
    <script src="./public/js/sha256.js" type="text/javascript" defer></script>
    <script src="./public/js/login.js" type="text/javascript" defer></script>

</head>
<body style="overflow: hidden;">
    <div class="wrapper">
        <div class="container">
            <form class="form">
                <img style="margin-bottom: -10px;" src="./public/images/USAN-Logo-White.svg" width="270" height="130" alt="Error loading logo." />
                <input class="Email" type="text" placeholder="Email" onfocusout="validateEmail('.Email')" required />
                <input class="Password" type="password" placeholder="Password" required />
                <button onclick="validateEmailPassword()" class="submit-login" type="submit" id="login-button">Login</button>
                <br />
            </form>
            <ul class="bg-bubbles">
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
            </ul>
        </div>
    </div>
    <script type="text/javascript" language="javascript">
        var frenchSupportedAppsStr = '<%= System.Configuration.ConfigurationManager.AppSettings["FrenchSupportedApps"].ToString() %>';
        var frenchSupportedApps = frenchSupportedAppsStr.split(",");

        localStorage.setItem('frenchSupportedApps', frenchSupportedApps);

        var sessionTimer = '<%= System.Configuration.ConfigurationManager.AppSettings["SessionTimeout"].ToString() %>';
        localStorage.setItem('sessionTimeout', sessionTimer);

    </script>

</body>
</html>
