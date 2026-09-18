import "../../models/ConfigData";
import "./ConfigTable.css";
import { GetUserContext } from "../../UserProvider.tsx";
import type { ConfigData } from "../../models/ConfigData";
import { useState, useEffect } from "react";

function ConfigTable() {
	return (
		<div id="config-table-container">
			<ConfigTableHeader />
			<ConfigTableData />
		</div>
	);
}

function ConfigTableHeader() {
	return (
		<div id="config-table-header">
			<div className="config-table-header-label config-table-block">Language</div>
			<div className="config-table-header-label config-table-block">DNIS</div>
			<div className="config-table-header-label config-table-block">Destination</div>
			<div className="config-table-header-label config-table-block">Rank</div>
			<div className="config-table-header-label config-table-block">Offer ID</div>
			<div className="config-table-header-label config-table-block">Offer Type</div>
			<div className="config-table-header-label config-table-block">Peg</div>
			<div className="config-table-header-label config-table-block">Skill ID</div>
			<div className="config-table-header-label config-table-block">Skill Name</div>
			<div className="config-table-header-label config-table-block">Agents Available</div>
			<div className="config-table-header-label config-table-block">MED</div>
			<div className="config-table-header-label config-table-block">Overflow Skill ID</div>
			<div className="config-table-header-label config-table-block">Overflow Skill Name</div>
			<div className="config-table-header-label config-table-block">Overflow Agents Available</div>
			<div className="config-table-header-label config-table-block">Overflow MED</div>
			<div className="config-table-header-label config-table-block">Last Modified By</div>
			<div className="config-table-header-label config-table-block">Last Modified Date</div>
		</div>
	);

	function CofigTableRow(props: { isHeaderRow: boolean; draggable: boolean; configData: ConfigData }) {}
}

function ConfigTableData() {
	const [data, setData] = useState([]);

	const context = GetUserContext();
	const user = context.user;

	useEffect(() => {
		async function getConfigData(): Promise<void> {
			var response = await fetch("/api/database/GetConfigurations", {
				headers: {
					"Content-Type": "application/json",
				},
				method: "POST",
				body: JSON.stringify({
					// username: user,
					username: "noah.wallace@usan.com",
				}),
			});

			if (!response.ok) console.error("unexpected error");

			setData(await response.json());
		}		
		// console.log(data)
		getConfigData();
	}, []); // call once

	let rowsCreated: Set<string> = new Set()

	return <>{
		data.map((config: ConfigData) => {
			if(!rowsCreated.has(config.application)){				
				rowsCreated.add(config.application)
				return <>
					<div key={crypto.randomUUID()} className="config-table-data-row config-table-collapsible">{config.application}</div>
					<DataRow config={config}/>
				</>
			}			

			return <DataRow config={config}/>
				
		})}
		</>;

	function DataRow({config}: {config:ConfigData}) {
		// Use type assertion (as Array<keyof User>) so TypeScript knows the exact keys
		return (
			<div className="config-table-data-row">
				{(Object.keys(config) as Array<keyof ConfigData>).map((key) => {
					if(!["crudId", "order", "application","applicationId","languageId", "lastModifiedUserId"].includes(key.toString()))
					return (
						<div key={crypto.randomUUID()} id={"config-table-data-" + key} className="config-table-data-element config-table-block">
							{key.toString() == "lastModifiedDateTime" ? 
								new Date(config[key].toString()).toLocaleDateString('en-US') : 
								config[key]
							}
						</div>
					);
				})}
				<button className="config-table-button">Edit</button>
				<button className="config-table-button">Copy</button>
				<button className="config-table-button">Delete</button>
			</div>
		);
	}
}

export default ConfigTable;
