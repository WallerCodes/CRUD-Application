<%@ Page Language="C#" MasterPageFile="./MasterPage.master" AutoEventWireup="true" Inherits="Admin" Title="Admin | BPCM" %>

<%@ MasterType VirtualPath="./MasterPage.master" %>


<asp:Content ID="CustomCSS_Admin" ContentPlaceHolderID="CustomCSS" runat="Server">
    <%: System.Web.Optimization.Styles.Render("~/bundles_css/admin") %>
</asp:Content>

<asp:Content ID="CustomJS_Admin" ContentPlaceHolderID="CustomJS" runat="Server">
    <%: System.Web.Optimization.Scripts.Render("~/bundles_js/admin") %>
</asp:Content>

<asp:Content ID="MainContent_Admin" ContentPlaceHolderID="MainContent" runat="Server">
    <div class="row site-heading" style="margin-bottom: 0px;">
        <span class='u-sitename'>User Provisioning</span>
    </div>
    <div class="row">
        <div class="col s12">
            <div id="u-filters" class="card">
                <div id="u-admin-nav" style="text-align: center;">
                    <ul style="border-radius: 10px 10px 0px 0px;" class="tabs tabs-transparent">
                        <li class="tab"><a class="active" onclick="openAdminTab('users')">Users</a></li>
                        <li class="tab"><a class="" onclick="openAdminTab('history')">History</a></li>
                    </ul>
                </div>
                <div id="u-admin-users" class="u-admin-panel">
                    <div class="row" style="margin-bottom: 15px;">
                        <i style="float: right; margin-right: 0.5em; font-size: 2.2em;" title="Reset Basic Filters" id="u-resetBasicFilters-users-btn" class="material-icons u-filter-reset tooltipped" data-position="bottom" data-tooltip="Reset General Filters">cached</i>
                    </div>
                    <div class="row" id="u-users-window">
                        <!-- <span class="uPanelTitle"><span>Users</span></span> -->
                        <div class="row u-toolbar-row">
                            <div class="col s4">
                                <a id="open-add-user" class="waves-effect waves-light btn"><i class="material-icons left">person_add</i>Add User</a>
                            </div>
                            <div id="email-honeypot" class="input-field col s4 u-cf-field">
                                <input type="search" id="u-user-form-userName" autocomplete="off" class="autocomplete">
                                <label for="u-user-form-userName">Email</label>
                            </div>
                            <div class="input-field col s4 u-cf-field" style="margin-top: -0.3em; margin-left: 3em;">
                                <input type="search" id="u-user-form-username" autocomplete="off" class="autocomplete">
                                <label for="u-user-form-username">Search User Name</label>
                            </div>
                        </div>
                    </div>
                </div>
                <div style="display: none" id="u-admin-history" class="u-admin-panel">
                    <div class="row" style="margin-bottom: 15px;">
                        <i style="float: right; margin-right: 0.5em; font-size: 2.2em;" title="Reset Basic Filters" id="u-resetBasicFilters-history-btn" class="material-icons u-filter-reset tooltipped" data-position="bottom" data-tooltip="Reset General Filters">cached</i>
                    </div>
                    <div class="row" id="u-history-window">
                        <!--<span class="uPanelTitle"><span>Users</span></span>-->
                        <div class="row u-toolbar-row">
                            <div class="input-field col s3 u-cf-field">
                                <input type="search" id="u-history-form-user-performer" autocomplete="off" class="autocomplete">
                                <label for="u-history-form-user-performer">Performing User</label>
                            </div>
                            <div class="input-field col s3 u-cf-field">
                                <input type="search" id="u-history-form-user-affected" autocomplete="off" class="autocomplete">
                                <label for="u-history-form-user-affected">Affected User</label>
                            </div>
                            <div class="input-field col s3 offset-s1 u-cf-field ">
                                <input type="search" id="u-history-form-begin-date" class="autocomplete" autocomplete="off">
                                <label for="u-history-form-begin-date">From Date</label>
                            </div>
                            <div class="input-field col s2 u-cf-field ">
                                <input type="search" id="u-history-form-begin-time" class="autocomplete" autocomplete="off">
                                <label for="u-history-form-begin-time">From Time</label>
                            </div>
                        </div>
                        <div class="row u-toolbar-row">
                            <div class="input-field col s6 u-cf-field ">
                                <input style="width: 96%;" type="search" id="u-history-form-action" autocomplete="off" class="autocomplete">
                                <label for="u-history-form-action">Action</label>
                            </div>
                            <div class="input-field col s3 offset-s1 u-cf-field ">
                                <input type="search" id="u-history-form-end-date" class="autocomplete" autocomplete="off">
                                <label for="u-history-form-end-date">To Date</label>
                            </div>
                            <div class="input-field col s2 u-cf-field ">
                                <input type="search" id="u-history-form-end-time" class="autocomplete" autocomplete="off">
                                <label for="u-history-form-end-time">To Time</label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="u-admin-users-table" class="row">
                <div class="card material-table">
                    <table id="users-datatable">
                    </table>
                </div>
            </div>
            <div style="display: none" id="u-admin-history-table" class="row">
                <div class="card material-table">
                    <table id="history-datatable">
                        <thead>
                            <tr>
                                <th>Timestamp</th>
                                <th>Performing User</th>
                                <th>Affected User</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                    </table>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

