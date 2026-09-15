
export interface User {
	userId: string;
	username: string;
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
	userRoles: UserRole[];
}

export interface UserRole {
	Username: string;
	Application: string;
	Role: string;
}