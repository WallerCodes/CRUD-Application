var performerUserEmail = '';

var userAccessLevel = 'None';
var document = '';

var editMode = false;

$(document).ready(function () {

    setLastModifiedByAndDate();

    setFrameSize();

    userAccessLevel = localStorage.getItem('accessLevel');

    document = this;

    // Get search params of current url
    const currentUrl = window.location.href;
    const urlObject = new URL(currentUrl);
    const searchParams = new URLSearchParams(urlObject.search);

    checkRoles(performerUserEmail).then(function (data) {

        fillParametersFromUrl(searchParams);

        observeDropdowns();

        getFilterDropdownValues();

        setEventListeners();

    });

});

function setLastModifiedByAndDate() {

    // Set value for last modified by
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

function getFilterDropdownValues() {
    $('#u-config-form-lastModifiedDate').datepicker({ showClearBtn: true });

    var filterObj = {
        performerUserEmail: performerUserEmail,
        allowedApps: editAppsList.toString()
    }

    // We only want to allow users who can edit apps to edit the ones they have permissions for
    const data = Object.fromEntries(editAppsList.map(key => [key, null]));

    var elems = document.querySelectorAll('#u-config-form-application');
    var search = M.Autocomplete.init(elems, {
        minLength: 0,
        data: data,
    })[0];

    $.post("./api/GetLanguages.ashx", filterObj,
        function (data) {
            var langs = {};

            data = JSON.parse(data);

            data.sort(function (a, b) {
                return compareStrings(a.languageName, b.languageName);
            });
            
            for (var idx in data) {
                langs[data[idx].languageName] = null;
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

    $('#u-bypassConfig-resetBasicFilters-btn').on('click', function () {
        //clear the combobox
        $('#u-bypassConfig-resetBasicFilters-btn').addClass("rotate");

        setTimeout(function () { $('#u-bypassConfig-resetBasicFilters-btn').removeClass('rotate'); }, 1000);

        $('#u-config-form-application').val("");
        $('#u-config-form-language').val("");
        $('#u-config-form-dnis').val("");
        $('#u-config-form-destination').val("");
        $('#u-config-form-peg').val("");
        $('#u-config-form-rank').val("");
        $('#u-config-form-offerID').val("");
        $('#u-config-form-offerType').val("");

        $('#u-config-form-skillName').val("");
        $('#u-config-form-skillId').val("");
        $('#u-config-form-agentsAvailable').val("");
        $('#u-config-form-medInSeconds').val("");
        $('#u-config-form-overflowSkillName').val("");
        $('#u-config-form-overflowSkillId').val("");
        $('#u-config-form-overflowAgentsAvailable').val("");
        $('#u-config-form-overflowMed').val("");

        $('label').removeClass('active');

        // We want to keep these active since they are immutable
        $('label[for="u-config-form-lastModifiedBy"]').addClass('active');
        $('label[for="u-config-form-lastModifiedDate"]').addClass('active');
    });

    $('#create-button').on('click', function () {
        // Extract values from input fields and add to object which will be sent as parameter
        const parameters = {
            application: $('#u-config-form-application').val(),
            language: $('#u-config-form-language').val(),
            dnis: $('#u-config-form-dnis').val().replace(/-/g, ''),
            destination: $('#u-config-form-destination').val().replace(/-/g, ''),
            rank: $('#u-config-form-rank').val().replace(/-/g, ''),
            offerId: $('#u-config-form-offerID').val().replace(/-/g, ''),
            offerType: $('#u-config-form-offerType').val().replace(/-/g, ''),
            peg: $('#u-config-form-peg').val(),
            skillId: $('#u-config-form-skillId').val(),
            skillName: $('#u-config-form-skillName').val(),
            agentsAvailable: $('#u-config-form-agentsAvailable').val(),
            medInSeconds: $('#u-config-form-medInSeconds').val(),
            overflowSkillId: $('#u-config-form-overflowSkillId').val(),
            overflowSkillName: $('#u-config-form-overflowSkillName').val(),
            overflowAgentsAvailable: $('#u-config-form-overflowAgentsAvailable').val(),
            overflowMed: $('#u-config-form-overflowMed').val(),
            lastModifiedUserName: $('#u-config-form-lastModifiedBy').val(),
            performerUserEmail: performerUserEmail
            // Date is autogenerated by DB
        };

        
        if (containsOnlyWhitespace(parameters.application)) {
            fireDialog('Application required.', 'error', 3000);
        }
        else if (containsOnlyWhitespace(parameters.skillName)) {
            fireDialog('Skill Name required.', 'error', 3000);
        }
        else if (containsOnlyWhitespace(parameters.skillId)) {
            fireDialog('Skill ID required.', 'error', 3000);
        }
        else if (containsOnlyWhitespace(parameters.agentsAvailable)) {
            fireDialog('Agents Available required.', 'error', 3000);
        }
        else if (containsOnlyWhitespace(parameters.medInSeconds)) {
            fireDialog('MED in Seconds required.', 'error', 3000);
        }
        else {
            parameters["isCopy"] = false;
            $.post("./api/AddConfiguration.ashx", parameters,
                function (data) {
                    //console.log(`data: ${JSON.stringify(data)}`);
                    data = JSON.parse(data);
                    if (data.success) {
                        fireDialog('Created new configuration!', 'success', 3000);
                        window.location.href = './Bypass.aspx';
                    }
                    else {
                        console.log("error")
                        fireDialog(`${data.message}`, 'error', 6000);
                    }
                }
            );
        }
    });

    const applicationInput = document.getElementById('u-config-form-application');
    // Prevent typing by blocking key events   
    applicationInput.addEventListener('keydown', function (e) {
        // Allow Backspace, Delete, Tab, Arrow keys for usability if needed
        const allowedKeys = [];
        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }
    });

    const languageInput = document.getElementById('u-config-form-language');

    // Prevent typing by blocking key events   
    languageInput.addEventListener('keydown', function (e) {
        // Allow Backspace, Delete, Tab, Arrow keys for usability if needed
        const allowedKeys = [];
        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }
    });

    //languageInput.addEventListener('change', function (e) {
    //    if (this.value == '* (ALL LANGUAGES)') {
    //        this.value = '*';
    //    }
    //});

    applicationInput.addEventListener('change', function (e) {
        if (applicationInput.value == 'CRSCS') {

            // Rank
            const rankInput = document.getElementById('u-config-form-rank');
            rankInput.value = '-';
            rankInput.labels[0].textContent = "Rank";
            rankInput.setAttribute('disabled', true);

            const rankLabel = document.querySelector(`label[for="u-config-form-rank"]`)            
            rankLabel.classList.add('active');

            // OfferID
            const offerIdInput = document.getElementById('u-config-form-offerID');
            offerIdInput.value = '-';
            offerIdInput.labels[0].textContent = "Offer ID";
            offerIdInput.setAttribute('disabled', true);            
            const offerIdInputLabel = document.querySelector(`label[for="u-config-form-offerID"]`)            
            offerIdInputLabel.classList.add('active');

            // OfferType
            const offerTypeInput = document.getElementById('u-config-form-offerType');
            offerTypeInput.value = '';
            offerTypeInput.labels[0].textContent = "Offer Type (Citi Strata or *)";
            offerTypeInput.removeAttribute('disabled');

            const offerTypeLabel = document.querySelector(`label[for="u-config-form-offerType"]`)            
            offerTypeLabel.classList.remove('active');
        }
        else if (applicationInput.value == 'BRANDSCS' || applicationInput.value == 'BANKCARDNRI') {

            // Language
            if (languageInput.value == 'French') {
                languageInput.value = '';
            }

            // Rank
            const rankInput = document.getElementById('u-config-form-rank');
            rankInput.value = '';            
            rankInput.labels[0].textContent = "Rank (1-6 or *)";
            rankInput.removeAttribute('disabled');

            const rankLabel = document.querySelector(`label[for="u-config-form-rank"]`)
            rankLabel.classList.remove('active');

            // OfferId
            const offerIdInput = document.getElementById('u-config-form-offerID');
            offerIdInput.value = '';            
            offerIdInput.labels[0].textContent = "Offer ID (12345678 or *)";
            offerIdInput.removeAttribute('disabled');

            const offerInputLabel = document.querySelector(`label[for="u-config-form-offerID"]`)
            offerInputLabel.classList.remove('active');

            // OfferType
            const offerTypeInput = document.getElementById('u-config-form-offerType');
            offerTypeInput.value = '-';            
            offerTypeInput.labels[0].textContent = "Offer Type";
            offerTypeInput.setAttribute('disabled', true);

            const offerTypeLabel = document.querySelector(`label[for="u-config-form-offerType"]`)
            offerTypeLabel.classList.add('active');
        }
        else {

            if (languageInput.value == 'French') {
                languageInput.value = '';
            }

            document.getElementById('u-config-form-rank').removeAttribute('disabled');
            document.getElementById('u-config-form-offerID').removeAttribute('disabled');
            document.getElementById('u-config-form-offerType').removeAttribute('disabled');
        }
    });

    setCommonEventListenersCreateEditCopy();    
}

function fillParametersFromUrl(searchParams) {
    
    setInputValueAndActivate("u-config-form-application", "application", searchParams);
    setInputValueAndActivate("u-config-form-language", "language", searchParams);
    setInputValueAndActivate("u-config-form-dnis", "dnis", searchParams);
    setInputValueAndActivate("u-config-form-destination", "destination", searchParams);

    const application = searchParams.get('application')

    if (application == 'BRANDSCS' || application == 'BANKCARDNRI') {       
        const offerTypeInput = document.getElementById('u-config-form-offerType');
        offerTypeInput.value = '';
        offerTypeInput.setAttribute('disabled', true);

        setInputValueAndActivate("u-config-form-rank", "rank", searchParams);
        setInputValueAndActivate("u-config-form-offerID", "offerID", searchParams);
    }
    else if (application == 'CRSCS') {
        const rankInput = document.getElementById('u-config-form-rank');
        rankInput.value = '';
        rankInput.setAttribute('disabled', true);

        const offerIdInput = document.getElementById('u-config-form-offerID');
        offerIdInput.value = '';
        offerIdInput.setAttribute('disabled', true);

        setInputValueAndActivate("u-config-form-offerType", "offerType", searchParams);
    }
    else {
        setInputValueAndActivate("u-config-form-rank", "rank", searchParams);
        setInputValueAndActivate("u-config-form-offerID", "offerID", searchParams);
        setInputValueAndActivate("u-config-form-offerType", "offerType", searchParams);
    }

    setInputValueAndActivate("u-config-form-peg", "peg", searchParams);

    setLastModifiedByAndDate();
}

function setInputValueAndActivate(id, paramName, searchParams) {
    const inputField = document.getElementById(id);
    if (inputField && searchParams.has(paramName)) {

        var paramValue = searchParams.get(paramName);
        // Validation to protect against invalid params
        // Label renaming based on input
        if (paramName == 'dnis') {
            if (paramValue.length != 12)
                paramValue = ''; // Do not allow incomplete phone numbers that are not 10 digits + 2 dashes
            else if (paramValue != '')
                inputField.labels[0].textContent = "DNIS"
        }
        if (paramName == 'destination') {
            if (paramValue.length != 12)
                paramValue = ''; // Do not allow incomplete phone numbers that are not 10 digits + 2 dashes
            else if (paramValue != '')
                inputField.labels[0].textContent = "Destination Phone Number"
        }
        else if (paramName == 'peg' && paramValue.length > 32) {
            paramValue = '';
        }
        else if (paramName == 'rank') {
            if (paramValue.length > 6)
                paramValue = '';
            else if (paramValue != '')
                inputField.labels[0].textContent = "Rank"
        }
        else if (paramName == 'offerId') {
            if (paramValue.length > 8)
                paramValue = '';
            else if (paramValue != '')
                inputField.labels[0].textContent = "Offer ID"
        }
        else if (paramName == 'offerType') {
            if (paramValue.length > 100)
                paramValue = '';
            else if (paramValue != '')
                inputField.labels[0].textContent = "Offer Type"
        }      

        inputField.value = paramValue;

        const inputLabel = document.querySelector(`label[for="${id}"]`);
        if (inputLabel && inputField.value != "") {
            inputLabel.classList.add('active');
        }
    }
}

function observeDropdowns() {
    observeSpecificDropdown('u-config-form-application');
    observeSpecificDropdown('u-config-form-language');
}

function observeSpecificDropdown(dropdownId) {
    //console.log(`full lang list: ${fullLanguagesList}`)

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

                            if (dropdownId == 'u-config-form-application') {
                                editAppsList.forEach((element) => {
                                    dropdown.innerHTML += `<li><span><span class="highlight"></span>${element}</span></li>`;
                                });
                            }
                            else {
                                fullLanguagesList.forEach((element) => {
                                    if ((element == 'French' && document.getElementById('u-config-form-application').value == 'BRANDSCS') ||
                                        (element == 'French' && !editAppsList.includes('CRSCS'))
                                    ) {
                                        // Never add French for BRANDSCS or if user can't edit CRSCS
                                    }
                                    else {
                                        dropdown.innerHTML += `<li><span><span class="highlight"></span>${element}</span></li>`;
                                    }
                                });
                            }
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

    $('#threshold-min').val("");
    $('#threshold-max').val("");
    $('#threshold-max').prop('disabled', false);

    $('#u-config-queue div label').removeClass('active');

    $('#u-config-form-application').prop("disabled", false);
    $('#u-config-form-language').prop("disabled", false);

    $('#u-config-form-skillName').val("");
    $('#u-config-form-skillName').prop("disabled", false);

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