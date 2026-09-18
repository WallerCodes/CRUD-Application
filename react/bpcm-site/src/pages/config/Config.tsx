import FilterForm from "../../components/FilterForm";
import "./Config.css";
import ConfigTable from "./ConfigTable";

function Config() {
	console.log("config");
	return (
		<div id="config-container">
			<div id="header-container"></div>
			<FilterForm />
			<div id="create-config-container">
				<button>Create New Configuration</button>
			</div>
			<ConfigTable />
		</div>
	);
}

export default Config;
