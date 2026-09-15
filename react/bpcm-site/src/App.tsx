import "./App.css";
import Login from "./pages/login/Login";
import { Routes, Route, BrowserRouter } from "react-router";
import { UserProvider } from "./UserProvider.tsx";
import Config from "./pages/config/Config.tsx";

function App() {
	return (
		<UserProvider>
			<BrowserRouter>
				<Routes>
					<Route path="/Login.tsx" element={<Login />} />
					<Route path="/Config.tsx" element={<Config />} />
					<Route path="*" element={<p>Path not resolved</p>} />
				</Routes>
			</BrowserRouter>
		</UserProvider>
	);
}

export default App;
