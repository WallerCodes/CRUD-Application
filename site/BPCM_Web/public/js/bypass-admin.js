var showDeleted = false;
var performerUserEmail = '';
var UsersTable = '';
var HistoryTable = '';

var userData = {};
var actionData = {};

var affectedUserId;


var userColumns = [
    {
        data: "userName", title: "User Name", render: function (data, type, row, meta) {
            return data;
        }
    },
    {
        data: "isSuperAdmin", title: "Super Admin", editable: false, render: function (data, type, row, meta) {
            var checkedStr = '';
            if (data === true) {
                checkedStr = 'checked="checked"';
            }

            return '<label class="u-grid-checkbox"><input type="checkbox" ' + checkedStr + ' onclick="adminRoleChange(\'' + row.userName + '\', ' + data + ', ' + meta.row + ')"/><span></span></label>';
        }
    },
    {
        data: "isUsanUser", title: "USAN User", editable: false, render: function (data, type, row, meta) {
            var checkedStr = '';
            if (data === true) {
                checkedStr = 'checked="checked"';
            }

            return '<label class="u-grid-checkbox"><input type="checkbox" ' + checkedStr + ' onclick="usanUserRoleChange(\'' + row.userName + '\', ' + data + ', ' + meta.row + ')"/><span></span></label>';
        }
    },
    {
        data: "id", title: "Edit Access Level", editable: false, sortable: false, render: function (data, type, row, meta) {
            return '<img class="u-access-level-config u-grid-icon material-icons" title="Edit Access Level" src="./public/images/user-management.png" onclick="openEditUserLPRolesModal(' + data + ', \'' + row.userName + '\')">';
        }
    },
    {
        data: "lastLogin", title: "Last Logged In", class: 'rec-date', render: function (data, type, row, meta) {
            var displayValue = 'NEVER';
            var d = new Date(data);

            // calc offset between browser and CST
            var tzOffset = (d.getTimezoneOffset() - getTimeZoneOffset(d, 'America/Winnipeg'));

            if (d && d instanceof Date) {
                var diff = (new Date()).getTime() - d.getTime();
                var diffM = (diff / 1000 / 60) + tzOffset;
                if (diffM < 1) {
                    displayValue = 'Just now';
                } else if (diffM < 60) {
                    var minute = Math.floor(diffM)
                    displayValue = minute + (minute > 1 ? ' mins' : ' min') + ' ago';
                } else {
                    var diffH = diffM / 60;
                    if (diffH < 24) {
                        var hour = Math.floor(diffH);
                        displayValue = hour + (hour > 1 ? ' hours' : ' hour') + ' ago';
                    } else {
                        var diffD = diffH / 24;
                        if (diffD > 10000) {
                            displayValue = 'NEVER';
                        } else if (diffD > 365) {
                            displayValue = 'Over a year ago';
                        } else {
                            var day = Math.floor(diffD);
                            displayValue = day + (day > 1 ? ' days' : ' day') + ' ago';
                        }

                    }
                }
            }
            return displayValue;
        }
    },
    {
        data: "id", title: "Reset Password", orderable: false, visible: superAdmin, render: function (data, type, row, meta) {
            if (superAdmin) {
                return '<img class="u-pw-reset u-grid-icon material-icons" title="Reset Password" src="./public/images/reset-password.png" onclick="openPasswordResetModal(' + data + ', \'' + row.userName + '\')">';
            } else {
                return "";
            }
        }
    },
    {
        data: "id", title: "Delete User", orderable: false, render: function (data, type, row, meta) {
            return '<img style="margin-left:15px;margin-top:-5px;" class="u-trash u-grid-icon material-icons red-text text-darken-4" title="Delete user" src="./public/images/trash.png" onclick="deleteUser(' + data + ', \'' + row.userName + '\')">';
        }
    }
];


var historyColumns = [
    {
        data: "actionTime", title: "Timestamp", width: "16%", class: 'rec-date', render: function (data, type, row, meta) {
            try {
                var dateStr = formatDate(data);

                return dateStr;
            } catch (err) {
                return data;
            }
        }
    },
    {
        data: "performerUserName", title: "Performing User", width: "15%", render: function (data, type, row, meta) {
            return data;
        }
    },
    {
        data: "affectedUserName", title: "Affected User", width: "15%", render: function (data, type, row, meta) {
            return data;
        }
    },
    {
        data: "action", title: "Action", width: "15%", render: function (data, type, row, meta) {
            var displayData = data;

            if (data == "Create Queue" || data == "Create TOD Plan" || data == "Update Port Limits" || data == "Change User Role"
                || data == "Update TOD Plan" || data == "Delete TOD Plan" || data == "Create TOD Plan Entry" || data == "Delete TOD Plan Entry"
                || data == "Update TOD Plan Entry" || data == "Update User" || data == "Update Queue" || data == "Delete Queue") {
                var afterVal = row.afterValue;

                afterVal = afterVal.replace("true", "<div style=\"margin-left: -2em; float: right; margin-right: 2em; margin-top: -0.4em; \"><i class=\"material-icons u-grid-success-yes green-text\">check</i></div>").replace("false", "<div style=\"margin-left: -2em; float: right; margin-right: 2em; margin-top: -0.4em;\"><i class=\"material-icons u-grid-success-no\">close</i></div>");

                displayData += " - " + afterVal;
            }

            return displayData;
        }
    }
];


var roleColumns = [
    { title: "User Name", data: "userName", editable: false },
    { title: "Application", data: "application", editable: false },
    {
        title: "None",
        data: "accessLevelNone",
        orderable: false,
        render: function (data, type, row, meta) {
            var checkedStr = '';
            if (data === true) {
                checkedStr = 'checked="checked"';
            }

            return '<label class="u-grid-checkbox"><input type="checkbox" ' + checkedStr + ' onclick="roleChange(\'' + row.application + '\',\'' + AccessLevel.None + '\', ' + data + ', ' + meta.row + ')"/><span></span></label>';
        }
    },
    {
        title: "View",
        data: "accessLevelRead",
        orderable: false,
        render: function (data, type, row, meta) {
            var checkedStr = '';
            if (data === true) {
                checkedStr = 'checked="checked"';
            }

            return '<label class="u-grid-checkbox"><input type="checkbox" ' + checkedStr + ' onclick="roleChange(\'' + row.application + '\',\'' + AccessLevel.Read + '\', ' + data + ', ' + meta.row + ')"/><span></span></label>';
        }
    },
    {
        title: "Edit",
        data: "accessLevelEdit",
        orderable: false,
        render: function (data, type, row, meta) {
            var checkedStr = '';
            if (data === true) {
                checkedStr = 'checked="checked"';
            }

            return '<label class="u-grid-checkbox"><input type="checkbox" ' + checkedStr + ' onclick="roleChange(\'' + row.application + '\',\'' + AccessLevel.Edit + '\', ' + data + ', ' + meta.row + ')"/><span></span></label>';
        }
    },
    {
        title: "Update Users",
        data: "accessLevelAdmin",
        orderable: false,
        render: function (data, type, row, meta) {
            var checkedStr = '';
            if (data === true) {
                checkedStr = 'checked="checked"';
            }

            return '<label class="u-grid-checkbox"><input type="checkbox" ' + checkedStr + ' onclick="roleChange(\'' + row.application + '\',\'' + AccessLevel.Admin + '\', ' + data + ', ' + meta.row + ')"/><span></span></label>';
        }
    }
];


$(document).ready(function () {

    setUnderline();

    $(window).scroll(function () {

        if ($('#u-admin-users-table').is(':visible')) {
            UsersTable.fixedHeader.enable();

            if (!isEmpty(HistoryTable)) {
                HistoryTable.fixedHeader.disable();
            }
        }
        else if ($('#u-admin-history-table').is(':visible')) {
            UsersTable.fixedHeader.disable();

            HistoryTable.fixedHeader.enable();

        }
    });

    setFrameSize();

    $('.tabs').tabs();

    checkRoles(performerUserEmail).then(function (data) {
        setupUserDatatable();

        getUserFilterDropdownValues();

        assignEventListeners();

        observeDropdowns();
    });
});

function observeDropdowns() { // Per request deactivated, this should only be active for fields that are dropdowns that cannot be typed in.
    //observeSpecificDropdown('u-history-form-user-performer');
    //observeSpecificDropdown('u-history-form-user-affected');
    //observeSpecificDropdown('u-history-form-action');

    //observeSpecificDropdown('u-user-form-username');
}

function observeSpecificDropdown(dropdownId) {

    // We are doing this because we still want the 'x' button for clearing but also want the fields to be readonly
    const applicationInput = document.getElementById(dropdownId);
    const parentElement = applicationInput.parentElement;

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
                            if (dropdownId == 'u-history-form-user-performer' ||
                                dropdownId == 'u-history-form-user-affected' ||
                                dropdownId == 'u-user-form-username') { // User dropdowns
                                fullUsersList.forEach((element) => {
                                    dropdown.innerHTML += `<li><span><span class="highlight"></span>${element}</span></li>`;
                                });
                            }
                            else {
                                actionData.forEach((element) => { // Actions
                                    dropdown.innerHTML += `<li><span><span class="highlight"></span>${element.action}</span></li>`;
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

function setUnderline() {
    const currentMenuItem = document.getElementById('admin-menu-option');
    currentMenuItem.style.textDecoration = 'underline';
}

function setupUserDatatable() {
    UsersTable = $('#users-datatable').DataTable({
        orderCellsTop: true,
        select: false,
        paging: true,
        dom: 't<"table-footer"flip>',
        serverSide: true,
        searching: false,
        fixedHeader: true,
        bInfo: true,
        order: [[0, "asc"]],
        pagingType: "full_numbers",
        ajax: {
            url: "./api/GetUsersTable.ashx",
            data: function (d) {
                d.performerUserEmail = performerUserEmail;
                d.lookupUserName = $('#u-user-form-username').val();

                var sortCol = -1;
                var sortDir = "";

                if (d.order.length > 0) {
                    sortCol = d.order[0].column;
                    sortDir = d.order[0].dir;
                }

                if (sortCol == 0) {
                    d.sort = "userName";
                }
                else if (sortCol == 1) {
                    d.sort = "isSuperAdmin";
                }
                else if (sortCol == 2) {
                    d.sort = "isUsanUser";
                }
                else if (sortCol == 4) {
                    d.sort = "lastLoginDate";
                }


                d.sortDir = sortDir;
            }
        },
        aoColumns: [
            {
                data: "userName", title: "User Name", render: function (data, type, row, meta) {
                    return data;
                }
            },
            {
                data: "isSuperAdmin", title: "Super Admin", editable: false, render: function (data, type, row, meta) {
                    var checkedStr = '';
                    if (data === true) {
                        checkedStr = 'checked="checked"';
                    }

                    return '<label class="u-grid-checkbox"><input type="checkbox" ' + checkedStr + ' onclick="adminRoleChange(\'' + row.userName + '\', ' + data + ', ' + meta.row + ')"/><span></span></label>';
                }
            },
            {
                data: "isUsanUser", title: "USAN User", editable: false, render: function (data, type, row, meta) {
                    var checkedStr = '';
                    if (data === true) {
                        checkedStr = 'checked="checked"';
                    }

                    return '<label class="u-grid-checkbox"><input type="checkbox" ' + checkedStr + ' onclick="usanUserRoleChange(\'' + row.userName + '\', ' + data + ', ' + meta.row + ')"/><span></span></label>';
                }
            },
            {
                data: "id", title: "Edit Access Level", editable: false, sortable: false, render: function (data, type, row, meta) {
                    return '<img class="u-access-level-config u-grid-icon material-icons" title="Edit Access Level" src="./public/images/user-management.png" onclick="openEditUserLPRolesModal(' + data + ', \'' + row.userName + '\')">';
                }
            },
            {
                data: "lastLogin", title: "Last Logged In", class: 'rec-date', render: function (data, type, row, meta) {
                    var displayValue = 'NEVER';
                    var d = new Date(data);

                    // calc offset between browser and EST
                    var tzOffset = (d.getTimezoneOffset() - getTimeZoneOffset(d, 'America/New_York')); // Set this to whatever TZ client wants

                    if (d && d instanceof Date) {
                        var diff = (new Date()).getTime() - d.getTime();
                        var diffM = (diff / 1000 / 60) + tzOffset;
                        if (diffM < 1) {
                            displayValue = 'Just now';
                        } else if (diffM < 60) {
                            var minute = Math.floor(diffM)
                            displayValue = minute + (minute > 1 ? ' mins' : ' min') + ' ago';
                        } else {
                            var diffH = diffM / 60;
                            if (diffH < 24) {
                                var hour = Math.floor(diffH);
                                displayValue = hour + (hour > 1 ? ' hours' : ' hour') + ' ago';
                            } else {
                                var diffD = diffH / 24;
                                if (diffD > 10000) {
                                    displayValue = 'NEVER';
                                } else if (diffD > 365) {
                                    displayValue = 'Over a year ago';
                                } else {
                                    var day = Math.floor(diffD);
                                    displayValue = day + (day > 1 ? ' days' : ' day') + ' ago';
                                }

                            }
                        }
                    }
                    return displayValue;
                }
            },
            {
                data: "id", title: "Reset Password", orderable: false, visible: superAdmin, render: function (data, type, row, meta) {
                    if (superAdmin) {
                        return '<img class="u-pw-reset u-grid-icon material-icons" title="Reset Password" src="./public/images/reset-password.png" onclick="openPasswordResetModal(' + data + ', \'' + row.userName + '\')">';
                    } else {
                        return "";
                    }
                }
            },
            {
                data: "id", title: "Delete User", orderable: false, render: function (data, type, row, meta) {
                    return '<img style="margin-left:15px;margin-top:-5px;" class="u-trash u-grid-icon material-icons red-text text-darken-4" title="Delete user" src="./public/images/trash.png" onclick="deleteUser(' + data + ', \'' + row.userName + '\')">';
                }
            }
        ],
        oLanguage: {
            "sEmptyTable": "No results found",
            "sStripClasses": "",
            "sInfo": "_START_ -_END_ of _TOTAL_",
            "sLengthMenu": '<span>Rows per page:</span><select class="browser-default">' +
                '<option value="10">10</option>' +
                '<option value="25">25</option>' +
                '<option value="50">50</option>' +
                '<option value="100">100</option>' +
                '</select></div>'
        },
        initComplete: function () {
            var api = this.api();

            if (!isUsanUser) {
                api.column(2).visible(false);
            }

            if (!superAdmin) {
                // Hide Super Admin column
                api.column(1).visible(false);
                api.column(6).visible(false);
            }
        }
    });
}


function setupHistoryDatatable() {

    var searchObj = {
        'performerUserEmail': performerUserEmail,
    }

    HistoryTable = $('#history-datatable').DataTable({
        orderCellsTop: true,
        searching: false,
        responsive: true,
        fixedHeader: true,
        serverSide: true,
        order: [[0, "desc"]],
        pagingType: "full_numbers",
        ajax: {
            url: "./api/GetHistoryResults.ashx",
            data: function (d) {
                //d.start = 0;
                d.performerUserEmail = searchObj.performerUserEmail;
                var actionName = $('#u-history-form-action').val();
                d.actionName = actionName;

                var performerUserName = $('#u-history-form-user-performer').val();
                d.performerUserName = performerUserName;

                var affectedUserName = $('#u-history-form-user-affected').val();
                d.affectedUserName = affectedUserName;

                // dates
                var startDate = $('#u-history-form-begin-date').val();
                var fromTimeVal = $('#u-history-form-begin-time').val();
                var endDate = $('#u-history-form-end-date').val();
                var toTimeVal = $('#u-history-form-end-time').val();

                if (startDate && fromTimeVal) {
                    d.startDate = startDate + " " + fromTimeVal;
                }
                else if (startDate) {
                    d.startDate = startDate + " 00:00:00";
                }

                if (endDate && toTimeVal) {
                    d.endDate = endDate + " " + convert12HrTo24HrWithSeconds(toTimeVal);
                }
                else if (endDate) {
                    d.endDate = endDate + " 23:59:59";
                }

                var sortCol = -1;
                var sortDir = "";

                if (d.order.length > 0) {
                    sortCol = d.order[0].column;
                    sortDir = d.order[0].dir;
                }

                if (sortCol == 0) {
                    d.sort = "auditDate";
                }
                else if (sortCol == 1) {
                    d.sort = "performerUserId";
                }
                else if (sortCol == 2) {
                    d.sort = "affectedUserId";
                }
                else if (sortCol == 3) {
                    d.sort = "auditDescription";
                }

                d.sortDir = sortDir;
            }
        },
        aoColumns: historyColumns,
        oLanguage: {
            "sEmptyTable": "No results found",
            "sStripClasses": "",
            "sInfo": "_START_ -_END_ of _TOTAL_",
            "sLengthMenu": '<span>Rows per page:</span><select class="browser-default">' +
                '<option value="10">10</option>' +
                '<option value="25">25</option>' +
                '<option value="50">50</option>' +
                '<option value="100">100</option>' +
                '</select></div>'
        }
    });
}


function openAdminTab(tabName) {
    $('.u-admin-panel').hide();
    var panelEl = $('#u-admin-' + tabName);
    if (panelEl.length > 0) {
        panelEl.css({ opacity: 0, display: 'contents' }).animate({
            opacity: 1
        }, 300);
    }

    if (tabName == "users") {
        if (UsersTable == '')
            setupUserDatatable();
        $('#u-admin-users-table').show();
        $('#u-admin-history-table').hide();
        getUserFilterDropdownValues();
    }
    else if (tabName == "history") {
        if (HistoryTable == '')
            setupHistoryDatatable();
        $('#u-admin-users-table').hide();
        $('#u-admin-history-table').show();
        getHistoryFilterDropdownValues();
        updateHistoryTable();
    }
}


function openPasswordResetModal(userID, userName) {
    if (userName == performerUserEmail) {
        fireDialog('Cannot update or delete your user.', 'error', 3500);
        return;
    }

    var rows = [];
    rows.push(
        '<div class="row">' +
        '<div class="input-field col s12"><input id="u-cp-login" disabled value="' + userName + '" type="text">' +
        '<label class="active" for="u-cp-login">Login</label>' +
        '</div>' +
        '</div>'
    );

    rows.push(
        '<div class="row">' +
        '<div class="input-field col s12"><input id="u-cp-password" type="password" class="validate" required>' +
        '<label for="u-cp-password">Password</label>' +
        '</div>' +
        '</div>'
    );

    $('#fm-save-btn').html("<i class=\"material-icons left\">replay</i>RESET"); //('<img src="./public/images/change-pw.png">'); 

    openFormModal({
        rows: rows,
        title: 'Reset User Password',
        onSave: resetUserPassword,
        height: '50%',
        element: '#form-modal'
    });

    $('#u-cp-password').on('focus', function () {
        $('label[for="u-cp-password"]').text('Password');
    });
}



function deleteUser(userID, userName) {
    if (userName == performerUserEmail) {
        fireDialog('Cannot update or delete your user.', 'error', 3500);
        return;
    }

    openYesNoModal({
        title: "Delete user?",
        message: 'Are you sure you want to delete "' + userName + '"?',
        onYes: function () {
            $.get("./api/DeleteUser.ashx", { userId: userID, performerUserEmail: performerUserEmail },
                function (deleteData) {
                    var deleteData = JSON.parse(deleteData);
                    if (deleteData.success) {
                        fireDialog('User successfully deleted.', 'success', 3500);
                        UsersTable.ajax.reload();
                    }
                    else {
                        fireDialog('Unable to delete user.', 'error', 3500);
                    }
                }
            );
        },
        onNo: function () {

        }
    });
}

function resetUserPassword() {
    var userName = $('#u-cp-login').val();
    var password = $('#u-cp-password').val();

    if (password == "") {
        fireDialog('Password is required.', 'error', 3500);
        $('#u-cp-password').css("border-bottom-color", "red")
        //$('label[for="u-cp-password"]').text('Password is required');
        //document.getElementById("u-cp-password").style.borderBottomColor = "red";
        return;
    }
    else {
        $('#u-cp-password').css("border-bottom", "#205fa8")
    }

    password = Sha256.hash(password);
    if (password) {
        $.post("./api/ChangePassword.ashx", { performerUserEmail: performerUserEmail, userName: userName, password: password, currentPassword: "" },
            function (updateData) {
                var updateData = JSON.parse(updateData);
                if (updateData.success) {
                    //showMessage("Password is changed!", 'check_circle');
                    fireDialog('Password changed successfully.', 'success', 3500);
                    //console.log(updateData);
                    //loadUsersData();
                    $('#form-modal').modal('close');
                    //passwordMenuItem.style.textDecoration = '';
                    //currentMenuItem.style.textDecoration = 'underline';
                } else {
                    fireDialog(updateData.error, 'error', 3500);
                    //displayError("Unable to change password. " + updateData.data)
                }
            }
        );
    }
}

function openAddUserModal(userInfo) {
    var rows = [];

    var userNameHoneypot = '<div class="row" style="z-index: -1; position: relative; height: 0; margin: 0; pointer-events: none;">' +
        '<div class="input-field col s12" style="height: 0; margin: 0; pointer-events: none;" tabindex="-1"><input id="u-adduser-userNameHoneypot" type="text" class="validate" ';

    var userNameStr = '<div class="row">' +
        '<div class="input-field col s12"><input id="u-adduser-userName" type="text" class="validate" ';

    if (userInfo && userInfo.userName) {
        userNameStr += ' value="' + userInfo.userName + '" required readonly>';
        userNameHoneypot += ' value="' + userInfo.userName + '" required readonly>';
    }
    else {
        userNameStr += 'required>' +
            '<label for="u-adduser-userName">User Name</label>';
        userNameHoneypot += 'required>' +
            '<label for="u-adduser-userName">User Name</label>';
    }

    userNameStr += '</div>' + '</div>';
    userNameHoneypot += '</div>' + '</div>';

    rows.push(userNameHoneypot);
    rows.push(userNameStr);

    rows.push(
        '<div class="row" style="z-index: -1; position: relative; height: 0; margin: 0; pointer-events: none;">' +
        '<div class="input-field col s12" style="height: 0; margin: 0; pointer-events: none;"><input id="u-adduser-passwordHoneypot" type="password" class="validate" tabindex="-1" required>' +
        '</div>' +
        '</div>'
    );

    rows.push(
        '<div class="row">' +
        '<div class="input-field col s12"><input id="u-adduser-password" type="password" class="validate" required>' +
        '<label for="u-adduser-password">Password</label>' +
        '</div>' +
        '</div>'
    );

    if (superAdmin) {
        rows.push(
            '<div class="row">' +
            '<div class="input-field col s12"><label><input id="u-adduser-isSuperAdmin" type="checkbox" /><span>Super Admin</span></label>' +
            '</div>' +
            '</div>'
        );

    }

    $('#fm-save-btn').html("<i class=\"material-icons left\">add</i>ADD");

    openFormModal({
        rows: rows,
        title: 'Add User',
        onSave: addNewUser,
        height: '47%',
        element: '#form-modal'
    });
}

function addNewUser() {
    var userName = $('#u-adduser-userName').val();
    var password = $('#u-adduser-password').val();

    var isSuperAdmin = $('#u-adduser-isSuperAdmin').is(':checked');

    if (!validateEmail('#u-adduser-userName') || userName.length == 0) {
        fireDialog('User Name must be a valid email.', 'error', 3500);
        $('#u-adduser-userName').css("border-bottom", "1px solid red");
        return;
    }
    else if (userName.length > 32) {
        fireDialog('Username cannot exceed 32 characters.', 'error', 3500);
        $('#u-adduser-userName').css("border-bottom", "1px solid red");
        return;
    }
    else {
        $('#u-adduser-userName').css("border-bottom", "1px solid #205fa8");
    }

    if (password == "" || password.length == 0) {
        fireDialog('Password is required.', 'error', 3500);
        $('#u-adduser-password').css("border-bottom", "1px solid red");
        return;
    }
    else if (password.length > 32) {
        fireDialog('Password cannot exceed 32 characters.', 'error', 3500);
        $('#u-adduser-password').css("border-bottom", "1px solid red")
        return;
    }
    else {
        $('#u-adduser-password').css("border-bottom", "1px solid #205fa8")
    }


    password = Sha256.hash(password);

    $.post("./api/AddUser.ashx", { performerUserEmail: performerUserEmail, userName: userName, password: password, isSuperAdmin: isSuperAdmin },
        function (updateData) {
            var updateData = JSON.parse(updateData);
            if (updateData.success) {
                //console.log(updateData);
                UsersTable.ajax.reload();
                //showMessage("User is added", 'check_circle');
                fireDialog('User added successfully.', 'success', 3500);
                $('#form-modal').modal('close');
            } else {
                fireDialog(updateData.error, 'error', 3500);
                //displayError("Unable to save new user. " + updateData.data)
            }
        }
    );
}

// change to a nice pretty popup with error message
function displayError(errorMessage) {
    openInfoModal({ icon: 'error', message: 'ERROR: ' + errorMessage })
}

function openEditUserLPRolesModal(userID, userName) {
    var rows = [];

    if (userName == performerUserEmail) {
        fireDialog('Cannot update or delete your user.', 'error', 3500);
        return;
    }

    var rows = [];

    rows.push(
        '<div class="row">' +
        '<table id="u-admin-edit-roles-datatable"></table>' +
        '</div>'
    );

    openFormModal({
        rows: rows,
        title: 'Edit Roles for ' + userName, // + '\'s Roles',
        //height: '75%',
        width: '100%',
        element: '#form-modal-no-footer'
    });

    affectedUserId = userID;
    loadEditRolesGrid(userID);
}

// Edit Roles Grid
function loadEditRolesGrid(userID) {
    RolesTable = $('#u-admin-edit-roles-datatable').DataTable({
        searching: false,
        bInfo: false,
        paging: false,
        order: [[0, "asc"]],
        ajax: {
            url: "./api/GetUserRoles.ashx",
            data: function (d) {
                d.performerUserEmail = performerUserEmail;
                d.userId = userID;
                d.allowedApps = adminAppsList.toString();


            }
        },
        aoColumns: roleColumns,
        columnDefs: [
            {
                target: 0,
                visible: false,
                searchable: false,
            }
        ],
    });

    // Add event listener for opening and closing details
    $('#u-admin-edit-roles-datatable tbody').on('click', 'td', function () {

        var tr = $(this).closest('tr');
        var row = RolesTable.cell(this)[0][0].row;
        var rowData = RolesTable.row(row).data();

        var cellData = !RolesTable.cell(this).data();

        var idx = RolesTable.cell(this)[0][0].column;
        var title = RolesTable.column(idx).header();

        if ($(title).html() === AccessLevel.None) {
            if (cellData) {
                //read false
                // edit false
                //admin false
                RolesTable.cell({ row: row, column: 2 }).data(true).draw();
                RolesTable.cell({ row: row, column: 3 }).data(false).draw();
                RolesTable.cell({ row: row, column: 4 }).data(false).draw();
                RolesTable.cell({ row: row, column: 5 }).data(false).draw();
            }
            else {
                RolesTable.cell({ row: row, column: 2 }).data(true).draw();
            }
        }
        else if ($(title).html() === AccessLevel.Read) {
            if (cellData) {
                //none false
                RolesTable.cell({ row: row, column: 2 }).data(false).draw();
                RolesTable.cell({ row: row, column: 3 }).data(true).draw();
            }
            else {
                RolesTable.cell({ row: row, column: 2 }).data(true).draw();
                RolesTable.cell({ row: row, column: 3 }).data(false).draw();
                RolesTable.cell({ row: row, column: 4 }).data(false).draw();
                RolesTable.cell({ row: row, column: 5 }).data(false).draw();
            }
        }
        else if ($(title).html() === AccessLevel.Edit) {
            if (cellData) {
                //none false
                //read true
                RolesTable.cell({ row: row, column: 2 }).data(false).draw();
                RolesTable.cell({ row: row, column: 3 }).data(true).draw();
                RolesTable.cell({ row: row, column: 4 }).data(true).draw();
            }
            else {
                RolesTable.cell({ row: row, column: 4 }).data(false).draw();
                RolesTable.cell({ row: row, column: 5 }).data(false).draw();
            }
        }
        else if ($(title).html() === AccessLevel.Admin) {
            if (cellData) {
                //none false
                //read true
                //edit true
                RolesTable.cell({ row: row, column: 2 }).data(false).draw();
                RolesTable.cell({ row: row, column: 3 }).data(true).draw();
                RolesTable.cell({ row: row, column: 4 }).data(true).draw();
                RolesTable.cell({ row: row, column: 5 }).data(true).draw();
            }
            else {
                RolesTable.cell({ row: row, column: 5 }).data(false).draw();
            }
        }
    });
}


function roleChange(app, accessLevel, prevSetting, row) {
    var accLvlNone = RolesTable.cell({ row: row, column: 2 }).data();
    var accLvlRead = RolesTable.cell({ row: row, column: 3 }).data();
    var accLvlEdit = RolesTable.cell({ row: row, column: 4 }).data();
    var accLvlAdmin = RolesTable.cell({ row: row, column: 5 }).data();

    var reqObj = {
        performerUserEmail: performerUserEmail,
        affectedUser: affectedUserId,
        application: app,
        accessLevel: accessLevel,
        //roleSetting: !prevSetting,
        accessLevelNone: accLvlNone,
        accessLevelRead: accLvlRead,
        accessLevelEdit: accLvlEdit,
        accessLevelAdmin: accLvlAdmin,
    };

    $.post("./api/AdminUpdateUser.ashx", reqObj,
        function (updateData) {
            var updateData = JSON.parse(updateData);
            if (updateData.success) {
                //console.log(updateData);
                fireDialog('User updated successfully.', 'success', 3500);
            } else {
                fireDialog(updateData.error, 'error', 3500);
            }
        }
    );

}

function adminRoleChange(affectedUser, prevSetting, row) {
    var isSuperAdmin = !UsersTable.cell({ row: row, column: 1 }).data();
    UsersTable.cell({ row: row, column: 1 }).data(isSuperAdmin);

    var reqObj = {
        performerUserEmail: performerUserEmail,
        affectedUser: affectedUser,
        isSuperAdmin: isSuperAdmin
    };

    $.post("./api/ChangeUserAuth.ashx", reqObj,
        function (updateData) {
            var updateData = JSON.parse(updateData);
            if (updateData.success) {
                fireDialog('User updated successfully.', 'success', 3500);
            } else {
                UsersTable.cell({ row: row, column: 1 }).data(!isSuperAdmin);
                fireDialog(updateData.error, 'error', 3500);
            }
        }
    );
}


function usanUserRoleChange(affectedUser, prevSetting, row) {
    var isUsanUser = !UsersTable.cell({ row: row, column: 2 }).data();
    UsersTable.cell({ row: row, column: 2 }).data(isUsanUser);

    var reqObj = {
        performerUserEmail: performerUserEmail,
        affectedUser: affectedUser,
        isUsanUser: isUsanUser
    };

    $.post("./api/ChangeUserAuth.ashx", reqObj,
        function (updateData) {
            var updateData = JSON.parse(updateData);
            if (updateData.success) {
                //console.log(updateData);
                fireDialog('User updated successfully.', 'success', 3500);
            } else {
                UsersTable.cell({ row: row, column: 2 }).data(!isUsanUser);
                fireDialog(updateData.error, 'error', 3500);
            }
        }
    );
}



function getUserFilterDropdownValues() {
    var searchObj = {
        'performerUserEmail': performerUserEmail,
        'showDeleted': showDeleted
    }


    $.get("./api/GetUsers.ashx", searchObj,
        function (data) {
            var users = {};

            data = JSON.parse(data);
            data = data.data;

            data.sort(function (a, b) {
                return compareStrings(a.userName, b.userName);
            });

            userData = data;

            for (var idx in data) {
                users[data[idx].userName] = null;
            }

            var elems = document.querySelectorAll('#u-user-form-username');
            var search = M.Autocomplete.init(elems, {
                minLength: 0,
                data: users,
            })[0];
        }
    );
}

function getHistoryFilterDropdownValues() {
    var searchObj = {
        'performerUserEmail': performerUserEmail,
        'showDeleted': showDeleted,
        'isUserSearch': true
    }

    $.get("./api/GetUsers.ashx", searchObj,
        function (data) {
            var users = {};

            data = JSON.parse(data);
            data = data.data;

            data.sort(function (a, b) {
                return compareStrings(a.userName, b.userName);
            });

            userData = data;

            for (var idx in data) {
                users[data[idx].userName] = null;
            }

            var elems = document.querySelectorAll('#u-history-form-user-performer');
            var search = M.Autocomplete.init(elems, {
                minLength: 0,
                data: users,
            })[0];


            elems = document.querySelectorAll('#u-history-form-user-affected');
            search = M.Autocomplete.init(elems, {
                minLength: 0,
                data: users,
            })[0];
        }
    );

    // Populate actions
    $.get("./api/GetHistoryActions.ashx", { performerUserEmail: performerUserEmail },
        function (actionsData) {
            var actionsData = JSON.parse(actionsData);
            if (actionsData.success) {
                actionData = actionsData.data;

                actionData.sort(function (a, b) {
                    return compareStrings(a.action, b.action);
                });

                var actions = {};
                for (var index in actionData) {
                    actions[actionData[index].action] = null
                }
                var elems = document.querySelectorAll('#u-history-form-action');
                historyActionsSearch = M.Autocomplete.init(elems, {
                    minLength: 0,
                    data: actions,
                })[0];
            } else {
                displayError("Unable to load actions. " + actionsData.data)
            }
        }
    );

    $('.am-btn').text('AM');

}

function assignEventListeners() {

    // Initialize pickers
    var today = new Date();
    $('#u-history-form-begin-date').datepicker({ maxDate: today, showClearBtn: true });
    $('#u-history-form-end-date').datepicker({ maxDate: today, showClearBtn: true });
    $('#u-history-form-begin-time').timepicker({ showClearBtn: true });
    $('#u-history-form-end-time').timepicker({ showClearBtn: true });

    $('#u-user-form-username').on('change', function () {
        updateUsersTable();
    });

    $('#u-history-window').on('change', 'input', () => {
        updateHistoryTable();
    });

    $('#u-resetBasicFilters-history-btn').on('click', function () {
        //clear the combobox
        $(this).addClass("rotate");

        setTimeout(function () { $('#u-resetBasicFilters-history-btn').removeClass('rotate'); }, 1000);

        $('input').val("")

        $('label').removeClass('active');

        updateHistoryTable();
    });

    $('#open-add-user').on('click', function (val, val2) {
        openAddUserModal();
    });

    $('#u-resetBasicFilters-users-btn').on('click', function () {
        //clear the combobox
        $(this).toggleClass("rotate");

        $('#u-user-form-username').val("");

        $('label').removeClass('active');
        updateUsersTable();
    });

    $('.timepicker-modal').parent().find('> input').on('change', function () {
        if (this.value == '') {
            // This small delay helps combat what the library is doing on clear
            // Even though the delay is set to 0, the function is placed on the call stack 
            // and exectued after the library adds the active class to the lable.
            setTimeout(() => { $(this).next().removeClass('active'); }, 0)
        }
    });

    const dateTimePickers = ['u-history-form-begin-date', 'u-history-form-end-date'];

    dateTimePickers.forEach(id => {
        let element = document.getElementById(id);
        element.addEventListener('change', function (e) {
            if (this.value == '') {
                this.parentElement.querySelector('label').classList.remove('active');
            }
            else {
                if (!isValidDateFormat(this.value)) {
                    fireDialog('Invalid date format.', 'error', 1500);
                }
                else {
                    if (this.value.replace(/\s/g, '').length == 8) {
                        this.value = formatMMDDYYYY(this.value)
                    }
                    updateHistoryTable();
                }
            }
        })

        element.addEventListener('input', function () {
            if (this.value.length > 12) {
                this.value = this.value.substring(0, 12);
                fireDialog('Invalid date format.', 'error', 1500);
            }
        });

        element.addEventListener('focus', function () {
            if (this.value.length == 10) {
                this.value = this.value.replace(/\//g, "");
            }
        });

        element.addEventListener('blur', function () {
            if (this.value.length == 8) {
                this.value = formatMMDDYYYY(this.value)
            }
        });
    });

    $('#u-users-window').on('input', '.autocomplete', function () {
        if (UsersTable) {
            updateUsersTable();
        }
    });

    $('#u-history-window').on('input', '.autocomplete', function () {
        if (HistoryTable &&
            this.id != 'u-history-form-begin-date' &&
            this.id != 'u-history-form-end-date' &&
            this.id != 'u-history-form-begin-time' &&
            this.id != 'u-history-form-end-time'
        ) {
            updateHistoryTable();
        }
    });

    $('#u-history-form-begin-time').on('change', function () {
        if (!isValidTimeFormat(this.value)) {
            this.value = '';
            fireDialog('Invalid time format.', 'error', 1500);
        }
    });

    $('#u-history-form-end-time').on('change', function () {
        if (!isValidTimeFormat(this.value)) {
            this.value = '';
            fireDialog('Invalid time format.', 'error', 1500);
        }
    });
}


// searches the log and updates the UI
function updateUsersTable() {
    UsersTable.ajax.reload();
}


function updateHistoryTable() {
    HistoryTable.ajax.reload();
}

function convert12HrTo24HrWithSeconds(time12hr) {
    const [time, period] = time12hr.split(' '); // Split into time and AM/PM
    let [hours, minutes] = time.split(':').map(Number); // Split time into hours and minutes

    // Convert to 24-hour format
    if (period.toLowerCase() === 'pm' && hours !== 12) {
        hours += 12;
    } else if (period.toLowerCase() === 'am' && hours === 12) {
        hours = 0; // Midnight (12 AM) is 00 hours
    }

    // Format hours and minutes to ensure two digits
    const formattedHours = String(hours).padStart(2, '0');
    const formattedMinutes = String(minutes).padStart(2, '0');

    // Append seconds (always "59" as per your example)
    const seconds = "59";

    return `${formattedHours}:${formattedMinutes}:${seconds}`;
}

function isValidTimeFormat(timeString) {
    // Regular expression to match HH:MM AM/PM format.
    // ^ asserts position at the start of the string.
    // (0[1-9]|1[0-2]) matches hours from 01 to 12.
    // : matches the colon separator.
    // ([0-5][0-9]) matches minutes from 00 to 59.
    // \s matches a single whitespace character.
    // (AM|PM) matches either "AM" or "PM".
    // $ asserts position at the end of the string.
    // The /i flag makes the match case-insensitive (e.g., "am", "Pm").
    const timeRegex = /^(0[1-9]|1[0-2]):([0-5][0-9])\s(AM|PM)$/i;

    return timeRegex.test(timeString);
}