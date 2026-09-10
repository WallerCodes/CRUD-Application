import logo from "../../assets/USAN-Logo-White.svg";
import "./Login.css";
import { useState, useEffect } from "react";

interface User {
  id: string;
  userName: string;
  password: string;
  isDeleted: boolean;
  isDisabled: boolean;
  isSuperAdmin: boolean;
  isUsanUser: boolean;
  lastLogin: Date;
  isLocked: boolean; // account locked out

  failedLoginAttempts: number;
  lastPasswordChangeDate: Date;
  forceChangePassword: boolean;
  dateAdded: Date;

  success: boolean; // was the user action successful or not
  // userRoles:List;
}

function Login() {
  const [user, setUser] = useState<User>();
  const [email, setEmail] = useState<string>();
  const [password, setPassword] = useState<string>();

  return (
    <>
      <div id="login-container">
        <form id="login-form">
          <img className="logo" src={logo} alt="Error loading logo" />
          <input id="email-input" type="text" placeholder="Email" onChange={(e) => setEmail(e.target.value)} required />
          <input id="password-input" type="password" placeholder="Password" onChange={(e) => setPassword(e.target.value)} required />
          <button id="login-button" onClick={handleSubmit} type="submit">
            Login
          </button>
          <br />
        </form>
      </div>
    </>
  );

  async function handleSubmit() {
    var response = await fetch("/api/database/ValidateLogin", {
      headers: {
        "Content-Type": "application/json",
      },
      method: "POST",
      body: JSON.stringify({
        username: "123",
        password: "123",
      }),
    });

    console.log("status:", response.status);
    console.log("content type:", response.headers.get("content-type"));

    var text = await response.text();
    console.log("raw response:", text);
  }
}

export default Login;
