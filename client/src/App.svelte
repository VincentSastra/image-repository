<script>
import AuthWidget from "./AuthWidget.svelte"
import FileUploadWidget from "./FileUploadWidget.svelte"

	const apiEndpoint = "https://z53n0uy9j0.execute-api.us-east-2.amazonaws.com/production"

	// To do create a user account
	const userName = "root"

	let imageKeyList = []

	const xmlParser = new DOMParser()

	const getImages = async () => {
		// Request a list of all images from the user's folder
		const res = await fetch(`${apiEndpoint}/list/${userName}`)
		const body = await res.text()

		// Parse the xml folder returned by API
		imageKeyList = [...xmlParser.parseFromString(body, "text/xml")
			.getElementsByTagName("Contents")]
			.map(contentXML => contentXML.getElementsByTagName("Key")[0].innerHTML)
			// Only match the keys and not folder names
			.filter(key => key.match(/.+\/.+/))
	}
</script>

<div>
	<AuthWidget />
	{#each imageKeyList as imageKey}
		<img src={`${apiEndpoint}/item/${imageKey}`} alt={imageKey} />
	{/each}
	<button on:click={getImages}>Get Image</button>
	<FileUploadWidget url={apiEndpoint} userName={userName} />
</div>

<style global lang="postcss">
	@tailwind base;
	@tailwind components;
	@tailwind utilities;
	:global(body) {
		background-color: #FFFFFF;
	}
</style>
