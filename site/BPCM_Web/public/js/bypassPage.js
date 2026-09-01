var summaryTable = '';
var queueTable = {};
var queueIntervalTable = {};

var childRows = [];
var childRowsQueue = {};


var appTableTimer;
var queueTableTimer;
var refreshTimer;
var intervalUpdateTimer;

var successRateFailThreshold = 35;

var browserName = '';

var lastUpdateOptions;
var allTimesOptions;

var previousAppSortDirection = 'asc';
var previousSortColIndex = 2;
var previousSortColDirection = 'asc';

$(document).ready(function () {

    setFrameSize();

    setUnderline();

    localStorage.setItem('accessLevel', "Update Users");
    userAccessLevel = localStorage.getItem('accessLevel');

    browserName = detectBrowser();

    lastUpdateOptions;
    allTimesOptions;


    if (browserName == 'Firefox') {
        lastUpdateOptions = { timeZone: 'America/Winnipeg', };
        allTimesOptions = { day: '2-digit', timeZone: 'America/Winnipeg', timeZoneName: 'long' };
    }
    else {
        lastUpdateOptions = { timeZone: 'CST', };
        allTimesOptions = { day: '2-digit', timeZone: 'CST', timeZoneName: 'long' };
    }

    //updateRefreshTimeDisplay();
    observeDropdowns();

    checkRoles(performerUserEmail).then(function (data) {

        getFilterDropdownValues();

        assignEventListeners();

        setupSummaryDataTable();

        hideElementsBasedOnRole();
    });
});

function setUnderline() {
    const currentMenuItem = document.getElementById('bypassConfigurationMenuItem');
    currentMenuItem.style.textDecoration = 'underline';
}

function hideElementsBasedOnRole() {
    if (editAppsList.length > 0) {
        document.getElementById('new-config-button').parentElement.hidden = false;
    }
}

function setupSummaryDataTable() {
    var currentAppName = '';
    summaryTable = $("#bypass-summary-datatable").DataTable({
        //dom: 'Bt',
        orderCellsTop: true,
        searching: false,
        paging: false,
        bInfo: false,
        select: false,
        stateSave: false, // Was true, but why?
        scrollX: true,
        fixedHeader: true,
        //responsive: true,
        buttons: [
            'colvis'
        ],
        // Grab the data from the DB using an api call
        ajax: {
            url: "./api/GetConfigurations.ashx",
            data: function (d) {
                d.userName = performerUserEmail;
                d.application = $('#u-bypass-form-application').val();
                d.language = $('#u-bypass-form-language').val();
                d.dnis = $('#u-bypass-form-dnis').val().replace(/-/g, "");
                d.destinationPhoneNumber = $('#u-bypass-form-destinationPhoneNumber').val().replace(/-/g, "");
                d.peg = $('#u-bypass-form-peg').val();
                d.rank = $('#u-bypass-form-rank').val();
                d.offerId = $('#u-bypass-form-offerId').val();
                d.offerType = $('#u-bypass-form-offerType').val();
                d.lastModifiedBy = $('#u-bypass-form-lastModifiedBy').val();
                d.lastModifiedDate = $('#u-bypass-form-lastModifiedDate').val();
            },
            dataSrc: function (json) {
                console.log(json)
                var dataRows = json.data
                dataRows.forEach(item => { // Fill empty values with - for regular fields, * for key fields
                    if (item['isHeader'] === false) {
                        for (let key in item) {
                            if (item[key] === null || item[key] === "") {
                                if (['language', 'dnis', 'destination', 'rank', 'offerId', 'offerType'].includes(key))
                                    item[key] = "*"
                                else
                                    item[key] = "-";
                            }
                        }
                    }
                });

                return dataRows; // Assuming your data is in the 'data' property
            },
            error: function (xhr, status, error) {
                if (!error == 'abort') {
                    fireDialog('Error reloading table', 'error', 3500);
                }
            }
        },
        // Define the columns that will appear in the table
        columns: [
            // Use this empty placeholder to trick the DataTable lib. 
            // It always automatically adds a control we don't want to the first td element of a table row.
            {
                className: "empty-placeholder",
                orderable: false,
                data: null,
                defaultContent: ""
            },
            {
                className: "details-control1",
                orderable: false,
                data: null,
                defaultContent: ""
            },
            { data: "application", title: "Application", className: "appNameBypass yellow-column-name", orderable: false },
            { data: "language", title: "Language", className: "languageBypass yellow-column-name", orderable: false },
            {
                data: "dnis",
                title: "DNIS",
                className: "dnisBypass yellow-column-name",
                orderable: false,
                render: function (data, type) {
                    // 'data' is the value of the 'dnis' field
                    // 'type' is the type of render requested (display, filter, sort, type)
                    if (type === 'display' && data && data != '*') { // Only format for display
                        return formatPhoneNumber(data);
                    }
                    return data; // Return original data for other types (sorting, filtering)
                }
            },
            {
                data: "destination",
                title: "Destination",
                className: "destinationBypass yellow-column-name",
                orderable: false,
                render: function (data, type) {
                    // 'data' is the value of the 'destination' field
                    // 'type' is the type of render requested (display, filter, sort, type)
                    if (type === 'display' && data && data != '*') { // Only format for display
                        return formatPhoneNumber(data);
                    }
                    return data; // Return original data for other types (sorting, filtering)
                }
            },
            { data: "rank", title: "Rank", className: "rankBypass yellow-column-name", orderable: false, },
            { data: "offerId", title: "Offer ID", className: "offerIdBypass yellow-column-name", orderable: false },
            { data: "offerType", title: "Offer Type", className: "offerTypeBypass yellow-column-name", orderable: false },
            { data: "peg", title: "Peg", className: "pegBypass", orderable: false },
            { data: "skillId", title: "Skill ID", className: "skillIdBypass", orderable: false },
            { data: "skillName", title: "Skill Name", className: "skillNameBypass", orderable: false },
            { data: "agentsAvailable", title: "Agents Available", className: "agentsAvailableBypass", orderable: false },
            { data: "med", title: "MED", className: "MEDBypass", orderable: false },
            { data: "overflowSkillId", title: "Overflow Skill ID", className: "overflowSkillIdBypass", orderable: false },
            { data: "overflowSkillName", title: "Overflow Skill Name", className: "overflowSkillNameBypass", orderable: false },
            { data: "overflowAgentsAvailable", title: "Overflow Agents Available", className: "overflowAgentsAvailableBypass", orderable: false },
            { data: "overflowMed", title: "Overflow MED", className: "overflowMEDBypass", orderable: false },
            { data: "lastModifiedUserName", title: "Last Modified By", className: "lastModifiedByBypass", orderable: false },
            { data: "lastModifiedDate", title: "Last Modified Date", className: "lastModifiedDateBypass", orderable: false },
            {
                className: "edit-configuration-icon",
                orderable: false,
                searchable: false,
                defaultContent: '',
                data: "application",
                render: function (data) {
                    // Hide if user is not allowed to edit specific app
                    if (isEditable(data)) {
                        return '<img src="./public/images/edit-tool.png" alt="Edit Icon" style="width: 20px; height: 20px; cursor: pointer;" onclick="goToEditOrCopyConfigurationPage(this, true)">';
                    }
                    return '';
                }
            },
            {
                className: "copy-configuration-icon",
                orderable: false,
                searchable: false,
                defaultContent: '',
                data: "application",
                render: function (data) {
                    if (isEditable(data)) {
                        return '<img src="./public/images/copy-icon.png" alt="Copy Icon" style="width: 25px; height: 25px; cursor: pointer;" onclick="goToEditOrCopyConfigurationPage(this, false)">';
                    }
                    return '';
                },
            },
            {
                className: "delete-configuration-icon",
                orderable: false,
                searchable: false,
                defaultContent: '',
                data: "application",
                render: function (data) {
                    if (isEditable(data)) {
                        return '<img src="./public/images/trash.png" alt="Delete Icon" style="width: 20px; height: 20px; cursor: pointer;" onclick="openDeleteRow(this);">';
                    }
                    return '';
                },
            }
        ],
        // Rows are getting created now that the data has been grabbed via api call
        createdRow: function (row, data, dataIndex) {
            if (data.isHeader == true) {

                currentAppName = data.application;

                $(row).addClass('configurationAppRow');
                $(row).attr('app', currentAppName);

                // Remove the edit, copy, and delete icons
                $('td:eq(-1)', row).html('');
                $('td:eq(-2)', row).html('');
                $('td:eq(-3)', row).html('');

            } else {
                // Give each child row a class name containing the name of the application
                $(row).addClass(`configurationChildRow`);
                $(row).attr('data-app', currentAppName);
                $(row).attr('data-configId', data.bypassConfigurationId);
                $(row).attr('data-order', data.order);
                // Remove the datail controls from non-header rows
                $('td:eq(1)', row).removeClass('details-control1');
                // Only make draggable is the user is allowed to edit this app
                if (isEditable(currentAppName)) {
                    $('td:eq(1)', row).addClass('drag-and-drop');
                    //$(row).attr('draggable', 'true');
                }

            }
        },
        initComplete: function () {
            summaryTable.column(2).visible(false); // Hiding the real application column
            initializeTableEventListeners();
            addTableProperties();
        },
        oLanguage: {
            "sEmptyTable": "No results found"
        },
    });

    // Add event listener for opening and closing details
    $("tbody").on("click", "td.details-control1", function () {
        var tr = $(this).closest("tr");
        var secondChild = $('td:eq(2)', tr);
        // We will use this app name to only expand the child rows of the application we are seeking
        var appName = secondChild.text();

        if (!$(tr).hasClass('dt-hasChild')) {
            $(`[data-app="${appName}"]`).show();
            $(tr).addClass('dt-hasChild');
            $(tr).addClass('shown')
        }
        else {
            $(`[data-app="${appName}"]`).hide();
            $(tr).removeClass('dt-hasChild');
            $(tr).removeClass('shown')
        }
    });
}

function addTableProperties() {
    // Initially show all child rows
    $('.configurationChildRow').show(); // Show child rows by default
    $('.configurationAppRow').addClass('dt-hasChild'); // Add controls to header rows
    $('.order').css('display', 'none'); // Hide order which is used for sorting

    //Make the drag icons draggable
    $('.configurationChildRow').each(function () {
        const $row = $(this); // Get the jQuery object for the current row
        const appValue = $row.data('app'); // Get the value of the data-app attribute

        if (editAppsList.includes(appValue)) {
            // Find the second td (index 1) within this row and make it draggable
            $row.find('td').eq(1).attr('draggable', 'true');
        }
    });
}

function initializeTableEventListeners() {

    const dataTable = $('#bypass-summary-datatable').DataTable();

    $('tbody').on('dragstart', '.configurationChildRow td', function (event) {

        //$(this).addClass('hovering-over');

        const dataTransfer = event.originalEvent.dataTransfer;
        //dataTransfer.dropEffect = 'copy';
        //dataTransfer.effectAllowed = 'copy';
        const row = $(this).closest('tr')[0]; // Gets the actual DOM element
        const rowIndex = dataTable.row(row).index();
        // Get the absolute position of where the drag action started on the page
        const x = event.originalEvent.pageX;
        const y = event.originalEvent.pageY;
        // Passable date between drag-related events
        const dragData = {
            row: row,
            originConfigId: row.dataset.configid,
            rowIndex: rowIndex,
            xOrigin: x,
            yOrigin: y,
            configId: row.dataset.configid,
        };

        //console.log(`drag data: ${JSON.stringify(dragData)}`);
        // Set data as plaintext
        dataTransfer.setData('text/plain', JSON.stringify(dragData));
    });

    $('tbody').on('dragover', 'td[draggable=true]', function (event) {
        event.preventDefault(); // Allow drop     
        //event.originalEvent.dataTransfer.dropEffect = 'copy';
        //event.originalEvent.dataTransfer.effectAllowed = 'none';
        $('tr').removeClass('magnified-row');
        $(this).closest('tr').addClass('magnified-row'); // Add the class to the hovered row
        $(this).addClass('hovering-over');
    });

    // Make sure rows don't stay magnified if dragged outside of table
    $('tbody').on('dragend', 'tr [draggable=true]', function (event) {
        $('tr').removeClass('magnified-row');
        $('.hovering-over').removeClass('hovering-over'); // Clean up the class
    });

    // Add drop listener to the table body
    $('tbody').on('drop', 'td[draggable=true]', async function (event) {
        event.preventDefault();

        $('tr').removeClass('magnified-row');

        // The data of the row we are dragging
        const draggedDataJson = event.originalEvent.dataTransfer.getData('text/plain');
        //console.log(`dragged data: ${draggedDataJson}`);
        const draggedData = JSON.parse(draggedDataJson);

        const originalRow = draggedData.row;
        const originRowIndex = draggedData.rowIndex;
        // The row we are targeting
        const targetRow = $(event.target).closest('tr');

        // This is the absolute y coordinate of the target row
        const targetRowMiddleY = getMiddleYDocument(targetRow[0]);
        const targetRowDOMElement = targetRow[0];
        const targetRowIndex = dataTable.row(targetRowDOMElement).index();

        // This is the absolute y coordinate of where the element is being dropped
        const yDrop = event.originalEvent.pageY;

        // Get all data rows
        var allData = dataTable.rows().data().toArray();
        const oldData = JSON.parse(JSON.stringify(allData)); // Create deep copy
        const movedRow = allData[originRowIndex]; // Data from original row 

        if (targetRowIndex < originRowIndex) {
            // When we drag upwards, inserting will change index of origin row, so we delete first
            //console.log(`Dragged row upward!`);
            if (yDrop < targetRowMiddleY) {
                //console.log(`Dropped origin above target row!`);

                allData.splice(originRowIndex, 1); // Remove original row       
                allData.splice(targetRowIndex, 0, movedRow); // Insert origin row above target      
            }
            else {
                //console.log(`Dropped origin below target row!`);

                allData.splice(originRowIndex, 1); // Remove original row  
                allData.splice(targetRowIndex + 1, 0, movedRow); // Insert origin row above target
            }
        }
        else {
            //console.log(`Dragged row downward!`);
            // If we drag downwards, deleteing the origin row first causes the index of insertion to become incorrect, so we add the row first and then delete
            if (yDrop < targetRowMiddleY) {
                //console.log(`Dropped origin above target row!`);

                allData.splice(targetRowIndex, 0, movedRow); // Insert origin row above target
                allData.splice(originRowIndex, 1); // Remove original row   
            }
            else {
                //console.log(`Dropped origin below target row!`);

                allData.splice(targetRowIndex + 1, 0, movedRow); // Insert origin row below target
                allData.splice(originRowIndex, 1); // Remove original row   
            }
        }

        // Clear and re-add data
        dataTable.clear().rows.add(allData).draw();
        // Add back table props
        addTableProperties();
        // Update DB table with changes from UI
        var configurationOrderList = "";
        var rowIndex = 0;

        allData = dataTable.rows().data().toArray();
        allData.forEach((dataRow) => {
            if (dataRow.bypassConfigurationId != null) {
                configurationOrderList += `${dataRow.bypassConfigurationId},${rowIndex};`;
            }
            else { // Reset when we reach a header so each app has its own ordering starting from 0
                rowIndex = 0;
            }
            rowIndex++;
            //console.log(`data row: ${JSON.stringify(dataRow)}, index: ${index}`);            
        });
        //console.log(`config list: ${configurationOrderList}`);
        const result = await updateConfigurationOrder(configurationOrderList)
        // Redraw the table with the old data on failure
        if (result == 'fail') {
            //console.log('redrawing table');
            dataTable.clear().rows.add(oldData).draw();
            addTableProperties();
        }

    });
}

function getMiddleYDocument(rowElement) {
    const rect = rowElement.getBoundingClientRect();
    const scrollTop = window.scrollY || document.documentElement.scrollTop;
    return rect.top + scrollTop + (rect.height / 2);
}

async function updateConfigurationOrder(configurationOrderList) {
    const parameters = {
        configurationOrderList: configurationOrderList,
        performerUserEmail: performerUserEmail
    }

    return new Promise((resolve, reject) => {
        $.post("./api/UpdateConfigurationOrder.ashx", parameters, function (updateData) {
            const parsed = JSON.parse(updateData);
            if (parsed.success) {
                fireDialog('Order changed successfully', 'success', 3500);
                $('#form-modal').modal('close');
                resolve('success');
            } else {
                fireDialog(parsed.error, 'error', 3500);
                resolve('fail');
            }
        }).fail(function () {
            fireDialog("Server error occurred", 'error', 3500);
            resolve('fail');
        });
    });
}

function isEditable(appName) {
    if (editAppsList.includes(appName)) {
        return true;
    }
    return false;
}

// Function for creating the window when delete icon is clicked
function openDeleteRow(clickedIcon) {

    let row = clickedIcon.closest('tr');
    let offerType = $('td:eq(8)', row).text();

    document.body.style.overflow = 'hidden'; // Stop scroll when confirmation box is open

    const modalContainer = document.createElement('div');
    modalContainer.id = 'modal-container';
    modalContainer.style.position = 'fixed';
    modalContainer.style.top = '0';
    modalContainer.style.left = '0';
    modalContainer.style.width = '100%';
    modalContainer.style.height = '100%';
    modalContainer.style.backgroundColor = 'rgba(0, 0, 0, 0.2)'; /* Semi-transparent background */
    modalContainer.style.display = 'flex';
    modalContainer.style.justifyContent = 'center';
    modalContainer.style.alignItems = 'center';
    modalContainer.style.zIndex = '1000'; /* Ensure it's on top */

    const confirmationBox = document.createElement('div');
    confirmationBox.style.backgroundColor = '#1b5ca6';
    confirmationBox.style.color = 'white';
    confirmationBox.style.padding = '30px';
    confirmationBox.style.borderRadius = '8px';
    confirmationBox.style.textAlign = 'center';
    confirmationBox.style.minWidth = '27vw';
    confirmationBox.style.minHeight = '40vh';
    confirmationBox.style.position = 'absolute';
    confirmationBox.style.bottom = '12%';

    const warningIconContainer = document.createElement('div');
    const warningIcon = document.createElement('img');
    warningIcon.src = './public/images/error-icon.jpg';
    warningIconContainer.appendChild(warningIcon);

    const confirmText = document.createElement('h2');
    confirmText.textContent = 'C  O  N  F  I  R  M';
    confirmText.style.fontSize = '22px'
    confirmText.style.fontWeight = '600'
    confirmText.style.marginTop = '10px';


    const messageText = document.createElement('p');
    messageText.innerHTML = `Are you sure you want to delete the <br>${offerType == '-' ? '' : `"${offerType}"`} offer?`;
    messageText.style.marginBottom = '20px';
    messageText.style.fontSize = '1.1em';

    const buttonsContainer = document.createElement('div');
    buttonsContainer.style.display = 'flex';
    buttonsContainer.style.gap = '15px';
    buttonsContainer.style.justifyContent = 'center';

    const yesButton = document.createElement('button');
    yesButton.id = 'yes-button';
    yesButton.textContent = 'Yes';
    yesButton.style.backgroundColor = 'white';
    yesButton.style.color = '#1b5ca6';
    yesButton.style.width = '25%';
    yesButton.style.border = 'none';
    yesButton.style.borderRadius = '25px';
    yesButton.style.padding = '10px 25px';
    yesButton.style.cursor = 'pointer';

    const noButton = document.createElement('button');
    noButton.textContent = 'No';
    noButton.style.backgroundColor = '#1b5ca6';
    noButton.style.color = 'white';
    noButton.style.width = '25%';
    noButton.style.border = '1px solid white';
    noButton.style.borderRadius = '25px';
    noButton.style.padding = '10px 25px';
    noButton.style.cursor = 'pointer';

    // Event listeners for the buttons
    yesButton.addEventListener('click', () => {
        const parameters = {
            configurationId: row.dataset.configid,
            performerUserEmail: performerUserEmail
        };

        $.post("./api/RemoveConfiguration.ashx", parameters,
            function (data) {
                //console.log(`data: ${JSON.stringify(data)}`);
                data = JSON.parse(data);
                if (data.success) {
                    fireDialog('Deletion success!', 'success', 3000);
                    document.body.style.overflow = 'auto'; // Resume scroll when confirmation box is closed
                    document.body.removeChild(modalContainer);

                    updateTable();
                }
                else {
                    fireDialog('Deletion failure!', 'error', 3000);
                }
            }
        );
    });

    noButton.addEventListener('click', () => {
        document.body.style.overflow = 'auto'; // Resume scroll when confirmation box is closed
        document.body.removeChild(modalContainer);
    });

    // Assemble the elements
    buttonsContainer.appendChild(yesButton);
    buttonsContainer.appendChild(noButton);

    confirmationBox.appendChild(warningIconContainer);
    confirmationBox.appendChild(confirmText);
    confirmationBox.appendChild(messageText);
    confirmationBox.appendChild(buttonsContainer);

    modalContainer.appendChild(confirmationBox);
    document.body.appendChild(modalContainer);
}

// Shared function for edit-configuration-icon and copy-configuration-icon
function goToEditOrCopyConfigurationPage(clickedIcon, isEdit) {

    var uri = "./EditOrCopyConfig.aspx?";

    let row = clickedIcon.closest('tr');

    if (row) {
        const configurationId = row.dataset.configid;
        uri += `configurationId=${configurationId}`;

        const application = row.dataset.app;
        uri += `&application=${application}`;

        const language = row.querySelector('.languageBypass').textContent;
        uri += `&language=${language == '-' ? '' : language}`;

        const dnis = row.querySelector('.dnisBypass').textContent; 
        uri += `&dnis=${dnis == '-' ? '' : dnis}`;

        const destination = row.querySelector('.destinationBypass').textContent;
        uri += `&destination=${destination == '-' ? '' : destination}`;

        const rank = row.querySelector('.rankBypass').textContent;
        uri += `&rank=${rank == '-' ? '' : rank}`;

        const offerID = row.querySelector('.offerIdBypass').textContent;
        uri += `&offerID=${offerID == '-' ? '' : offerID}`;

        const offerType = row.querySelector('.offerTypeBypass').textContent;
        uri += `&offerType=${offerType == '-' ? '' : offerType}`;

        const peg = row.querySelector('.pegBypass').textContent;
        uri += `&peg=${peg == '-' ? '' : peg}`;

        const skillId = row.querySelector('.skillIdBypass').textContent;
        uri += `&skillId=${skillId == '-' ? '' : skillId}`;

        const skillName = row.querySelector('.skillNameBypass').textContent;
        uri += `&skillName=${skillName == '-' ? '' : skillName}`;

        const agentsAvailable = row.querySelector('.agentsAvailableBypass').textContent;
        uri += `&agentsAvailable=${agentsAvailable == '-' ? '' : agentsAvailable}`;

        const MED = row.querySelector('.MEDBypass').textContent;
        uri += `&MED=${MED == '-' ? '' : MED}`;

        const overflowSkillId = row.querySelector('.overflowSkillIdBypass').textContent;
        uri += `&overflowSkillId=${overflowSkillId == '-' ? '' : overflowSkillId}`;

        const overflowSkillName = row.querySelector('.overflowSkillNameBypass').textContent;
        uri += `&overflowSkillName=${overflowSkillName == '-' ? '' : overflowSkillName}`;

        const overflowAgentsAvailable = row.querySelector('.overflowAgentsAvailableBypass').textContent;
        uri += `&overflowAgentsAvailable=${overflowAgentsAvailable == '-' ? '' : overflowAgentsAvailable}`;

        const overflowMED = row.querySelector('.overflowMEDBypass').textContent;
        uri += `&overflowMED=${overflowMED == '-' ? '' : overflowMED}`;

        const lastModifiedBy = row.querySelector('.lastModifiedByBypass').textContent;
        uri += `&lastModifiedBy=${lastModifiedBy == '-' ? '' : lastModifiedBy}`;

        const lastModifiedDate = row.querySelector('.lastModifiedDateBypass').textContent;
        uri += `&lastModifiedDate=${lastModifiedDate == '-' ? '' : lastModifiedDate}`;

        uri += `&isEdit=${isEdit}`;
    } else {
        console.log('Error: Could not find the parent row.');
    }

    // Encode and navigate to url
    var url = encodeURI(uri);

    window.location.href = url;
}

function getFilterDropdownValues() {

    $('#u-bypass-form-lastModifiedDate').datepicker({ showClearBtn: true });

    var filterObj = {
        performerUserEmail: performerUserEmail,
        "allowedApps": readAppsList.toString()
    }

    // We only want to allow users who can edit apps to edit the ones they have permissions for
    const appData = Object.fromEntries(readAppsList.map(key => [key, null]));
    //console.log(`read app list: ${readAppsList}`);

    var elems = document.querySelectorAll('#u-bypass-form-application');
    var search = M.Autocomplete.init(elems, {
        minLength: 0,
        data: appData,
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

            var elems = document.querySelectorAll('#u-bypass-form-language');
            M.Autocomplete.init(elems, {
                minLength: 0,
                data: langs,
            });
        }
    );

    $.post("./api/GetUsers.ashx", filterObj,
        function (response) {
            var users = {};

            response = JSON.parse(response);

            data = response.data;
            //console.log(`data: ${JSON.stringify(data)}`)


            // Uncomment if we want to get rid of SYSTEM showing up in user filtering. 
            data = data.filter(obj => obj.userName !== 'SYSTEM');

            data.sort(function (a, b) {
                return compareStrings(a.userName, b.userName);
            });

            for (var idx in data) {
                users[data[idx].userName] = null;
            }

            var elems = document.querySelectorAll('#u-bypass-form-lastModifiedBy');
            var search = M.Autocomplete.init(elems, {
                minLength: 0,
                data: users,
            })[0];
        }
    );
}

function observeDropdowns() {
    observeSpecificDropdown('u-bypass-form-application');
    observeSpecificDropdown('u-bypass-form-language');
    //observeSpecificDropdown('u-bypass-form-lastModifiedBy');
}

function observeSpecificDropdown(dropdownId) {
    // We are doing this because we still want the 'x' button for clearing but also want the fields to be readonly
    const applicationInput = document.getElementById(dropdownId);
    const parentElement = applicationInput.parentElement;

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
                            if (dropdownId == 'u-bypass-form-application') {
                                readAppsList.forEach((element) => {
                                    dropdown.innerHTML += `<li><span><span class="highlight"></span>${element}</span></li>`;
                                });
                            }
                            else if (dropdownId == 'u-bypass-form-language') {
                                fullLanguagesList.forEach((element) => {
                                    if (element == 'French' && !readAppsList.includes('CRSCS') ||
                                        element == 'French' && document.getElementById('u-bypass-form-application').value == 'BRANDSCS') {
                                        // We don't want to show users who can only view BRANDSCS the language French
                                        // There are only two apps so if CRSCS is not present we can assume the only app is BRANDSCS or no app at all
                                    }
                                    else {
                                        dropdown.innerHTML += `<li><span><span class="highlight"></span>${element}</span></li>`;
                                    }
                                });
                            }
                            else {
                                fullUsersList.forEach((element) => {
                                    dropdown.innerHTML += `<li><span><span class="highlight"></span>${element}</span></li>`;
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

function assignEventListeners() {

    const alwaysAllowed = ['Backspace', 'Enter', 'Tab', 'ArrowLeft', 'ArrowRight', 'Delete'];

    //////////////////////////////
    // Table Reload listeners

    $('#bypass-summary-datatable').on('error.dt', function (e, settings, techNote, message) {
        // Handle the error, e.g., display an error message to the user
        fireDialog('Failed to reload data.', 'error', 3500);
    });

    //////////////////////////////
    // Filter Reset Button listeners

    $('#u-bypass-resetBasicFilters-btn').on('click', function () {
        //clear the combobox
        $('#u-bypass-resetBasicFilters-btn').addClass("rotate");

        setTimeout(function () { $('#u-bypass-resetBasicFilters-btn').removeClass('rotate'); }, 1000);

        $('#u-bypass-form-application').val("");
        $('#u-bypass-form-language').val("");
        $('#u-bypass-form-dnis').val("");
        $('#u-bypass-form-destinationPhoneNumber').val("");
        $('#u-bypass-form-peg').val("");
        $('#u-bypass-form-rank').val("");
        $('#u-bypass-form-offerId').val("");
        $('#u-bypass-form-offerType').val("");
        $('#u-bypass-form-lastModifiedBy').val("");
        $('#u-bypass-form-lastModifiedDate').val("");

        $('label').removeClass('active');
        updateTable();
    });

    //////////////////////////////
    // Table Refresh Button listeners

    $('#bypass-table-refresh-button').on('click', function () {
        //clear the combobox
        $('#bypass-table-refresh-button').addClass("rotate");

        setTimeout(function () { $('#bypass-table-refresh-button').removeClass('rotate'); }, 1000);

        updateTable('refresh');
    });


    //////////////////////////////
    // Application input listeners

    const applicationInput = document.getElementById('u-bypass-form-application');
    // Prevent typing by blocking key events   
    applicationInput.addEventListener('keydown', function (e) {
        // Allow Backspace, Delete, Tab, Arrow keys for usability if needed
        const allowedKeys = [];
        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }
    });

    applicationInput.addEventListener('change', () => {
        if (languageInput.value == 'French') { // No French for BRANDSCS
            languageInput.value = '';
            languageInput.parentElement.querySelector('label').classList.remove('active');
        }
        updateTable();
    });

    //////////////////////////////
    // Language input listeners

    const languageInput = document.getElementById('u-bypass-form-language');

    // Prevent typing by blocking key events   
    languageInput.addEventListener('keydown', function (e) {
        // Allow Backspace, Delete, Tab, Arrow keys for usability if needed
        const allowedKeys = [];
        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }
    });

    languageInput.addEventListener('change', () => {
        if (languageInput.value == '* (ALL LANGUAGES)') {
            languageInput.value = '*';
            
        }

        updateTable();
    });

    ///////////////////////////////////////////////////////////////////
    // DNIS input listeners

    const dnisInput = document.getElementById('u-bypass-form-dnis');

    dnisInput.addEventListener('input', function () {
        if (dnisInput.value.length > 10) {
            dnisInput.value = dnisInput.value.substring(0, 10);
            fireDialog('DNIS must be 10 digits.', 'error', 1500);
        }

        updateTable();
    });

    dnisInput.addEventListener('change', function () {
        if (dnisInput.value.length == 10) {
            this.value = formatPhoneNumber(this.value)            
        }

        updateTable();
    });

    dnisInput.addEventListener('focus', function () {
        if (dnisInput.value.length == 12) {
            this.value = this.value.replace(/-/g, "");
        }

        this.labels[0].textContent = "DNIS";
    });

    dnisInput.addEventListener('blur', function () {
        if (dnisInput.value.length == 10) {
            this.value = formatPhoneNumber(this.value)
        }

        if (this.value.length == 0)
            this.labels[0].textContent = "DNIS (800-123-4567 or *)";
        else {
            this.labels[0].textContent = "DNIS";
        }
    });

    dnisInput.addEventListener('keydown', function (e) {
        // Allow Backspace, Delete, Tab, Arrow keys for usability if needed
        const allowedKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab', 'Enter', 'Escape', '*'];
        if (!allowedKeys.includes(e.key)) {
            e.preventDefault();
        }
        else {
            if (e.key == '*' && this.value.length >= 1) {
                fireDialog('DNIS must be numeric or *', 'error', 1500);
                e.preventDefault();
            }

            if (this.value.includes('*') && this.value.length >= 1 && !alwaysAllowed.includes(e.key)) {
                fireDialog('DNIS must be numeric or *', 'error', 1500);
                e.preventDefault();
            }
        }        
    });


    ///////////////////////////////////////////////////////////////////
    // Destination input listeners

    const destinationInput = document.getElementById('u-bypass-form-destinationPhoneNumber');

    destinationInput.addEventListener('input', function () {
        if (this.value.length > 10) {
            this.value = this.value.substring(0, 10);
            fireDialog('Destination Phone Number must be 10 digits.', 'error', 1500);
        }

        updateTable();
    });

    destinationInput.addEventListener('change', function () {
        if (this.value.length == 10) {
            this.value = formatPhoneNumber(this.value)
        }

        updateTable();
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

        if (this.value.length == 0)
            this.labels[0].textContent = "Destination (123-456-7890 or *)";
        else {
            this.labels[0].textContent = "Destination Phone Number";
        }
    });

    destinationInput.addEventListener('keydown', function (e) {
        // Allow Backspace, Delete, Tab, Arrow keys for usability if needed
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

    ///////////////////////////////////////////////////////////////////
    // PEG input listeners

    const pegInput = document.getElementById('u-bypass-form-peg');

    pegInput.addEventListener('input', function () {
        if (this.value.length > 32) {
            this.value = this.value.substring(0, 32);
            fireDialog('PEG cannot exceed 32 digits.', 'error', 1500);
        }
        updateTable();
    });

    ///////////////////////////////////////////////////////////////////
    // Rank input listeners

    const rankInput = document.getElementById('u-bypass-form-rank');

    rankInput.addEventListener('input', function () {
        if (this.value.length > 6) {
            this.value = rankInput.value.substring(0, 6);
            fireDialog('Rank cannot exceed 6 digits.', 'error', 1500);
        }
        updateTable();
    });

    rankInput.addEventListener('keydown', function (e) {
        // Allow Backspace, Delete, Tab, Arrow keys for usability if needed
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
        this.labels[0].textContent = "Rank";
    });

    rankInput.addEventListener('blur', function () {
        if (this.value.length == 0)
            this.labels[0].textContent = "Rank (1-6 or *)";
        else
            this.labels[0].textContent = "Rank";
    });

    ///////////////////////////////////////////////////////////////////
    // Offer ID input listeners

    const offerIdInput = document.getElementById('u-bypass-form-offerId');

    offerIdInput.addEventListener('input', function () {
        if (this.value.length > 8) {
            this.value = offerIdInput.value.substring(0, 8);
            fireDialog('Offer ID cannot exceed 8 characters.', 'error', 1500);
        }
        updateTable();
    });

    offerIdInput.addEventListener('keydown', function (e) {
        // Allow alphanumeric and *
        const disallowedKeys = ".,;:?!+-=/|\\<>()[]#$%^&@{}\"\'`~";

        if (disallowedKeys.indexOf(e.key.toLowerCase()) > -1)
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
        if(this.value.length == 0)
            this.labels[0].textContent = "Offer ID (12345678 or *)";
        else
            this.labels[0].textContent = "Offer ID";
    });

    ///////////////////////////////////////////////////////////////////
    // Offer Type input listeners

    const offerTypeInput = document.getElementById('u-bypass-form-offerType');

    offerTypeInput.addEventListener('input', function () {
        if (this.value.length > 100) {
            this.value = this.value.substring(0, 100);
            fireDialog('Offer Type cannot exceed 100 characters.', 'error', 1500);
        }
        updateTable();
    });

    offerTypeInput.addEventListener('keydown', function (e) {
        // Allow alphanumeric and *
        const disallowedKeys = ".,;:?!+-=/|\\<>()[]#$%^&@{}\"\'`~";

        if (disallowedKeys.indexOf(e.key.toLowerCase()) > -1)
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
        if (this.value.length == 0)
            this.labels[0].textContent = "Offer Type (Citi Strata or *)";
        else
            this.labels[0].textContent = "Offer Type";
    }); 

    ///////////////////////////////////////////////////////////////////
    // Last Modified By input listeners

    const lastModifiedBy = document.getElementById('u-bypass-form-lastModifiedBy');

    // Prevent typing by blocking key events   
    lastModifiedBy.addEventListener('input', function (e) {
        updateTable();
    });

    lastModifiedBy.addEventListener('change', function (e) {
        updateTable();
    });

    ///////////////////////////////////////////////////////////////////
    // Last Modified Date input listeners

    const lastModifiedDateInput = document.getElementById('u-bypass-form-lastModifiedDate');

    // Prevent typing by blocking key events   
    lastModifiedDateInput.addEventListener('change', function (e) {
        updateTable();
    });

    ///////////////////////////////////////////////////////////////////
    // New Configuration Button listeners

    const newConfigurationButton = document.getElementById('new-config-button');
    newConfigurationButton.addEventListener('click', function (e) {
        var uri = "./BypassConfig.aspx?";

        const application = applicationInput.value;
        uri += `application=${application}`;

        const language = languageInput.value;
        uri += `&language=${language}`;

        const dnis = document.getElementById('u-bypass-form-dnis').value;
        uri += `&dnis=${dnis}`;

        const destination = document.getElementById('u-bypass-form-destinationPhoneNumber').value;
        uri += `&destination=${destination}`;

        const rank = document.getElementById('u-bypass-form-rank').value;
        uri += `&rank=${rank}`;

        const offerID = document.getElementById('u-bypass-form-offerId').value;
        uri += `&offerID=${offerID}`;

        const offerType = document.getElementById('u-bypass-form-offerType').value;
        uri += `&offerType=${offerType}`;

        const peg = document.getElementById('u-bypass-form-peg').value;
        uri += `&peg=${peg}`;

        // Encode and navigate to url
        var url = encodeURI(uri);

        window.location.href = url;
    });

    ///////////////////////////////////////////////////////////////////
    // Date Picker Input listeners

    // Set the label for the last modified date to inactive when the date is cleared
    const datePickerInput = document.getElementById('u-bypass-form-lastModifiedDate');
    datePickerInput.addEventListener('change', function (e) {
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
                updateTable();
            }
        }
    })    

    datePickerInput.addEventListener('input', function () {
        if (this.value.length > 12) {
            this.value = this.value.substring(0, 12);
            fireDialog('Invalid date format.', 'error', 1500);
        }       
    });

    datePickerInput.addEventListener('focus', function () {
        if (this.value.length == 10) {
            this.value = this.value.replace(/\//g, "");
        }
    });

    datePickerInput.addEventListener('blur', function () {
        if (this.value.length == 8) {
            this.value = formatMMDDYYYY(this.value)
        }
    });
}

function updateControls() {
    const items = document.querySelectorAll('.configurationAppRow');

    items.forEach(function (row) {
        //console.log(`${JSON.stringify(row)}`);
        row.classList.add('dt-hasChild');
        row.classList.add('shown');
    });
}

function updateTable(action = 'default') {
    //console.log('updating table')
    summaryTable.ajax.reload(function (data) {
        // This callback function will be executed after the reload is complete
        //console.log('Data reloaded:', data); // Optional: You can inspect the reloaded data here

        // Simulate scroll (this will happen after the reload)
        window.scrollTo(window.scrollX + 1, window.scrollY + 1);
        window.scrollTo(window.scrollX - 1, window.scrollY - 1);

        // Call updateControls() now that the reload is finished
        updateControls();

        // Add draggable properties to children
        addTableProperties();

        // We want to disable drag an drop functionality when filtering
        checkForFiltering();

        if (action == 'refresh') {
            fireDialog('Table refreshed!', 'success', 1500);
        }
    });
}

function checkForFiltering() {
    if (
        $('#u-bypass-form-application').val() ||
        $('#u-bypass-form-language').val() ||
        $('#u-bypass-form-dnis').val() ||
        $('#u-bypass-form-destinationPhoneNumber').val() ||
        $('#u-bypass-form-peg').val() ||
        $('#u-bypass-form-rank').val() ||
        $('#u-bypass-form-offerId').val() ||
        $('#u-bypass-form-offerType').val() ||
        $('#u-bypass-form-lastModifiedBy').val() ||
        $('#u-bypass-form-lastModifiedDate').val()
    ) {
        // Do something if any field has a non-empty value
        const dragAndDropElements = document.querySelectorAll('.drag-and-drop');
        dragAndDropElements.forEach((element) => {
            element.classList.remove('drag-and-drop');
            element.setAttribute('draggable', false);
        })
    }
}