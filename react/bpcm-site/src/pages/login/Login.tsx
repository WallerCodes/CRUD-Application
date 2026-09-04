import logo from "../../assets/USAN-Logo-White.svg";
import "./Login.css";

function Login() {
  const handleSubmit: React.MouseEventHandler<HTMLButtonElement> = (event) => {
    event.preventDefault();
    console.log("Link clicked!");
  };

  const onEmailBlur: React.FocusEventHandler<HTMLInputElement> = () => {};

  return (
    <>
      <div id="login-container">
        <form id="login-form">
          <img className="logo" src={logo} alt="Error loading logo" />
          <input id="email-input" className="Email" type="text" placeholder="Email" onBlur={onEmailBlur} required />
          <input id="password-input" className="Password" type="password" placeholder="Password" required />
          <button id="login-button" onClick={handleSubmit} type="submit">
            Login
          </button>
          <br />
        </form>
      </div>
    </>
  );
}

export default Login;
