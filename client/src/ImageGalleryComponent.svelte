<script>
import PhotoGridComponent from "./PhotoGridComponent.svelte"

	export let baseUrl, accessToken

	// Create the images to be rendered
	let imageURLList = []
	let loading = false

	// Populate the imageURLList array with the image's URLs
	const getImages = async () => {
		loading = true

		// Request a list of all images from the user's folder
		const res = await fetch(`${baseUrl}/list`, {
			headers: {
				Authorization: accessToken
			}
		})
		const body = await res.text()

		// Parse the xml folder returned by API
		const xmlParser = new DOMParser()
		const keyList = [...xmlParser.parseFromString(body, "text/xml").getElementsByTagName("Contents")]
			.map(contentXML => contentXML.getElementsByTagName("Key")[0].innerHTML)
			// Only match the keys and not folder names
			.filter(key => /.+\/.+/.test(key))
			// Get the key name only, without the first folder
			// The first folder is the User's URL which will be set by the
			// Cognito Authorizer
			.map(key => key.match(/(?<=\/).*/)[0])

		// Get the images for each imageURL
		// Use fetch because we need to pass the accessToken and
		// src does not accept headers
		imageURLList = await Promise.all(keyList.map(async url => {
			const res = await fetch(`${baseUrl}/item/${url}`, {
				headers: {
					Authorization: accessToken
				}
			})
			const blob = await res.blob()
			return {url: URL.createObjectURL(blob), name: url.match(/[^\/]+$/)[0]}
		}))
		loading = false
	}
</script>

<body>
	{#if loading}
		<div
			class="fixed w-full h-full flex justify-center content-center bg-black bg-opacity-10" 
		>
			<img class="h-20 w-20 m-auto" src="./tailspin.svg" alt="Loading" />
		</div>
	{/if}
	<PhotoGridComponent 
		imageArray={imageURLList}
	/>
	<div class="flex w-full justify-center">
		<button class="standard-button"
			on:click={getImages}>{imageURLList.length > 0 ? "Refresh Images" : "Get Images"}</button>
	</div>
</body>