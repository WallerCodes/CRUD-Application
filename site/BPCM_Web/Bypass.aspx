<%@ Page Language="C#" MasterPageFile="./MasterPage.master" AutoEventWireup="true" Inherits="Bypass" Title="Bypass" %>

<%@ MasterType VirtualPath="./MasterPage.master" %>


<asp:Content ID="CustomCSS_RTM" ContentPlaceHolderID="CustomCSS" runat="Server">
    <%: System.Web.Optimization.Styles.Render("~/bundles_css/bypass") %>
</asp:Content>

<asp:Content ID="CustomJS_RTM" ContentPlaceHolderID="CustomJS" runat="Server">
    <%: System.Web.Optimization.Scripts.Render("~/bundles_js/bypass") %>
</asp:Content>

<asp:Content ID="MainContent_RTM" ContentPlaceHolderID="MainContent" runat="Server">
    <div class="row site-heading" style="margin-bottom: 0px;">
        <span class='u-sitename'>Bypass Configuration</span>
    </div>
    <div class="row">
        <div class="col s12">
            <div id="u-filters" class="card">
                <div id="u-rtm" class="u-rtm-panel;" style="border-radius: 10px">
                    <div style="margin-bottom: 10px; background-color: #a9a9a9; text-align: center; font-size: 20px; color: white; border-radius: 10px 10px 0 0; padding: 10px 0;">
                        FILTERS
                    </div>
                    <div class="row" style="margin-bottom: 0px;">
                        <i style="cursor: pointer; float: right; margin-right: 0.5em; font-size: 2.2em;" title="Reset Basic Filters" id="u-bypass-resetBasicFilters-btn" class="material-icons u-filter-reset tooltipped" data-position="bottom" data-tooltip="Reset General Filters">cached</i>
                    </div>
                    <div class="row" style="margin-bottom: 0px;">
                        <div class="col s12">
                            <div class="u-container-left" style="padding: 10px 10px 1em 5em; margin-top: -10px;">
                                <div class="row">
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-bypass-form-application" autocomplete="off" class="autocomplete" readonly onfocus="this.removeAttribute('readonly');">
                                            <label class="filter-placeholder" for="u-bypass-form-application">Application</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-bypass-form-language" autocomplete="off" class="autocomplete" readonly onfocus="this.removeAttribute('readonly');">
                                            <label class="filter-placeholder" for="u-bypass-form-language">Language</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-bypass-form-dnis" autocomplete="off">
                                            <label class="filter-placeholder" for="u-bypass-form-dnis">DNIS (800-123-4567 or *)</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-bypass-form-destinationPhoneNumber" autocomplete="off">
                                            <label class="filter-placeholder" for="u-bypass-form-destinationPhoneNumber">Destination (123-456-7890 or *)</label>
                                        </div>
                                    </div>
                                    <div class="col s2">
                                        <div class="call-seq-input input-field">
                                            <input type="search" id="u-bypass-form-peg" autocomplete="off" dataType="alphanumeric">
                                            <label class="filter-placeholder" for="u-bypass-form-peg">Peg</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row" style="height: 60px;">
                    <div class="col s12">
                        <div class="u-container-left" style="padding: 0px 10px 1em 5em; margin-top: -10px;">
                            <div class="row">
                                <div class="col s2">
                                    <div class="call-seq-input input-field">
                                        <input type="search" id="u-bypass-form-rank" autocomplete="off">
                                        <label class="filter-placeholder" for="u-bypass-form-rank">Rank (1-6 or *)</label>
                                    </div>
                                </div>
                                <!-- Dummy field for email to be autofilled into by browser... -->
                                <div id="email-div" class="col s2" tabindex="-1">
                                    <div class="call-seq-input input-field">
                                        <input type="email" id="u-bypass-form-email" tabindex="-1">
                                        <label class="filter-placeholder" for="u-bypass-form-email">Email</label>
                                    </div>
                                </div>
                                <div class="col s2">
                                    <div class="call-seq-input input-field">
                                        <input type="search" id="u-bypass-form-offerId" autocomplete="off">
                                        <label class="filter-placeholder" for="u-bypass-form-offerId">Offer ID (12345678 or *)</label>
                                    </div>
                                </div>
                                <div class="col s2">
                                    <div class="call-seq-input input-field">
                                        <input type="search" id="u-bypass-form-offerType" autocomplete="off">
                                        <label class="filter-placeholder" for="u-bypass-form-offerType">OfferType (Citi Strata or *)</label>
                                    </div>
                                </div>
                                <div class="col s2">
                                    <div class="call-seq-input input-field">
                                        <input type="search" id="u-bypass-form-lastModifiedBy" autocomplete="off" class="autocomplete">
                                        <label class="filter-placeholder" for="u-bypass-form-lastModifiedBy">Last Modified By</label>
                                    </div>
                                </div>
                                <div class="col s2">
                                    <div class="call-seq-input input-field">
                                        <input type="search" id="u-bypass-form-lastModifiedDate" autocomplete="off">
                                        <label class="filter-placeholder" for="u-bypass-form-lastModifiedDate">Last Modified Date</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row" style="height: 20px; border-radius: 0 0 10px 10px; display: flex; justify-content: end">
                </div>
            </div>
        </div>
    </div>
    <div class="row" style="height: 60px; border-radius: 0 0 10px 10px" hidden>
        <a class="bypass-button" id="new-config-button">CREATE NEW CONFIGURATION</a>
    </div>
    <div id="u-rtm-main-table" class="row">
        <div class="card material-table">
            <div>                
                <i id="bypass-table-refresh-button" class="material-icons u-filter-reset tooltipped" title="Reset Basic Filters" data-position="bottom" data-tooltip="Reset General Filters">cached</i>
            </div>
            <table id="bypass-summary-datatable">
                <thead>
                    <tr>
                        <th></th>
                        <th></th>
                        <th>Application</th>
                        <th>Language</th>
                        <th>DNIS</th>
                        <th>Destination</th>
                        <th>Peg</th>
                        <th>Rank</th>
                        <th>Offer ID</th>
                        <th>Offer Type</th>
                        <th>Skill ID</th>
                        <th>Skill Name</th>
                        <th>Agents Available</th>
                        <th>MED</th>
                        <th>Overflow Skill ID</th>
                        <th>Overflow Skill</th>
                        <th>Overflow Agents Available</th>
                        <th>Overflow MED</th>
                        <th>Last Modified By</th>
                        <th>Last Modified Date</th>
                        <th></th>
                        <th></th>
                        <th></th>
                    </tr>
                </thead>
            </table>
        </div>
    </div>
</asp:Content>
