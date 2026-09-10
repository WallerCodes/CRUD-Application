// Globals
var allFields = {}; // object contains fields that we will submit
var formValid = false; // once form is valid - it stays valid until its reset
var hideMaskAfterLoad = true;
var partnerData = [];
var isTemplate = false;
var nextID = 0;
var makeDatesRelativeToToday = false;

var performerUserEmail = '';

var currentUserData = {};

var readAppsList = [];
var editAppsList = [];
var adminAppsList = [];
var fullAppsList = [];
var fullLanguagesList = [];
var fullUsersList = [];
var superAdmin = false;
var isUsanUser = false;

var localeTimeOptions;

const AccessLevel = {
    None: "None",
    Read: "View",
    Edit: "Edit",
    Admin: "Update Users"
}

function generateNextElementID() {
    nextID++;
    return 'u-el-' + nextID;
}

function setTheme(themeName) {
    if (themeName.indexOf('theme') != 0) {
        themeName = "theme-" + themeName;
    }
    document.documentElement.className = themeName;

}

// ===== UI Elements ==========================================================

(function (window, document, undefined) {

    var factory = function ($, DataTable) {
        "use strict";

        $('.search-toggle').click(function () {
            if ($('.hiddensearch').css('display') == 'none')
                $('.hiddensearch').slideDown();
            else
                $('.hiddensearch').slideUp();
        });

        /* Set the defaults for DataTables initialisation */
        $.extend(true, DataTable.defaults, {
            dom: "<'hiddensearch'f'>" +
                "tr" +
                "<'table-footer'lip'>",
            renderer: 'material'
        });

        /* Default class modification */
        $.extend(DataTable.ext.classes, {
            sWrapper: "dataTables_wrapper",
            sFilterInput: "form-control input-sm",
            sLengthSelect: "form-control input-sm"
        });

        /* Bootstrap paging button renderer */
        DataTable.ext.renderer.pageButton.material = function (settings, host, idx, buttons, page, pages) {
            var api = new DataTable.Api(settings);
            var classes = settings.oClasses;
            var lang = settings.oLanguage.oPaginate;
            var btnDisplay, btnClass, counter = 0;

            var attach = function (container, buttons) {
                var i, ien, node, button;
                var clickHandler = function (e) {
                    e.preventDefault();
                    if (!$(e.currentTarget).hasClass('disabled')) {
                        api.page(e.data.action).draw(false);
                    }
                };

                for (i = 0, ien = buttons.length; i < ien; i++) {
                    button = buttons[i];

                    if ($.isArray(button)) {
                        attach(container, button);
                    } else {
                        btnDisplay = '';
                        btnClass = '';

                        switch (button) {

                            case 'first':
                                btnDisplay = '<i class="material-icons">first_page</i>';
                                btnClass = button + (page > 0 ?
                                    '' : ' disabled');
                                break;

                            case 'previous':
                                btnDisplay = '<i class="material-icons">chevron_left</i>';
                                btnClass = button + (page > 0 ?
                                    '' : ' disabled');
                                break;

                            case 'next':
                                btnDisplay = '<i class="material-icons">chevron_right</i>';
                                btnClass = button + (page < pages - 1 ?
                                    '' : ' disabled');
                                break;

                            case 'last':
                                btnDisplay = '<i class="material-icons">last_page</i>';
                                btnClass = button + (page < pages - 1 ?
                                    '' : ' disabled');
                                break;

                        }

                        if (btnDisplay) {
                            node = $('<li>', {
                                'class': classes.sPageButton + ' ' + btnClass,
                                'id': idx === 0 && typeof button === 'string' ?
                                    settings.sTableId + '_' + button : null
                            })
                                .append($('<a>', {
                                    'href': '#',
                                    'aria-controls': settings.sTableId,
                                    'data-dt-idx': counter,
                                    'tabindex': settings.iTabIndex
                                })
                                    .html(btnDisplay)
                                )
                                .appendTo(container);

                            settings.oApi._fnBindAction(
                                node, {
                                action: button
                            }, clickHandler
                            );

                            counter++;
                        }
                    }
                }
            };

            // IE9 throws an 'unknown error' if document.activeElement is used
            // inside an iframe or frame.
            var activeEl;

            try {
                // Because this approach is destroying and recreating the paging
                // elements, focus is lost on the select button which is bad for
                // accessibility. So we want to restore focus once the draw has
                // completed
                activeEl = $(document.activeElement).data('dt-idx');
            } catch (e) { }

            attach(
                $(host).empty().html('<ul class="material-pagination"/>').children('ul'),
                buttons
            );

            if (activeEl) {
                $(host).find('[data-dt-idx=' + activeEl + ']').focus();
            }
        };

        /*
         * TableTools Bootstrap compatibility
         * Required TableTools 2.1+
         */
        if (DataTable.TableTools) {
            // Set the classes that TableTools uses to something suitable for Bootstrap
            $.extend(true, DataTable.TableTools.classes, {
                "container": "DTTT btn-group",
                "buttons": {
                    "normal": "btn btn-default",
                    "disabled": "disabled"
                },
                "collection": {
                    "container": "DTTT_dropdown dropdown-menu",
                    "buttons": {
                        "normal": "",
                        "disabled": "disabled"
                    }
                },
                "print": {
                    "info": "DTTT_print_info"
                },
                "select": {
                    "row": "active"
                }
            });

            // Have the collection use a material compatible drop down
            $.extend(true, DataTable.TableTools.DEFAULTS.oTags, {
                "collection": {
                    "container": "ul",
                    "button": "li",
                    "liner": "a"
                }
            });
        }

    }; // /factory

    // Define as an AMD module if possible
    if (typeof define === 'function' && define.amd) {
        define(['jquery', 'datatables'], factory);
    } else if (typeof exports === 'object') {
        // Node/CommonJS
        factory(require('jquery'), require('datatables'));
    } else if (jQuery) {
        // Otherwise simply initialise as normal, stopping multiple evaluation
        factory(jQuery, jQuery.fn.dataTable);
    }

})(window, document);


$('.logout-user').click(function () {
    logoutUser();
});


function changePassword() {
    //var email = localStorage.getItem('email');
    var oldPassword = $(".old-password").val();
    var newPassword = $(".new-password").val();
    var confirmPassword = $(".confirm-password").val();

    if (newPassword == "" || confirmPassword == "" || oldPassword == "") {
        fireDialog('Invalid login info! Password cannot be blank.', 'error', 3500);
        return;
    }

    const oldHash = Sha256.hash(oldPassword);
    const newHash = Sha256.hash(newPassword);

    if (newPassword != confirmPassword) {
        fireDialog('Passwords do not match! Please try again.', 'error', 3500);
        return;
    }

    $.post("./api/UpdateUser.ashx",
        {
            userName: performerUserEmail,
            oldPassword: oldHash,
            newPassword: newHash
        },
        function (data, status) {
            //login success
            data = JSON.parse(data);
            if (status == 'success' && data.success === true) {
                fireDialog('Password changed successfully', 'success', 3500);
                cancelAction();
                $('.old-password').val('');
                $('.new-password').val('');
                $('.confirm-password').val('');
                removeChangePasswordUnderline();
            }
            else {
                if (data.error) {
                    fireDialog(data.error, 'error', 3500);
                }
                else {
                    fireDialog('Could not change user password! Please try again', 'error', 3500);
                }
            }
        }
    );
}

function isValidPhoneNumber(phoneNumber) {
    // Regular expression to match the format XXX-XXX-XXXX
    // ^: Asserts position at the start of the string.
    // \d{3}: Matches exactly three digits (0-9).
    // -: Matches the hyphen literally.
    // $: Asserts position at the end of the string.
    const phoneRegex = /^\d{3}-\d{3}-\d{4}$/;

    return phoneRegex.test(phoneNumber);
}

function formatPhoneNumber(phoneNumber) {
    const areaCode = phoneNumber.substring(0, 3);
    const centralOfficeCode = phoneNumber.substring(3, 6);
    const lineNumber = phoneNumber.substring(6, 10);

    return `${areaCode}-${centralOfficeCode}-${lineNumber}`;
}

function addChangePasswordUnderline() {
    const passwordMenuItem = document.getElementById('changePasswordMenuItem');
    passwordMenuItem.style.textDecoration = 'underline';
    var currentMenuItem;

    const currentLocation = window.location.href;
    if (currentLocation.includes('Admin')) {
        currentMenuItem = document.getElementById('admin-menu-option');
    }
    else if (currentLocation.includes('Bypass.aspx')) {
        currentMenuItem = document.getElementById('bypassConfigurationMenuItem');
    }

    currentMenuItem.style.textDecoration = 'none';
}

function removeChangePasswordUnderline() {
    const passwordMenuItem = document.getElementById('changePasswordMenuItem');
    passwordMenuItem.style.textDecoration = 'none';
    var currentMenuItem;

    const currentLocation = window.location.href;
    if (currentLocation.includes('Admin.aspx')) {
        currentMenuItem = document.getElementById('admin-menu-option');
    }
    else if (currentLocation.includes('Bypass.aspx')) {
        currentMenuItem = document.getElementById('bypassConfigurationMenuItem');
    }

    currentMenuItem.style.textDecoration = 'underline';
}

function showChangePassword() {
    $('#changePwForm').fadeToggle();
    addChangePasswordUnderline()
}

function cancelAction() {
    $('.old-password').val("")
    $('.new-password').val("")
    $('.confirm-password').val("")
    $('#changePwForm').fadeToggle();
    removeChangePasswordUnderline();
}

$(document).mouseup(function (e) {
    var container = $("#changePwForm");

    if (!container.is(e.target) // if the target of the click isn't the container...
        && container.has(e.target).length === 0) // ... nor a descendant of the container
    {
        //$('.ump-options-btn.ump-btn').show();
        container.fadeOut();
    }
});


function validateEmail(classEmail) {
    var email = $(classEmail).val();

    if (email == "") {
        return;
    }

    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    if (!re.test(email)) {
        fireDialog('Invalid Email', 'error', 3500)
        return false;
    }
    return true;
}


$(window).on('resize', function () {
    setFrameSize();
});

$(document).ready(function () {
    checkIfUserStillExists();
    // Materialize Components
    //console.log("Initializing modals")
    $('#form-modal').modal();
    $('#form-modal-no-footer').modal();
    $('#yesno-modal').modal();
    $('#info-modal').modal();

    $('.old-password').attr('placeholder', 'Old Password');
    $('.new-password').attr('placeholder', 'New Password');
    $('.confirm-password').attr('placeholder', 'Confirm Password');

    // Only fires if there is a pushState that has been added (done in the logout handler)
    window.addEventListener('pageshow', function (event) {
        if (event.persisted) {
            // Restored from bfcache - force reload
            window.location.reload();
        }
    });

    // Don't allow anything but numbers in number type input fields
    document.querySelectorAll('input[type="number"]').forEach(function (input) {
        input.addEventListener('keydown', function (e) {
            const allowedKeys = [
                'Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab', 'Home', 'End'
            ];

            // Allow digits and allowed control keys
            if (
                !e.key.match(/^\d$/) && // not a digit
                !allowedKeys.includes(e.key)
            ) {
                e.preventDefault();
            }
        });
    });

    $('input[type=search].autocomplete').on('search', function () {
        // this function will be executed on click of X (clear button)
        // render the dropdown again after the clear
        if ($(this)[0].textContent == "")
            $(this)[0].M_Autocomplete.open();
    });

    // Blur search field on Enter
    $('input[type="search"]').on('keydown', function (e) {
        if (e.key == 'Enter') {
            this.blur();
        }
    })

    $('input[dataType="alphanumeric"]').on('keydown', function (e) {
        const controlKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab', 'Enter', 'Escape', ' '];

        // Allow control keys
        if (controlKeys.includes(e.key)) {
            return;
        }

        // Allow alphanumeric characters (single characters only)
        if (/^[a-zA-Z0-9]$/.test(e.key)) {
            return;
        }

        // Prevent anything else
        e.preventDefault();
    });  

    var currPage = window.location.href;

    performerUserEmail = localStorage.getItem('email');

    if (isEmpty(performerUserEmail) && !currPage.includes('Login.tsx')) {
        window.location.href = './Login.tsx';
    }

    checkErrorMessage();

    if (hideMaskAfterLoad) {
        hideMask();
    }

    getAppsLangsUsers();

});

function setDropdownTabindex() {
    const dropdownElements = document.querySelectorAll('.dropdown-content');
    dropdownElements.forEach(element => {
        element.setAttribute('tabindex', '0');
    });
}

function isEmpty(value) {
    return (
        // null or undefined
        (value == null) ||

        // has length and it's zero
        (value.hasOwnProperty('length') && value.length === 0) ||

        // is an Object and has no keys
        (value.constructor === Object && Object.keys(value).length === 0) ||

        //for dates
        (value == '0001-01-01T00:00:00')
    )
}

function getAppsLangsUsers() {

    var filterObj = {
        performerUserEmail: performerUserEmail,
        "allowedApps": readAppsList.toString()
    }

    $.post("./api/GetLanguages.ashx", filterObj,
        function (data) {

            data = JSON.parse(data);

            data.sort(function (a, b) {
                return compareStrings(a.languageName, b.languageName);
            });

            data.forEach((jsonElement) => {
                fullLanguagesList.push(jsonElement.languageName);
            });       

            const firstLang = fullLanguagesList.shift();

            if (firstLang == '*') {
                fullLanguagesList.push("* (ALL LANGUAGES)")
            }

            //console.log(`full lang list: ${fullLanguagesList}`)
        }
    );

    $.post("./api/GetUsers.ashx", filterObj,
        function (response) {
            response = JSON.parse(response);

            data = response.data;

            // Uncomment if we want to get rid of SYSTEM showing up in user filtering. 
            data = data.filter(obj => obj.userName !== 'SYSTEM');

            data.sort(function (a, b) {
                return compareStrings(a.userName, b.userName);
            });

            data.forEach((jsonElement) => {
                fullUsersList.push(jsonElement.userName);
            });
        }
    );





}


function checkRoles(userName) {
    var searchObj = {
        performerUserEmail: userName,
        lookupUserName: userName
    };

    return $.post("./api/GetFullUser.ashx", searchObj,
        function (data) {
            data = JSON.parse(data);

            currentUserData = data;

            var showAdminOption = false;

            currentUserData.userRoles.forEach(function (roleRow) {
                var currApp = roleRow.application;

                if (roleRow.accessLevelRead && readAppsList.indexOf(currApp) === -1) {
                    readAppsList.push(currApp);
                }

                if (roleRow.accessLevelEdit && editAppsList.indexOf(currApp) === -1) {
                    editAppsList.push(currApp);
                }

                if (roleRow.accessLevelAdmin && adminAppsList.indexOf(currApp) === -1) {
                    adminAppsList.push(currApp);
                }

                if (roleRow.accessLevelAdmin === true) {
                    showAdminOption = true;
                }

            });

            if (currentUserData.isSuperAdmin === true) {
                superAdmin = true;
            }

            if (currentUserData.isUsanUser === true) {
                isUsanUser = true;
            }

            // if super admin or admin of app show the tab
            if (currentUserData.isSuperAdmin || showAdminOption) {
                $('#admin-menu-option').show();
            }

            if (editAppsList.length > 0) {
                $('#config-menu-option').show();
            }
        }
    );
}

function checkErrorMessage() {
    var errorEl = $('#websiteErrorMessage');
    if (errorEl && errorEl.length > 0) {
        displayError(errorEl.html())
    }
    $('#u-mask').fadeIn();
}

function hideMask() {
    $('#u-mask').fadeOut();
}

function showMessage(msg, icon) {
    if (!icon) {
        icon = 'check_circle';
    }
    openInfoModal({ icon: icon, message: msg })
}

function formatDate(date) {
    if (!date) {
        return '';
    }
    var m = new Date(date);

    var tzOffset = (m.getTimezoneOffset() - getTimeZoneOffset(m, 'America/New_York')); // Set to whatever TZ client wants to convert to

    m.setMinutes(m.getMinutes() + tzOffset);

    var amPmStr = 'AM';
    var hrs = m.getHours();
    if (hrs > 12) {
        hrs = hrs - 12;
        amPmStr = 'PM';
    }
    else if (hrs == 12) {
        amPmStr = 'PM';
    }
    var mins = m.getMinutes();
    if (mins < 10) {
        mins = '0' + mins;
    }
    if (hrs < 10) {
        hrs = '0' + hrs;
    }
    var dateString = (m.getMonth() + 1) + "/" + m.getDate() + "/" + m.getFullYear() + " " + hrs + ":" + mins + " " + amPmStr;
    return dateString;
}

// change to a nice pretty popup with error message
function displayError(errorMessage) {
    openInfoModal({ icon: 'error', message: 'ERROR: ' + errorMessage })
}

function openInfoModal(config) {
    var icon = "info";
    if (config.icon) {
        icon = config.icon;
    }
    var iconClass = 'info';
    if (icon == "error") {
        iconClass = "error";
    } else if (icon == "check_circle") {
        iconClass = "success";
    }
    if (config.msg) {
        config.message = config.msg;
    }
    $("#info-modal .modal-header i").on('click', function () {
        $("#info-modal").modal('close');
    });
    $("#info-modal .modal-content").empty();
    $("#info-modal .modal-content").append('<div class="u-modal-icon ' + iconClass + '"> <i class="medium material-icons">' + config.icon + '</i></div><div class="u-modal-msg">' + config.message + '</div>');


    // initialize clicks
    $("#info-ok-btn").off('click');

    // set height
    if (!config.height) {
        var startHeight = 11.5;
        var lineCount = Math.ceil(config.message.length / 50);
        if (lineCount > 3) {
            startHeight += lineCount - 3;
        }
        config.height = startHeight + 'em';
    }
    $('#info-modal').css('height', config.height);

    // set max_width 
    if (!config.maxWidth) {
        $('#info-modal').css('max-width', '500px');
    } else {
        $('#info-modal').css('max-width', config.maxWidth);
    }


    // open modal
    if (!$("#info-modal").is(':visible')) {
        $("#info-modal").modal('open');
    }
}

function openYesNoModal(config) {
    $("#yesno-modal .modal-header i").on('click', function () {
        $("#yesno-modal").modal('close');
    });
    $("#yesno-modal .modal-title").html(config.title);
    $("#yesno-modal .modal-content").empty();

    $("#yesno-modal .modal-content").append(config.message);


    // initialize clicks
    $("#yesno-yes-btn").off('click');
    if (config.onYes) {
        $("#yesno-yes-btn").click(function () {
            config.onYes();
        })
    }
    $("#yesno-no-btn").off('click');
    if (config.onNo) {
        $("#yesno-no-btn").click(function () {
            config.onNo();
        })
    }

    // set height
    if (!config.height) {
        config.height = '14em';
    }
    $('#yesno-modal').css('height', config.height);


    // open modal
    if (!$("#yesno-modal").is(':visible')) {
        $("#yesno-modal").modal('open');
    }
}

function openFormModal(config) {
    $(config.element + " .modal-header i").on('click', function () {
        $(config.element).modal('close');
    });
    $(config.element + " .modal-title").html(config.title);
    $(config.element + " .modal-content").empty();



    $(config.element + " .modal-content").append('<form class="col s12"></form>');

    // add form rows
    if (config.rows) {
        for (var a = 0; a < config.rows.length; a++) {
            $(config.element + " form").append(config.rows[a]);
        }
    }


    // initialize click
    $("#fm-save-btn").off('click');
    if (config.onSave) {
        $("#fm-save-btn").click(function () {
            config.onSave();
        })
    }


    // set height
    if (!config.height) {
        config.height = '70%';
    }
    $(config.element).css('height', config.height);

    if (!config.width) {
        config.width = '500px';
    }

    $(config.element).css('width', config.width);

    // open modal
    if (!$(config.element).is(':visible')) {
        $(config.element).modal('open');
    }

    // additional stuff after init
    if (config.onAfterInit) {
        config.onAfterInit();
    }
}

function materializeFormInit() {
    //$('.datepicker').datepicker();
    M.updateTextFields(); // update label of filled values
}

function setBooleanValue(elementID, value) {
    $('input[name=' + elementID + '][value="1"]').prop("checked", (value ? true : false));
    $('input[name=' + elementID + '][value="0"]').prop("checked", (value ? false : true));
}

var MONTHS_SHORT = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
function processFieldValue(field) {
    if (field.field_type == "date") {
        var offset = new Date().getTimezoneOffset() * 60 * 1000;
        if (field.value && field.value.indexOf('1') == 0 && field.value.length == 7) {
            var year = '20' + field.value.substring(1, 3);
            var month = field.value.substring(3, 5);
            var day = field.value.substring(5, 7);
            var date = new Date(Date.parse(year + '-' + month + '-' + day) + offset);
            var dateStr = MONTHS_SHORT[date.getMonth()] + " " + day + ", " + year;
            return dateStr;
        } else if (field.value && field.value.length == 8) {
            var year = field.value.substring(4, 8);
            var month = field.value.substring(0, 2);
            var day = field.value.substring(2, 4);
            //var date = new Date(year + '-' + month + '-' + day);
            var date = new Date(Date.parse(year + '-' + month + '-' + day) + offset);
            var dateStr = MONTHS_SHORT[date.getMonth()] + " " + day + ", " + year;
            return dateStr;
        }
    } else if (field.field_name == "SSN") {
        if (field.value && field.value.length > 4) {
            return field.value.substring(field.value.length - 4)
        }
    } else if (field.field_type == "money") {
        if (field.value) {
            // if there is a dot - don't do anything. May be in future we can normalize by parseFloat, then toFixed(2).
            if (field.value.indexOf('.') > 0) {
                return field.value;
            }
            var val = parseInt(field.value);
            if (field.max_length == 13) {
                return (val / 100).toFixed(2);
            } else {
                return val;
            }
        }
    }
    return field.value;
}

/* FIELD RENDERERS */
function getFieldHTML(field) {
    // default value
    if (field.value === null && field.field_type == "date") {
        field.value = field.default_value;
    }
    // process field value based on the type
    field.value = processFieldValue(field);

    // calculate the style
    if (field.width) {
        field.style = 'width: ' + field.width;
    }
    if (field.style) {
        field.styleStr = ' style="' + field.style + '"';
    } else {
        field.styleStr = '';
    }

    // default value
    if (field.value === null) {
        field.value = field.default_value;
    }

    // generate and save element ID
    var elementID = 'u-field-' + field.field_name;
    field.elementID = elementID;


    // save to field info to a global dictionary
    field.start_value = field.value;
    field.elementID = elementID;
    field.is_valid = !field.is_required;
    allFields[field.field_id] = field;

    // get HTML based on the field type
    if (field.field_type == "money") {
        return getMoneyField(field);
    } else if (field.field_type == "int") {
        return getIntField(field);
    } else if (field.field_type == "accountnum") {
        return getAccountField(field);
    } else if (field.field_type == "phone") {
        return getPhoneField(field);
    } else if (field.field_type == "enum") {
        return getEnumField(field);
    } else if (field.field_type == "date") {
        return getDateField(field);
    } else if (field.field_type == "string") {
        return getStringField(field);
    } else if (field.field_type == "boolean") {
        return getBooleanField(field);
    } else if (field.field_type == "custom" && ['Days_Delq', 'DpdInd1', 'DpdInd2', 'DpdInd3', 'DpdInd4'].indexOf(field.field_name) > -1) {
        return getDaysDelinquentField(field);
    } else {
        // default
        //console.log("Unknown field type", field.field_type);
        return getStringField(field);
    }
}

function encodeForHTML(val) {
    if (!val) {
        return "";
    }
    if (typeof val != "string") {
        val = "" + val;
    }
    val = val.replace(/"/g, '\x22');
    val = val.replace(/'/g, '&quot;');
    return val;
}

function ddUpdate(field, val) {
    val = parseInt(val);
    // find date fields that depend on dd
    if (!field.dependants) {
        field.dependants = [];

        for (var i in allFields) {
            if (allFields[i].field_type == 'date' && allFields[i].dateFormula && allFields[i].dateFormula.dd != 0) {
                var isDependant = true;
                if (selectedPartner && selectedPartner.partner_type == 'CCF') {
                    if (field.elementID.slice(-1) != allFields[i].elementID.slice(-1)) {
                        isDependant = false;
                    }
                }
                if (isDependant) {
                    field.dependants.push(i);
                }

            }
        }
    }
    if (!field.start_value) {
        field.start_value = val;
    }

    var ddDiff = val - field.start_value;

    for (var a = 0; a < field.dependants.length; a++) {
        var df = allFields[field.dependants[a]];
        if (!df || !df.elementID) {
            continue;
        }
        // var currDate = $('#' + df.elementID).val();
        var currDate = $('#' + df.elementID).val();
        var startToUse = (new Date(currDate)).getTime();
        /*var startToUse = df.start_value;
        if (makeDatesRelativeToToday) {
            startToUse = (new Date()).getTime();
        }*/
        if (startToUse) {
            if (!('lastDD' in df)) {
                df.lastDD = field.start_value;
            }
            if (!df.lastDD) {
                df.lastDD = 0;
            }
            var ddDiff = val - df.lastDD;
            var newDateTime = startToUse + df.dateFormula.dd * ddDiff * 24 * 60 * 60 * 1000;
            df.lastDD = val;
            //console.log(df.elementID, df.lastDD, ddDiff)
            //var val = formatDateForView(newDate);
            var newDate = new Date(newDateTime);
            $('#' + df.elementID).datepicker('setDate', newDate);
            $('#' + df.elementID).datepicker('setInputValue', formatDateForView(newDate)); // update input box
            $('#' + df.elementID).trigger('change');
        }
    }
}

function generateFormErrorMessage(field) {
    var value = "character";
    if (field.field_type == "accountnum" || field.field_type == "int") {
        value = "digit";
    }
    var errorMessage = "The field has to be ";
    if (field.max_length == field.min_length) {
        if (field.min_length != 1) {
            value += 's';
        }
        errorMessage += field.min_length + " " + value + " long";
    } else {
        errorMessage += field.min_length + " to " + field.max_length + " " + value + " long";
    }
    return errorMessage;
}

function getStringField(field) {
    var errorMessage = generateFormErrorMessage(field);
    var valClass = "";
    if (field.is_required) {
        valClass = "validate";
    }
    var fieldHtml = '<div class="input-field col u-cf-field" ' + field.styleStr + ' >' +
        '<input id= "' + field.elementID + '" type="text" class="' + valClass + '" value="' + encodeForHTML(field.value) + '">' +
        '<label for="' + field.elementID + '">' + field.display_name + '</label>' +
        '<span class="helper-text" data-error="' + errorMessage + '" data-success=""></span>' +
        '</div>';
    var elementID = field.elementID;
    var field_id = field.field_id;
    return {
        html: fieldHtml,
        onAfterRender: function () {
            $('#' + elementID).on('input', function () {
                //allFields[field_id].is_valid = true;
                //checkValidForm();
            });
        }
    };
}

function checkValidForm() {
    if (!formValid) {
        formValid = true; // to check
        $('#u-nc-dial-btn').removeClass('disabled');
    }
}

function getEnumField(field) {
    var options = [];
    var vals = [];
    if (field.type_params) {
        vals = field.type_params.split(',');
        //vals = vals.map(val => val.trim());
        jQuery.map(vals, function () {
            vals = vals.trim();
        });
    }
    if (!field.value) {
        if (field.field_name == "PhoneType") {
            // inject user phone data
            if (userObj.home_phone) {
                var index = vals.indexOf("HOME");
                if (index > -1) {
                    options.push('<option value="HOME" selected>HOME</option>');
                    vals.splice(index, 1);
                } else {
                    options.push('<option value="" disabled selected></option>');
                }
            } else if (userObj.cell_phone) {
                var index = vals.indexOf("CELL");
                if (index > -1) {
                    options.push('<option value="CELL" selected>CELL</option>');
                    vals.splice(index, 1);
                } else {
                    options.push('<option value="" disabled selected></option>');
                }
            } else {
                options.push('<option value="" disabled selected></option>');
            }
        } else {
            options.push('<option value="" disabled selected></option>');
        }
    }
    for (var a = 0; a < vals.length; a++) {
        var selectedString = '';
        var v = vals[a].trim();
        if (v == field.value) {
            selectedString = 'selected';
        }
        options.push('<option value="' + v + '" ' + selectedString + '>' + v + '</option>')
    }
    var fieldHtml = '<div class="input-field col u-cf-field"  ' + field.styleStr + ' ><select id="' + field.elementID + '">' + options.join(' ') +
        //'<input id="' + field.elementID + '" type="text" maxlength="22">' +
        //'<label for="' + field.elementID + '">' + field.display_name + '</label>' +
        '</select><label>' + field.display_name + '</label</div>';
    var elementID = field.elementID;
    var fieldName = field.field_name
    return {
        html: fieldHtml,
        onAfterRender: function () {
            $('#' + elementID).formSelect();
            if (fieldName != "PhoneType") {
                return;
            }
            $(document).on('change', '#' + elementID, function () {
                var phoneElementId = '';
                for (i in allFields) {
                    if (allFields[i].field_name == "Phone") {
                        phoneElementId = allFields[i].elementID;
                        break;
                    }
                }
                if (!phoneElementId) {
                    return;
                }
                var phoneElement = $('#' + phoneElementId);
                if ($(this).val() == 'HOME' && userObj.home_phone) {
                    phoneElement.val(userObj.home_phone);
                    phoneElement.parent().find('label').addClass("active");
                } else if (userObj.cell_phone) {
                    phoneElement.val(userObj.cell_phone);
                    phoneElement.parent().find('label').addClass("active");
                }
            });
        }
    };
}

function getBooleanField(field) {
    var checkedYesStr = '';
    var checkedNoStr = 'checked';
    if (field.value && field.value != "0") {
        checkedYesStr = 'checked';
        checkedNoStr = '';
    }
    var fieldHtml = '<div class="col u-cf-field"  ' + field.styleStr + ' >' +
        '<span class="u-radio-desc">' + field.display_name + '</span>' +
        '<label>' +
        '<input name="' + field.elementID + '" type="radio" value="1" ' + checkedYesStr + ' />' +
        '<span>Yes</span>' +
        '            </label >' +
        '<label>' +
        '    <input name="' + field.elementID + '" type="radio" value="0" ' + checkedNoStr + '/>' +
        '   <span>No</span>' +
        '</label>' +
        '</div>';
    var elementID = field.elementID;
    return {
        html: fieldHtml,
        onAfterRender: function () {

        }
    };
}

function getMoneyField(field) {
    var errorMessage = generateFormErrorMessage(field);
    var valClass = "";
    if (field.is_required) {
        valClass = "validate";
    }
    var fieldHtml = '<div class="input-field col u-cf-field"  ' + field.styleStr + ' >' +
        '<input id= "' + field.elementID + '" class="' + valClass + '" type="text" maxlength="25" value="' + encodeForHTML(field.value) + '">' +
        '<label for="' + field.elementID + '">' + field.display_name + '</label>' +
        '<span class="helper-text" data-error="' + errorMessage + '" data-success=""></span>' +
        '</div>';
    var elementID = field.elementID;
    var maxLength = field.max_length;
    return {
        html: fieldHtml,
        onAfterRender: function () {
            var digits = 0;
            if (maxLength == 13 || maxLength == 12) {
                digits = 2;
            }
            $('#' + elementID).inputmask({
                alias: "currency",
                prefix: '$ ',
                allowMinus: false,
                autoUnmask: true,
                shortcuts: false,
                showMaskOnHover: false,
                rightAlign: false,
                digits: digits
            });
        }
    };
}

function getAccountField(f) {
    var field = f;
    var errorMessage = generateFormErrorMessage(field);
    var valClass = "";
    if (field.is_required) {
        valClass = "validate";
    }

    var fieldHtml = '<div class="input-field col u-cf-field"  ' + field.styleStr + ' >' +
        '<input id= "' + field.elementID + '" class="' + valClass + '" type="text" value="' + encodeForHTML(field.value) + '">' +
        '<label for="' + field.elementID + '">' + field.display_name + '</label>' +
        '<span class="helper-text" data-error="' + errorMessage + '" data-success=""></span>' +
        '</div>';
    var elementID = field.elementID;

    return {
        html: fieldHtml,
        onAfterRender: function () {
            $('#' + elementID).inputmask({ mask: '9999 9999 9999 9999', placeholder: '', showMaskOnHover: false, autoUnmask: true });
        }
    };
}

function getPhoneField(f) {
    var field = f;
    var errorMessage = generateFormErrorMessage(field);
    var valClass = "";
    var fieldVal = field.value;
    if (field.is_required) {
        valClass = "validate";
    }
    if (!fieldVal) {
        // inject user phone data
        if (userObj.home_phone) {
            fieldVal = userObj.home_phone;
        } else if (userObj.cell_phone) {
            fieldVal = userObj.cell_phone;
        }
    }

    var fieldHtml = '<div class="input-field col u-cf-field" ' + field.styleStr + ' >' +
        '<input id= "' + field.elementID + '" type="text" class="' + valClass + '" value="' + encodeForHTML(fieldVal) + '">' +
        '<label for="' + field.elementID + '">' + field.display_name + '</label>' +
        '<span class="helper-text" data-error="' + errorMessage + '" data-success=""></span>' +
        '</div>';
    var elementID = field.elementID;

    return {
        html: fieldHtml,
        onAfterRender: function () {
            $('#' + elementID).inputmask({ mask: '999 999 9999', placeholder: '', showMaskOnHover: false, autoUnmask: true });
        }
    };
}

function insertPreloader(elID) {
    $(elID).html('<div class="preloader-wrapper small active">' +
        '  <div class="spinner-layer spinner-blue-only">' +
        '    <div class="circle-clipper left">' +
        '      <div class="circle"></div>' +
        '    </div><div class="gap-patch">' +
        '      <div class="circle"></div>' +
        '    </div><div class="circle-clipper right">' +
        '      <div class="circle"></div>' +
        '    </div>' +
        '  </div>' +
        '</div>');
}

function getIntField(f) {
    var field = f;
    var errorMessage = generateFormErrorMessage(field);
    var valClass = "";
    if (field.is_required) {
        valClass = "validate";
    }
    var fieldHtml = '<div class="input-field col u-cf-field"  ' + field.styleStr + ' >' +
        '<input id= "' + field.elementID + '" class="' + valClass + '" type="text" value="' + encodeForHTML(field.value) + '">' +
        '<label for="' + field.elementID + '">' + field.display_name + '</label>' +
        '<span class="helper-text" data-error="' + errorMessage + '" data-success=""></span>' +
        '</div>';
    var elementID = field.elementID;

    return {
        html: fieldHtml,
        onAfterRender: function () {
            $('#' + elementID).inputmask({ mask: '9{' + field.min_length + "," + field.max_length + '}', showMaskOnHover: false, placeholder: '', autoUnmask: true });
        }
    };
}

function processDateFormula(formula) {
    var ddStart = formula.indexOf('dd');
    var dd = 0;
    var otherPart = formula;
    if (ddStart >= 0) {
        var isDDPositive = true;
        var ddLength = 2;
        if (ddStart > 0) {
            var ddSign = formula.charAt(ddStart - 1);
            if (ddSign == '-') {
                isDDPositive = false;
            }
            ddStart = ddStart - 1;
            ddLength = 3;
        }
        if (ddStart == 0) {
            otherPart = formula.substring(ddLength);
        } else {
            otherPart = formula.substring(0, formula.length - ddLength);
        }
        //console.log(otherPart, ddStart, ddLength)

        dd = -1;
        if (isDDPositive) {
            dd = 1;
        }

    }
    if (!otherPart) {
        otherPart = 0;
    }

    return {
        otherPart: otherPart,
        str: formula,
        dd: dd,
        addDays: parseInt(otherPart)
    }
}

function getDateField(f) {
    var field = f;
    var val = field.value;
    var elementID = field.elementID;
    field.allowFuture = true;
    var isRequired = true;
    if (!field.is_required) {
        isRequired = false;
    }
    field.origValue = val;
    if (val) {
        field.origValue = new Date(val);
    }
    if (field.type_params) {
        var ps = field.type_params.split(',');

        for (var a = 0; a < ps.length; a++) {
            var param = ps[a];
            param = param.trim().toLowerCase();
            param = param.replaceAll(' ', '');
            if (param == "allowfuture=false") {
                field.allowFuture = false;
            }
            if (param.indexOf('formula=') == 0) {
                field.dateFormula = processDateFormula(param.substring(8));
            }
        }
    }
    if (!val && field.dateFormula) {
        var dateToShow = calculateFormulaDate(field)
        field.value = dateToShow;
    }
    if (field.value) {
        field.start_value = (new Date(field.value)).getTime();
    }
    var errorMessage = "Please enter a valid date";
    //console.log(field.field_name + " 0 " + allowFuture)
    var clearHTML = '';
    var clearID = 0;
    if (!isRequired) {
        clearID = generateNextElementID();
        clearHTML = '<i id="' + clearID + '" class="small material-icons u-field-clear-btn">clear</i>'
    }
    var fieldHtml = '<div class="input-field col u-cf-field"  ' + field.styleStr + ' >' +
        '<input id= "' + field.elementID + '" type= "text" class="datepicker" value="' + encodeForHTML(field.value) + '">' +
        '<label for="' + field.elementID + '">' + field.display_name + '</label>' + clearHTML
    '<span class="helper-text" data-error="' + errorMessage + '" data-success=""></span>' +
        '</div>';

    return {
        html: fieldHtml,
        onAfterRender: function () {
            var initObj = {
                onSelect: function (val) {
                    //console.log("SLEECTED!!!", val)
                }
            };
            if (!field.allowFuture) {
                initObj.maxDate = new Date();
            }
            if (!isRequired) {
                initObj.showClearBtn = true;

                $('#' + clearID).click(function () {
                    $('#' + elementID).datepicker('setDate', '');
                    $('#' + elementID).datepicker('setInputValue'); // update input box
                });
                $('#' + clearID).hide(); // hide clear button by default
                $('#' + elementID).change(function (var1, var2) {

                    // display that clear button only when there is a value
                    var v = $('#' + elementID).val();
                    if (v) {
                        $('#' + clearID).fadeIn();
                    } else {
                        $('#' + clearID).fadeOut();
                    }
                })
            }
            $('#' + elementID).datepicker(initObj);
            if (val) {
                $('#' + elementID).datepicker('setDate', new Date(val));
                $('#' + elementID).trigger('change'); // fire change event to show clear button
            }

            $('#' + elementID).on('focus', function (con) {
                $('#' + elementID).datepicker('open');
                //console.log(con);
            })
        }
    };
}


function getFormValues(skipValidation) {
    var submitValues = {};
    var hasError = false;
    let lowestErrorOffset = 99999;
    let highestInvalidElement = '';
    for (var field_id in allFields) {
        var field = allFields[field_id];
        var fieldValue = getFieldValue(field);
        if (field.is_required) {
            var fieldStrValue = "" + fieldValue;
            var elSelector = '#' + field.elementID;
            if (field.field_type == 'enum') {
                var instance = M.FormSelect.getInstance($(elSelector)[0]);
                elSelector = instance.input;
            }
            if (!skipValidation) {
                if (!fieldStrValue.length || fieldStrValue.length < field.min_length || fieldStrValue.length > field.max_length) {
                    hasError = true;
                    $(elSelector).addClass('invalid');
                    $(elSelector).removeClass('valid');
                    // find highest error as window destination
                    let offsetTop = $(elSelector)[0].getBoundingClientRect().top;
                    if (offsetTop < lowestErrorOffset) {
                        lowestErrorOffset = offsetTop;
                        highestInvalidElement = $(elSelector);
                    }
                } else {
                    $(elSelector).addClass('valid')
                    $(elSelector).removeClass('invalid')
                }
            }

        }
        submitValues[field_id] = fieldValue;
    }

    //console.log("Dialing", submitValues);
    if (hasError && !skipValidation) {
        $([document.documentElement, document.body]).animate({
            scrollTop: highestInvalidElement.offset().top - 90
        }, 500);
        return false;
    } else {
        return submitValues;
    }
}

function addField(field, fieldDef) {
    if (!field.is_exposed) {
        return;
    }
    // Phones and Phone Types should be hidden in Templates
    if (isTemplate && (field.field_name == "Phone")) {
        return;
    }

    if (fieldDef && fieldDef.width) {
        field.width = fieldDef.width;
    }

    var fieldObj = getFieldHTML(field);
    var formID = '#u-form-extra';
    if (fieldDef && fieldDef.form) {
        formID = fieldDef.form;
    }
    if (typeof fieldObj == 'string') {
        // simple addition 
        $(formID).append(fieldObj);
    } else if (fieldObj && fieldObj.html) {
        // complex addition
        $(formID).append(fieldObj.html);
        if (fieldObj.onAfterRender) {
            fieldObj.onAfterRender();
        }
    } else {
        // error
        console.error("Cannot add field", field)
    }
}

function setCommonEventListenersCreateEditCopy() {

    const alwaysAllowed = ['Backspace', 'Enter', 'Tab', 'ArrowLeft', 'ArrowRight', 'Delete'];

    // LANGUAGE
    const languageInput = document.getElementById('u-config-form-language');

    languageInput.addEventListener('change', function (e) {
        if (this.value == '* (ALL LANGUAGES)') {
            this.value = '*';
        }
    });

    // DNIS
    const dnisInput = document.getElementById('u-config-form-dnis');

    dnisInput.addEventListener('change', function () {
        if (this.value.length != 10 && this.value.length != 0 && this.value != '*') {
            this.value = '';
            fireDialog('DNIS must be 10 digits.', 'error', 1500);
        }        
    });

    dnisInput.addEventListener('input', function () {
        if (this.value.length > 10) {
            this.value = this.value.substring(0, 10);
            fireDialog('DNIS must be 10 digits.', 'error', 1500);
        }
    });

    dnisInput.addEventListener('keydown', function (e) {
        const allowedKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab', 'Enter', 'Escape', '*'];

        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }     

        if (e.key == '*' && this.value.length >= 1) {
            fireDialog('DNIS must be numeric or *', 'error', 1500);
            e.preventDefault();
        }        

        if (this.value.includes('*') && this.value.length >= 1 && !alwaysAllowed.includes(e.key)) {
            fireDialog('DNIS must be numeric or *', 'error', 1500);
            e.preventDefault();
        }
    });

    dnisInput.addEventListener('focus', function () {
        if (this.value.length == 12) {
            this.value = this.value.replace(/-/g, "");
        }

        this.labels[0].textContent = "DNIS";
    });

    dnisInput.addEventListener('blur', function () {
        if (this.value.length == 10) {
            this.value = formatPhoneNumber(this.value)
        }        

        if (this.value.length == 0) {
            this.labels[0].textContent = "DNIS (800-123-4567 or *)";
        }         
    });

    // DESTINATION PHONE
    const destinationInput = document.getElementById('u-config-form-destination');

    destinationInput.addEventListener('change', function () {
        if (this.value.length != 10 && this.value.length != 0) {
            this.value = '';
            fireDialog('Destination Phone Number must be 10 digits.', 'error', 1500);
        }
    });

    destinationInput.addEventListener('input', function () {
        if (this.value.length > 10) {
            this.value = this.value.substring(0, 10);
            fireDialog('Destination Phone Number must be 10 digits.', 'error', 1500);
        }
    });

    destinationInput.addEventListener('keydown', function (e) {
        const allowedKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab', 'Enter', 'Escape', '*'];
        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }

        if (e.key == '*' && this.value.length >= 1) {
            fireDialog('Destination Phone Number must be numeric or *', 'error', 1500);
            e.preventDefault();
        }

        if (this.value.includes('*') && this.value.length >= 1 && !alwaysAllowed.includes(e.key)) {
            fireDialog('Destination Phone Number must be numeric or *', 'error', 1500);
            e.preventDefault();
        }
    });

    destinationInput.addEventListener('focus', function () {
        if (this.value.length == 12) {
            this.value = this.value.replace(/-/g, "");
        }

        this.labels[0].textContent = "Destination Phone Number";
    });

    destinationInput.addEventListener('blur', function () {
        if (this.value.length == 10) {
            this.value = formatPhoneNumber(this.value)
        }

        if(this.value.length == 0) {
            this.labels[0].textContent = "Destination (123-456-7890 or *)";
        }
    });

    // PEG
    const pegInput = document.getElementById('u-config-form-peg');

    pegInput.addEventListener('input', function () {
        if (pegInput.value.length > 32) {
            pegInput.value = this.value.substring(0, 32);
            fireDialog('PEG cannot exceed 32 characters.', 'error', 1500);
        }
    });

    pegInput.addEventListener('change', function () {
        if (containsOnlyWhitespace(this.value)) {
            this.value = ''
        }
    });

    // RANK
    const rankInput = document.getElementById('u-config-form-rank');

    rankInput.addEventListener('input', function () {
        if (rankInput.value.length > 6) {
            this.value = this.value.substring(0, 6);
            fireDialog('Rank cannot exceed 6 digits.', 'error', 1500);
        }
    });

    rankInput.addEventListener('keydown', function (e) {
        const allowedKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab', 'Enter', 'Escape', '*'];
        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }

        if (e.key == '*' && this.value.length >= 1) {
            fireDialog('Rank must be numeric or *', 'error', 1500);
            e.preventDefault();
        }

        if (this.value.includes('*') && this.value.length >= 1 && !alwaysAllowed.includes(e.key)) {
            fireDialog('Rank must be numeric or *', 'error', 1500);
            e.preventDefault();
        }
    });

    rankInput.addEventListener('focus', function () {
        if (this.value.length == 12) {
            this.value = this.value.replace(/-/g, "");
        }

        this.labels[0].textContent = "Rank";
    });

    rankInput.addEventListener('blur', function () {
        if (this.value.length == 0) {
            this.labels[0].textContent = "Rank (1-6 or *)";
        }
    });

    // OFFER ID
    const offerIdInput = document.getElementById('u-config-form-offerID');

    offerIdInput.addEventListener('input', function () {
        if (this.value.length > 8) {
            this.value = this.value.substring(0, 8);
            fireDialog('Offer ID cannot exceed 8 characters.', 'error', 1500);
        }        
    });

    offerIdInput.addEventListener('change', function () {
        if (containsOnlyWhitespace(this.value)) {
            this.value = ''
        }
    });

    offerIdInput.addEventListener('keydown', function (e) {
        // Allow alphanumeric and *
        const disallowedKeys = ".,;:?!+-=/|\\<>()[]#$%^&@{}\"\'`~";

        if(disallowedKeys.indexOf(e.key.toLowerCase()) > -1)
            e.preventDefault();

        if (e.key == '*' && this.value.length >= 1) {
            fireDialog('Offer ID must be alphanumeric or *', 'error', 1500);
            e.preventDefault();
        }

        if (this.value.includes('*') && this.value.length >= 1 && !alwaysAllowed.includes(e.key)) {
            fireDialog('Offer ID must be alphanumeric or *', 'error', 1500);
            e.preventDefault();
        }
    });

    offerIdInput.addEventListener('focus', function () {
        this.labels[0].textContent = "Offer ID";
    });

    offerIdInput.addEventListener('blur', function () {
        if (this.value.length == 0) {
            this.labels[0].textContent = "Offer ID (12345678 or *)";
        }
    });
    
    // OFFER TYPE
    const offerTypeInput = document.getElementById('u-config-form-offerType');

    offerTypeInput.addEventListener('input', function () {
        if (this.value.length > 100) {
            this.value = this.value.substring(0, 100);
            fireDialog('Offer Type cannot exceed 100 characters.', 'error', 1500);
        }
    });

    offerTypeInput.addEventListener('change', function () {
        if (containsOnlyWhitespace(this.value)) {
            this.value = ''
        }
    });

    offerTypeInput.addEventListener('keydown', function (e) {
        // Allow alphanumeric and *
        const disallowedKeys = ".,;:?!+-=/|\\<>()[]#$%^&@{}\"\'`~";

        if(disallowedKeys.indexOf(e.key.toLowerCase()) > -1)
            e.preventDefault();   

        if (e.key == '*' && this.value.length >= 1) {
            fireDialog('Offer Type must be alphanumeric or *', 'error', 1500);
            e.preventDefault();
        }

        if (this.value.includes('*') && this.value.length >= 1 && !alwaysAllowed.includes(e.key)) {
            fireDialog('Offer Type must be alphanumeric or *', 'error', 1500);
            e.preventDefault();
        }
    });

    offerTypeInput.addEventListener('focus', function () {
        this.labels[0].textContent = "Offer Type";
    });

    offerTypeInput.addEventListener('blur', function () {
        this.labels[0].textContent = "Offer Type (Citi Strata or *)";
    });

    // SKILL NAME
    const skillNameInput = document.getElementById('u-config-form-skillName');

    skillNameInput.addEventListener('input', function () {
        if (this.value.length > 32) {
            this.value = this.value.substring(0, 32);
            fireDialog('Skill Name cannot exceed 32 characters.', 'error', 1500);
        }
    });

    skillNameInput.addEventListener('change', function () {
        if (containsOnlyWhitespace(this.value)) {
            this.value = ''
        }
    });

    // SKILL ID
    const skillIdInput = document.getElementById('u-config-form-skillId');

    skillIdInput.addEventListener('input', function () {
        if (this.value.length > 10) {
            this.value = this.value.substring(0, 10);
            fireDialog('Skill ID cannot exceed 10 digits.', 'error', 1500);
        }
    });

    skillIdInput.addEventListener('change', function () {
        if (containsOnlyWhitespace(this.value)) {
            this.value = ''
        }
    });

    skillIdInput.addEventListener('keydown', function (e) {
        const allowedKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab', 'Enter', 'Escape'];
        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }
    });

    // AGENTS AVAILABLE
    const agentsAvailableInput = document.getElementById('u-config-form-agentsAvailable');

    agentsAvailableInput.addEventListener('input', function () {
        if (this.value.length > 3) {
            this.value = this.value.substring(0, 3);
            fireDialog('Agents Available cannot exceed 3 digits.', 'error', 1500);
        }
    });

    agentsAvailableInput.addEventListener('keydown', function (e) {
        const allowedKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab', 'Enter', 'Escape'];
        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }
    });

    // MED
    const medInSecondsInput = document.getElementById('u-config-form-medInSeconds');

    medInSecondsInput.addEventListener('input', function () {
        if (this.value.length > 3) {
            this.value = this.value.substring(0, 3);
            fireDialog('MED cannot exceed 3 digits.', 'error', 1500);
        }
    });

    medInSecondsInput.addEventListener('keydown', function (e) {
        const allowedKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab', 'Enter', 'Escape'];
        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }
    });

    // OVERFLOW SKILL NAME
    const overflowSkillNameInput = document.getElementById('u-config-form-overflowSkillName');

    overflowSkillNameInput.addEventListener('input', function () {
        if (this.value.length > 32) {
            this.value = this.value.substring(0, 32);
            fireDialog('Overflow Skill Name cannot exceed 32 characters.', 'error', 1500);
        }
    });

    overflowSkillNameInput.addEventListener('change', function () {
        if (containsOnlyWhitespace(this.value)) {
            this.value = ''
        }
    });

    // OVERFLOW SKILL ID
    const overflowSkillIdInput = document.getElementById('u-config-form-overflowSkillId');

    overflowSkillIdInput.addEventListener('input', function () {
        if (this.value.length > 10) {
            this.value = this.value.substring(0, 10);
            fireDialog('Overflow Skill ID cannot exceed 10 digits.', 'error', 1500);
        }
    });

    overflowSkillIdInput.addEventListener('change', function () {
        if (containsOnlyWhitespace(this.value)) {
            this.value = ''
        }
    });

    overflowSkillIdInput.addEventListener('keydown', function (e) {
        const allowedKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab', 'Enter', 'Escape'];
        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }
    });

    // OVERFLOW AGENTS
    const overflowAgentsAvailableInput = document.getElementById('u-config-form-overflowAgentsAvailable');

    overflowAgentsAvailableInput.addEventListener('input', function () {
        if (this.value.length > 3) {
            this.value = this.value.substring(0, 3);
            fireDialog('Overflow Agents Available cannot exceed 3 digits.', 'error', 1500);
        }
    });

    overflowAgentsAvailableInput.addEventListener('keydown', function (e) {
        const allowedKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab', 'Enter', 'Escape'];
        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }
    });

    // OVERFLOW MED
    const overflowMedInput = document.getElementById('u-config-form-overflowMed');

    overflowMedInput.addEventListener('input', function () {
        if (this.value.length > 3) {
            this.value = this.value.substring(0, 3);
            fireDialog('Overflow MED cannot exceed 3 digits.', 'error', 1500);
        }
    });

    overflowMedInput.addEventListener('keydown', function (e) {
        const allowedKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab', 'Enter', 'Escape'];
        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }
    });


    $('#u-resetBasicFilters-queue-btn').on('click', function () {
        resetQueueFilters();
    });
}

// adds a label to the form. Does not get submitted
function addLabelField(fieldDef) {
    var formID = '#u-form-extra';
    if (fieldDef && fieldDef.form) {
        formID = fieldDef.form;
    }
    // calculate the style
    if (fieldDef.width) {
        fieldDef.style = 'width: ' + fieldDef.width;
    }
    if (fieldDef.style) {
        fieldDef.styleStr = ' style="' + fieldDef.style + '"';
    } else {
        fieldDef.styleStr = '';
    }

    $(formID).append('<div class="u-form-label" ' + fieldDef.styleStr + '>' + fieldDef.text + '</div>');
}

function setFrameSize() {
    var $window = $(window),
        $html = $('body');
    $html.removeClass('large-frame');
    $html.removeClass('small-frame');

    if ($window.height() < 600) {
        return $html.addClass('small-frame');
    }
    else if ($window.height() > 600 && $window.height() < 800) {
        return $html.addClass('small-frame');
    }
    else if ($window.height() > 800 && $window.height() < 900) {
        return $html.addClass('large-frame');
    }
    else if ($window.height() > 900) {
        return $html.addClass('large-frame');
    }
}


// Gets the type of browser
function detectBrowser() {
    if ((navigator.userAgent.indexOf("Opera") || navigator.userAgent.indexOf('OPR')) != -1) {
        return 'Opera';
    } else if (navigator.userAgent.indexOf("Chrome") != -1) {
        return 'Chrome';
    } else if (navigator.userAgent.indexOf("Safari") != -1) {
        return 'Safari';
    } else if (navigator.userAgent.indexOf("Firefox") != -1) {
        return 'Firefox';
    } else if ((navigator.userAgent.indexOf("MSIE") != -1) || (!!document.documentMode == true)) {
        return 'IE';//crap
    } else {
        return 'Unknown';
    }
}


function fireDialog(myText, type, time, pos) {
    // set default to optional arg
    if (pos === undefined) {
        pos = 'top'
    }

    const Toast = Swal.mixin({
        toast: true,
        position: pos,
        //position: 'center',
        showConfirmButton: false,
        timer: time
    });
    Toast.fire({
        icon: type,
        title: myText
    });
}


function logoutUser() {
    $.post("./api/Logout.ashx",
        {
            performerUserEmail: performerUserEmail
        },
        function (data, status) {
            localStorage.setItem('email', null);
            localStorage.setItem('activityTimer', null)
            performerUserEmail = '';
            window.location.href = './Login.tsx';
        }
    );
}

function compareStrings(a, b) {
    a = a.toLowerCase();
    b = b.toLowerCase();

    return (a < b) ? -1 : (a > b) ? 1 : 0;
}

function getTimeZoneOffset(date, timeZone) {

    // Abuse the Intl API to get a local ISO 8601 string for a given time zone.
    let iso = date.toLocaleString('en-CA', { timeZone, hour12: false }).replace(', ', 'T');

    // Include the milliseconds from the original timestamp
    iso += '.' + date.getMilliseconds().toString().padStart(3, '0');

    // Lie to the Date object constructor that it's a UTC time.
    const lie = new Date(iso + 'Z');

    // Return the difference in timestamps, as minutes
    // Positive values are West of GMT, opposite of ISO 8601
    // this matches the output of `Date.getTimeZoneOffset`
    return -(lie - date) / 60 / 1000;
}

function checkIfUserStillExists() {
    var searchObj = {
        lookupUserName: localStorage.getItem('email')
    };

    return $.post("./api/GetFullUser.ashx", searchObj,
        function (data) {
            data = JSON.parse(data);

            if (data.isDeleted) {
                logoutUser()
            }
        }
    );
}

function isValidDateFormat(dateString) {
    // Regular expression for "MMM DD, YYYY" format.
    const monthDayYearRegex = /^(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s(0[1-9]|[12][0-9]|3[01]),\s\d{4}$/;

    // Regular expression for "MM/DD/YYYY" format.
    // Breakdown of the regex:
    // ^                   - Start of the string
    // (0[1-9]|1[0-2])     - Matches a two-digit month (01-12)
    // \/                  - Matches a literal forward slash (escaped)
    // (0[1-9]|[12][0-9]|3[01]) - Matches a two-digit day (01-31)
    // \/                  - Matches a literal forward slash (escaped)
    // \d{4}               - Matches exactly four digits for the year
    // $                   - End of the string

    //const numericDateRegex = /^(0[1-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01])\/\d{4}$/; // This allows 06/05/2025
    const onlyNumbers = /^\d+$/;
    const dateStringNoWhiteSapce = dateString.replace(/\s/g, '')
    // Test the string against both regular expressions
    return monthDayYearRegex.test(dateString) || (dateStringNoWhiteSapce.length == 8 && onlyNumbers.test(dateStringNoWhiteSapce)); // 8 allows dates of the format 06052025 per Emily's request
}

function formatMMDDYYYY(cleanedDate) {
    // Ensure the input is treated as a string
    var dateStr = String(cleanedDate);

    // Check if the string is exactly 8 digits long
    // For a "cleaned" date, we assume it already only contains digits.
    // If you need to enforce only digits, add a regex check here:
    // if (!/^\d{8}$/.test(dateStr)) {
    //   console.warn("Input date is not an 8-digit number string:", cleanedDate);
    //   return cleanedDate; // Return original if not valid
    // }
    dateStr = dateStr.replace(/\s/g, '');

    if (dateStr.length === 8) {
        const month = dateStr.slice(0, 2);
        const day = dateStr.slice(2, 4);
        const year = dateStr.slice(4, 8);

        return `${month}/${day}/${year}`;
    } else {
        // If the string is not 8 digits, return it as is or handle the error
        return cleanedDate;
    }
}

function containsOnlyWhitespace(str) {
    // The regex /^\s*$/g checks:
    // ^       - start of the string
    // \s* - zero or more whitespace characters (space, tab, newline, etc.)
    // $       - end of the string
    return /^\s*$/.test(str);
}
