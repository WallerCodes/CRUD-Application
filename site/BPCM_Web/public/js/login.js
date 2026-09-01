$(document).ready(function () {
    setFrameSize();

    performerUserEmail = '';
    localStorage.setItem('email', '');

    // Trigger a reflow to force style re-application
    const input = document.querySelector('input.Email');

    $('form').submit(function (e) {
        e.preventDefault();
    });
});

function validateEmailPassword() {
    var email = $(".Email").val();
    var password = $(".Password").val();

    if (password == "") {
        return;
    }

    const hash = Sha256.hash(password);


    if (!validateEmail(".Email")) {
        return;
    }

    $.post("./api/ValidateLogin.ashx",
        {
            performerUserEmail: email,
            password: hash
        },
        function (data, status) {
            //login success
            try {
                data = JSON.parse(data);
                if (status == 'success' && data.success === true && !data.isLocked) {
                    localStorage.setItem('email', email);
                    window.location.href = './Bypass.aspx';
                    performerUserEmail = email;          
                    localStorage.setItem('activityTimer', Date.now());
                }
                else if (data.isLocked) {
                    fireDialog('Your account is locked. Please contact an administrator', 'error', 3500);
                }
                else {
                    if (data.error) {
                        console.log('error')
                        fireDialog(data.error, 'error', 3500);
                    }
                    else {
                        fireDialog('Email or Password is incorrect! Please try again', 'error', 3500);
                    }
                }
            }
            catch (e) {
                fireDialog('Email or Password is incorrect! Please try again', 'error', 3500);
            }
        }
    );
}