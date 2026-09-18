import "./FilterForm.css";

function FilterForm() {
	return (
		<div id="filter-form-panel">
			<div id="filter-top-row" className="filter-row">
				<FilterElement elementId="application" placeholder="Application"></FilterElement>
				<FilterElement elementId="language" placeholder="Language"></FilterElement>
				<FilterElement elementId="dnis" placeholder="DNIS"></FilterElement>
				<FilterElement elementId="ped" placeholder="Peg"></FilterElement>
			</div>
			<div id="filter-bottom-row" className="filter-row">
				<FilterElement elementId="rank" placeholder="Rank"></FilterElement>
				<FilterElement elementId="offerId" placeholder="Offer ID"></FilterElement>
				<FilterElement elementId="offerType" placeholder="Offer Type"></FilterElement>
				<FilterElement elementId="lastModifiedBy" placeholder="Last Modified By"></FilterElement>
				<FilterElement elementId="lastModifiedDate" placeholder="Last Modified Date"></FilterElement>
			</div>
		</div>
	);
}

function FilterElement(props: { elementId: string; placeholder: string }) {
	return (
		<div id={props.elementId + "input-field"} className="filter-input-field">
			<label id={props.elementId + "-label"} className="filter-label" htmlFor={props.elementId + "-input"}>
				{props.placeholder}
			</label>
			<input id={props.elementId + "-input"} className="filter-input" type="search" placeholder={props.placeholder}></input>
		</div>
	);
}

export default FilterForm;
