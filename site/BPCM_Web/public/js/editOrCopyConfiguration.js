var performerUserEmail = '';

var userAccessLevel = 'None';
var document = '';

var editMode = false;

$(document).ready(function () {

    // Get search params of current url
    const currentUrl = window.location.href;
    const urlObject = new URL(currentUrl);
    const searchParams = new URLSearchParams(urlObject.search);

    setSiteTitle(searchParams);

    setFrameSize();

    performerUserEmail = localStorage.getItem('email');
    userAccessLevel = localStorage.getItem('accessLevel');

    document = this;

    checkRoles(performerUserEmail).then(function (data) {

        getFilterDropdownValues();

        fillParametersFromUrl(searchParams);

        setEventListeners();

        observeDropdowns();
    });

});

function setSiteTitle(searchParams) {

    // Get Page Title
    var siteTitle = document.querySelector('.u-sitename');

    const isEdit = searchParams.get('isEdit');
    if (isEdit == 'true') {
        siteTitle.textContent = 'Edit Configuration';
    }
    else {
        siteTitle.textContent = 'Copy Configuration';
    }
}

function fillParametersFromUrl(searchParams) {
    setInputValueAndActivate("u-config-form-application", "application", searchParams);
    setInputValueAndActivate("u-config-form-language", "language", searchParams);
    setInputValueAndActivate("u-config-form-dnis", "dnis", searchParams);
    setInputValueAndActivate("u-config-form-destination", "destination", searchParams);

    const application = searchParams.get('application')

    if (application == 'CRSCS') {

        // Rank
        const rankInput = document.getElementById('u-config-form-rank');
        rankInput.value = '-';
        rankInput.setAttribute('disabled', true);

        const rankLabel = document.querySelector(`label[for="u-config-form-rank"]`)
        rankLabel.classList.add('active');
        rankLabel.textContent = "Rank";

        // OfferID
        const offerIdInput = document.getElementById('u-config-form-offerID');
        offerIdInput.value = '-';
        offerIdInput.setAttribute('disabled', true);
        const offerIdInputLabel = document.querySelector(`label[for="u-config-form-offerID"]`)
        offerIdInputLabel.classList.add('active');
        offerIdInputLabel.textContent = "Offer ID";

        setInputValueAndActivate("u-config-form-offerType", "offerType", searchParams);
    }
    else if (application == 'BRANDSCS' || application == 'BANKCARDNRI') {    

        // OfferType
        const offerTypeInput = document.getElementById('u-config-form-offerType');
        offerTypeInput.value = '-';
        offerTypeInput.setAttribute('disabled', true);

        const offerTypeLabel = document.querySelector(`label[for="u-config-form-offerType"]`)
        offerTypeLabel.classList.add('active');
        offerTypeLabel.textContent = "Offer Type";

        setInputValueAndActivate("u-config-form-rank", "rank", searchParams);
        setInputValueAndActivate("u-config-form-offerID", "offerID", searchParams);
    }
    else {
        setInputValueAndActivate("u-config-form-rank", "rank", searchParams);
        setInputValueAndActivate("u-config-form-offerID", "offerID", searchParams);
        setInputValueAndActivate("u-config-form-offerType", "offerType", searchParams);
    }

    setInputValueAndActivate("u-config-form-peg", "peg", searchParams);

    setLastModifiedByAndDate();

    setInputValueAndActivate("u-config-form-skillId", "skillId", searchParams);
    setInputValueAndActivate("u-config-form-skillName", "skillName", searchParams);
    setInputValueAndActivate("u-config-form-agentsAvailable", "agentsAvailable", searchParams);
    setInputValueAndActivate("u-config-form-medInSeconds", "MED", searchParams);
    setInputValueAndActivate("u-config-form-overflowSkillId", "overflowSkillId", searchParams);
    setInputValueAndActivate("u-config-form-overflowSkillName", "overflowSkillName", searchParams);
    setInputValueAndActivate("u-config-form-overflowAgentsAvailable", "overflowAgentsAvailable", searchParams);
    setInputValueAndActivate("u-config-form-overflowMed", "overflowMED", searchParams);
}

// Grabs parameters from the url and inserts them into their respective fields
function setInputValueAndActivate(id, paramName, searchParams) {
    const inputField = document.getElementById(id);
    if (inputField && searchParams.has(paramName)) {
        inputField.value = searchParams.get(paramName);
        const inputLabel = document.querySelector(`label[for="${id}"]`);
        if (inputLabel && inputField.value != "") {
            inputLabel.classList.add('active');
        }
        if (paramName == 'application') {
            inputField.setAttribute('disabled', '');
        }
        if (paramName == 'dnis') {
            inputField.labels[0].textContent = "DNIS"
        }
        if (paramName == 'destination') {
            inputField.labels[0].textContent = "Destination"
        }
        if (paramName == 'rank') {
            inputField.labels[0].textContent = "Rank"
        }
        if (paramName == 'offerID') {
            inputField.labels[0].textContent = "Offer ID"
        }
        if (paramName == 'offerType') {
            inputField.labels[0].textContent = "Offer Type"
        }
    }
}

function setLastModifiedByAndDate() {

    // Set value for last modified by
    performerUserEmail = localStorage.getItem('email');

    const lastModifiedByInput = document.getElementById('u-config-form-lastModifiedBy');
    lastModifiedByInput.value = performerUserEmail;
    lastModifiedByInput.setAttribute('disabled', '');
    const lastModifiedByLabel = document.querySelector(`label[for="u-config-form-lastModifiedBy"]`);
    if (lastModifiedByLabel) {
        lastModifiedByLabel.classList.add('active');
    }

    // Set value for last modified date
    const today = new Date();

    const formattedDate = String(today.getMonth() + 1).padStart(2, '0') + '/'
        + String(today.getDate()).padStart(2, '0') + '/'
        + String(today.getFullYear()).slice(-2);

    const lastModifiedDateInput = document.getElementById('u-config-form-lastModifiedDate');
    lastModifiedDateInput.value = formattedDate;
    lastModifiedDateInput.setAttribute('disabled', '');
    const lastModifiedDateLabel = document.querySelector(`label[for="u-config-form-lastModifiedDate"]`);
    if (lastModifiedDateLabel) {
        lastModifiedDateLabel.classList.add('active');
    }
}

function observeDropdowns() {
    observeSpecificDropdown('u-config-form-language');
}

function observeSpecificDropdown(dropdownId) {
    // We are doing this because we still want the 'x' button for clearing but also want the fields to be readonly
    const applicationInput = document.getElementById(dropdownId);
    const parentElement = applicationInput.parentElement;
    //console.log(`edit apps list: ${editAppsList}`);
    var dropdown = applicationInput.parentElement.querySelector('.autocomplete-content.dropdown-content');

    const observer = new MutationObserver((mutationsList, observer) => {
        for (const mutation of mutationsList) {
            if (mutation.type === 'childList') {
                const dropdown = parentElement.querySelector('.autocomplete-content.dropdown-content');
                if (dropdown) {
                    // Disconnect the observer once we've found the element
                    observer.disconnect();
                    // Once the dropdown exists, set up a new observer for changes *within* it
                    // We want the dropdown list to always have all values, not just the ones that contain the input field as a substring
                    const contentObserver = new MutationObserver((contentMutationsList, contentObserver) => {
                        // We only want to make this modification if there are child elements, the list is closed
                        if (dropdown.childElementCount > 0) {
                            dropdown.innerHTML = '';
                            fullLanguagesList.forEach((element) => {
                                if ((element == 'French' && document.getElementById('u-config-form-application').value == 'BRANDSCS') ||
                                    (element == 'French' && !editAppsList.includes('CRSCS'))
                                ) {
                                    // Never add French for BRANDSCS
                                }
                                else {
                                    dropdown.innerHTML += `<li><span><span class="highlight"></span>${element}</span></li>`;
                                }
                            });
                        }
                    });

                    // Start observing the dropdown for changes to its attributes
                    contentObserver.observe(dropdown, {
                        attributes: true, // Watch for changes to attributes
                    });
                    return;
                }
            }
        }
    });

    // Start observing the parent element for the addition of new child nodes
    observer.observe(parentElement, { childList: true, subtree: false });
}

function getFilterDropdownValues() {
    $('#u-config-form-lastModifiedDate').datepicker({ showClearBtn: true });

    var filterObj = {
        performerUserEmail: performerUserEmail,
        allowedApps: editAppsList.toString()
    }

    $.post("./api/GetLanguages.ashx", filterObj,
        function (data) {
            var langs = {};

            data = JSON.parse(data);

            data.sort(function (a, b) {
                return compareStrings(a.languageName, b.languageName);
            });

            // We only want English and Spanish for BrandsCS
            for (var idx in data) {
                if (document.getElementById('u-config-form-application').value == 'BRANDSCS') {
                    if (data[idx].languageName == 'English' || data[idx].languageName == 'Spanish') {
                        langs[data[idx].languageName] = null;
                    }
                }
                else {
                    langs[data[idx].languageName] = null;
                }

            }

            var elems = document.querySelectorAll('#u-config-form-language');
            var search = M.Autocomplete.init(elems, {
                minLength: 0,
                data: langs,
            })[0];
        }
    );
}

// if edit mode, do not updateQueueTable
function setEventListeners() {

    const currentUrl = window.location.href;
    const urlObject = new URL(currentUrl);
    const searchParams = new URLSearchParams(urlObject.search);
    const isEdit = searchParams.get('isEdit');

    $('#u-bypassConfig-resetBasicFilters-btn').on('click', function () {
        //clear the combobox
        $('#u-bypassConfig-resetBasicFilters-btn').addClass("rotate");

        setTimeout(function () { $('#u-bypassConfig-resetBasicFilters-btn').removeClass('rotate'); }, 1000);

        //$('#u-config-form-application').val("");
        $('#u-config-form-language').val("");
        $('#u-config-form-dnis').val("");
        $('#u-config-form-destination').val("");
        $('#u-config-form-rank').val("");
        $('#u-config-form-offerID').val("");
        $('#u-config-form-offerType').val("");

        $('#u-config-form-skillId').val("");
        $('#u-config-form-skillName').val("");

        $('#u-config-form-peg').val("");

        $('#u-config-form-agentsAvailable').val("");
        $('#u-config-form-medInSeconds').val("");
        $('#u-config-form-overflowSkillId').val("");
        $('#u-config-form-overflowSkillName').val("");
        $('#u-config-form-overflowAgentsAvailable').val("");
        $('#u-config-form-overflowMed').val("");

        // Reset labels to being inactive so user can type in them
        $('label').removeClass('active');

        // We want to keep these active since they are immutable
        $('label[for="u-config-form-lastModifiedBy"]').addClass('active');
        $('label[for="u-config-form-lastModifiedDate"]').addClass('active');
        $('label[for="u-config-form-application"]').addClass('active');
    });


    $('#save-button').on('click', function () {
        // Extract values from input fields and add to object which will be sent as parameter
        const parameters = {
            configurationId: searchParams.get('configurationId'),
            application: $('#u-config-form-application').val(),
            language: $('#u-config-form-language').val(),
            dnis: $('#u-config-form-dnis').val().replace(/-/g, ""),
            destination: $('#u-config-form-destination').val().replace(/-/g, ""),
            rank: $('#u-config-form-rank').val().replace(/-/g, "") || null,
            offerId: $('#u-config-form-offerID').val().replace(/-/g, "") || null,
            offerType: $('#u-config-form-offerType').val().replace(/-/g, "") || null,
            peg: $('#u-config-form-peg').val() || null,
            skillId: $('#u-config-form-skillId').val(),
            skillName: $('#u-config-form-skillName').val() || null,
            agentsAvailable: $('#u-config-form-agentsAvailable').val(),
            medInSeconds: $('#u-config-form-medInSeconds').val(),
            overflowSkillId: $('#u-config-form-overflowSkillId').val() || null,
            overflowSkillName: $('#u-config-form-overflowSkillName').val() || null,
            overflowAgentsAvailable: $('#u-config-form-overflowAgentsAvailable').val() || null,
            overflowMed: $('#u-config-form-overflowMed').val() || null,
            lastModifiedUserName: $('#u-config-form-lastModifiedBy').val() || null,
            performerUserEmail: performerUserEmail
            // Date is autogenerated by DB
        };

        if (parameters.application == '') {
            fireDialog('Application required.', 'error', 3000);
        }
        else if (parameters.skillName == '') {
            fireDialog('Skill Name required.', 'error', 3000);
        }
        else if (parameters.skillId == '') {
            fireDialog('Skill ID required.', 'error', 3000);
        }
        else if (parameters.agentsAvailable == '') {
            fireDialog('Agents Available required.', 'error', 3000);
        }
        else if (parameters.medInSeconds == '') {
            fireDialog('MED in Seconds required.', 'error', 3000);
        }
        else {
            if (isEdit == true || isEdit == 'true') {
                $.post("./api/UpdateConfiguration.ashx", parameters,
                    function (data) {
                        //console.log(`data: ${JSON.stringify(data)}`);
                        data = JSON.parse(data);
                        if (data.success) {
                            fireDialog('Edited configuration!', 'success', 3000);
                            window.location.href = './Bypass.aspx';
                        }
                        else {
                            fireDialog(`${data.message}`, 'error', 6000);
                        }
                    }
                );
            }
            else {
                parameters["isCopy"] = true;
                $.post("./api/AddConfiguration.ashx", parameters,
                    function (data) {
                        //console.log(`data: ${JSON.stringify(data)}`);
                        data = JSON.parse(data);
                        if (data.success) {
                            fireDialog('Copied configuration!', 'success', 3000);
                            window.location.href = './Bypass.aspx';
                        }
                        else {
                            fireDialog(`${data.message}`, 'error', 6000);
                        }
                    }
                );
            }
        }
    });

    setCommonEventListenersCreateEditCopy();
}

function resetQueueFilters() {
    //clear the combobox
    $('#u-bypassConfig-resetBasicFilters-btn').addClass("rotate");

    setTimeout(function () { $('#u-bypassConfig-resetBasicFilters-btn').removeClass('rotate'); }, 2000);

    $('#u-config-form-application').val("");
    $('#u-config-form-language').val("");
    $('#u-config-form-rank').val("");
    $('#u-config-form-lastModifiedDate').val("");
    $('#u-config-form-dnis').val("");
    $('#u-config-form-destination').val("");

    $('#u-config-form-offerID').val("");
    $('#u-config-form-offerType').val("");
    $('#u-config-form-lastModifiedBy').val("");


    $('#u-config-form-application').prop("disabled", false);

    $('#u-config-form-skillId').val("");
    $('#u-config-form-skillName').val("");

    $('.slotCount > textfield').text(0);

    $('#slots-input').val("");
    $('#max-overflow-input').val("");
    $('#slots-subset-input').val("");
    unselectAllTimeslots();

    $('#u-form-inboundCallerID').prop('checked', false);
    $('#u-form-makeDefault').prop('checked', false);
    $('#u-form-noMax').prop('checked', false);

    $('#switch').removeClass("toggle-on");

    if (!editMode)
        updateQueueTable();
}