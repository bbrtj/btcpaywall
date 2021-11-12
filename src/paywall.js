import "./styles.scss";
import "bootstrap";

document.addEventListener('DOMContentLoaded', (event) => {
	let el = document.getElementById('address-field');

	el.addEventListener('copy', (e) => {
		let address = el.getAttribute('data-address');

		navigator.clipboard.writeText(address);
	});
});
