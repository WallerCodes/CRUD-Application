import logo from "../../assets/USAN-Logo-White.svg";
import "./Login.css";
import { GetUserContext } from "../../UserProvider.tsx";
import { useState } from "react";
import { type User } from "../../models/User";
import { useNavigate } from "react-router";

function Login() {
	const [email, setEmail] = useState<string>();
	const [password, setPassword] = useState<string>();
	const context = GetUserContext(); // errors if context is null
	const setUser = context.setUser;
	let navigate = useNavigate();

	return (
		<>
			<div id="login-container">
				<form id="login-form" onSubmit={(e) => handleSubmit(e)}>
					<img className="logo" src={logo} alt="Error loading logo" />
					<input id="email-input" type="email" placeholder="Email" onChange={(e) => setEmail(e.target.value)} required />
					<input id="password-input" type="password" placeholder="Password" onChange={(e) => setPassword(e.target.value)} required />
					<button id="login-button" type="submit">
						Login
					</button>
					<br />
				</form>
			</div>
		</>
	);

	async function handleSubmit(e: React.SubmitEvent<HTMLFormElement>) {
		e.preventDefault();
		var response = await fetch("/api/database/ValidateLogin", {
			headers: {
				"Content-Type": "application/json",
			},
			method: "POST",
			body: JSON.stringify({
				username: email,
				password: password,
			}),
		});

		if (response.ok) {
			var user = (await response.json()) as User;
			setUser(user);
			navigate("/Config.tsx");
		} else if (response.status == 401) {
			// console.error("incorrect password");
		} else if (response.status == 404) {
			// console.error("user not found password");
		} else {
			console.error("unexpected error");
		}
	}
}

export default Login;
