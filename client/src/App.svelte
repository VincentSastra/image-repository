<script>
	import AuthWidget from "./AuthWidget.svelte"
	import FileUploadWidget from "./FileUploadWidget.svelte"

	const apiEndpoint = "https://gc0luje0lc.execute-api.us-east-2.amazonaws.com/production"

	let imageKeyList = []
	let accessToken
	const xmlParser = new DOMParser()

	const getImages = async () => {
		// Request a list of all images from the user's folder
		const res = await fetch(`${apiEndpoint}/list`, {
			headers: {
				Authorization: accessToken
			}
		})
		const body = await res.text()

		// Parse the xml folder returned by API
		const keyList = [...xmlParser.parseFromString(body, "text/xml")
			.getElementsByTagName("Contents")]
			.map(contentXML => contentXML.getElementsByTagName("Key")[0].innerHTML)
			// Only match the keys and not folder names
			.filter(key => /.+\/.+/.test(key))
			.map(key => key.match(/[^/]+$/)[0])

		imageKeyList = await Promise.all(keyList.map(async url => {
			const res = await fetch(`${apiEndpoint}/item/${url}`, {
				headers: {
					Authorization: accessToken
				}
			})
			const blob = await res.blob()
			return URL.createObjectURL(blob)
		}))
	}
</script>

<div>
	<AuthWidget bind:accessToken={accessToken} />
	{accessToken}
	{#each imageKeyList as imageKey}
		<img src={imageKey} alt={imageKey} />
	{/each}
	<button on:click={getImages}>Get Image</button>
	<FileUploadWidget url={apiEndpoint} accessToken={accessToken} />
</div>

<style global lang="postcss">
	@tailwind base;
	@tailwind components;
	@tailwind utilities;
	:global(body) {
		background-color: #FFFFFF;
	}
</style>
