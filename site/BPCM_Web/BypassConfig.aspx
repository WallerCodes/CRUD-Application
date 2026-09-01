<%@ Page Language="C#" MasterPageFile="./MasterPage.master" AutoEventWireup="true" Inherits="BypassConfig" Title="Configuration | Bypass" %>

<%@ MasterType VirtualPath="./MasterPage.master" %>


<asp:Content ID="CustomCSS_Config" ContentPlaceHolderID="CustomCSS" runat="Server">
    <%: System.Web.Optimization.Styles.Render("~/bundles_css/Config") %>
</asp:Content>

<asp:Content ID="CustomJS_Config" ContentPlaceHolderID="CustomJS" runat="Server">
    <%: System.Web.Optimization.Scripts.Render("~/bundles_js/Config") %>
</asp:Content>

<asp:Content ID="MainContent_Config" ContentPlaceHolderID="MainContent" runat="Server">

    <div class="row site-heading" style="margin-bottom: 0px;">
        <span class='u-sitename'>Create Configuration</span>
    </div>
    <div class="row">
        <div class="col s12">
            <div id="u-filters" class="card">
                <div id="u-admin-nav" style="text-align: center;">
                    <ul style="border-radius: 10px 10px 0px 0px;" class="tabs tabs-transparent">
                    </ul>
                </div>
                <div class="row">
                    <i style="cursor: pointer; float: right; margin-right: 0.5em; font-size: 2.2em;" title="Reset Filters" id="u-bypassConfig-resetBasicFilters-btn" class="material-icons u-filter-reset tooltipped" data-position="bottom" data-tooltip="Reset General Filters">cached</i>
                </div>
                <div id="u-config-bypass" class="u-config-panel">
                    <div class="row" style="margin-bottom: 0px; margin-top: 5px; margin-left: 3em;">
                        <div class="col s12">
                            <div class="row" style="margin-bottom: 0px;"></div>
                            <div class="u-container-left" style="padding: 0px 10px 0px 10px; margin-top: -10px; margin-right: 1em;">
                                <div class="row" style="margin-bottom: 1.5em; z-index: 5;">
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-application" autocomplete="off" class="autocomplete" readonly onfocus="this.removeAttribute('readonly');" onblur="this.setAttribute('readonly', true);">
                                            <label for="u-config-form-application">Application</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-language" autocomplete="off" class="autocomplete" readonly onfocus="this.removeAttribute('readonly');" onblur="this.setAttribute('readonly', true);">
                                            <label for="u-config-form-language">Language</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-dnis" autocomplete="off">
                                            <label for="u-config-form-dnis">DNIS (800-123-4567 or *)</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-destination" autocomplete="off">
                                            <label for="u-config-form-destination">Destination (123-456-7890 or *)</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-peg" autocomplete="off" dataType="alphanumeric">
                                            <label for="u-config-form-peg">Peg</label>
                                        </div>
                                    </div>
                                </div>
                                <div class="row" style="margin-bottom: 1.5em;">
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-rank" autocomplete="off">
                                            <label for="u-config-form-rank">Rank (1-6 or *)</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-offerID" autocomplete="off">
                                            <label for="u-config-form-offerID">Offer ID (12345678 or *)</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-offerType" autocomplete="off">
                                            <label for="u-config-form-offerType">OfferType (Citi Strata or *)</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field" style="width: 98%">
                                            <input type="search" id="u-config-form-lastModifiedBy">
                                            <label for="u-config-form-lastModifiedBy">Last Modified By</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-lastModifiedDate">
                                            <label for="u-config-form-lastModifiedDate">Last Modified Date</label>
                                        </div>
                                    </div>
                                </div>
                                <div class="row" style="margin-bottom: 1.5em;">
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-skillName" autocomplete="off" dataType="alphanumeric">
                                            <label for="u-config-form-skillName">Skill Name</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-skillId" autocomplete="off">
                                            <label for="u-config-form-skillId">Skill ID</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-agentsAvailable" autocomplete="off">
                                            <label for="u-config-form-agentsAvailable">Agents Available (> or =)</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-medInSeconds" autocomplete="off">
                                            <label for="u-config-form-medInSeconds">MED in Seconds (< or =)</label>
                                        </div>
                                    </div>
                                </div>
                                <div class="row" style="margin-bottom: 1.5em;">
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-overflowSkillName" autocomplete="off" dataType="alphanumeric">
                                            <label for="u-config-form-overflowSkillName">Overflow Skill Name</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-overflowSkillId" autocomplete="off">
                                            <label for="u-config-form-overflowSkillId">Overflow Skill ID</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-overflowAgentsAvailable" autocomplete="off">
                                            <label for="u-config-form-overflowAgentsAvailable">Overflow Agents Available (> or =)</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-config-form-overflowMed" autocomplete="off">
                                            <label for="u-config-form-overflowMed">Overflow MED (< or =)</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div id="email-honeypot" class="call-seq-input input-field" autocomplete="off">
                                            <input type="search" id="u-config-form-email">
                                            <label for="u-config-form-email">Email</label>
                                        </div>
                                    </div>
                                </div>
                                <div class="row" style="margin-bottom: 1.5em; height: 60px">
                                    <a class="bypass-button" id="create-button">CREATE</a>
                                    <a href="./Bypass.aspx" class="bypass-button" id="cancel-button">CANCEL</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>


