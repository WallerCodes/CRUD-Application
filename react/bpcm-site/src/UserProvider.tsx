import { createContext, useState, useContext } from "react";
import { type User } from "./models/User";

interface UserContextType {
	user: User | null;
	setUser: React.Dispatch<React.SetStateAction<User | null>>;
}

const UserContext = createContext<UserContextType | null>(null); // context that will be accessible from any child of a UserProvider node

export function UserProvider(props: { children: React.ReactNode }) {
	// children is child tree of UserProvider (anything wrapped in <UserProvider><UserProvider/>) -> extracted from props which is always passed
	// destructure and take children property from props
	const [user, setUser] = useState<User | null>(null);
	// const [user, setUser] = useState<User>(); // user will be undefined - semantically the same as null

	return <UserContext.Provider value={{ user, setUser }}>{props.children}</UserContext.Provider>;
}

// allows us to not have to deal with null values for every context call in components
export function GetUserContext() {
	const context = useContext(UserContext);

	if (context === null) {
		throw new Error("GetUserContext must be used inside child of UserProvider");
	}

	return context;
}

export default UserContext;
