<script>
	export let baseUrl, accessToken

	// Create the images to be rendered
	let imageURLList = [
		"https://picsum.photos/200/300",
		"https://picsum.photos/200/600",
		"https://picsum.photos/400/300",
		"https://picsum.photos/600/300",
		"https://picsum.photos/300/300",
		"https://picsum.photos/800/300"
	]

	// Populate the imageURLList array with the image's URLs
	const getImages = async () => {
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
			return URL.createObjectURL(blob)
		}))
	}
</script>

<body>
	<div class="photo-grid">
		{#each imageURLList as imageURL}
			<div class="photo-div">
				<img src={imageURL} alt={imageURL} class="absolute background-image" />
				<img src={imageURL} alt={imageURL} />
				<div class="image-title">{imageURL.split("/").slice(-1)[0]}</div>
			</div>
		{/each}
	</div>
	<div class="flex w-full justify-center">
		<button class="px-12 py-4 bg-primary border-1 hover:bg-white"
			on:click={getImages}>{imageURLList.length > 0 ? "Refresh Images" : "Get Images"}</button>
	</div>
</body>


<style global lang="postcss">
	@tailwind base;
	@tailwind components;
	@tailwind utilities;
	
	.photo-grid {
		grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
		display: grid;
		grid-gap: 1rem;
		padding: 0px;
		@apply justify-center p-8;
	}

	.photo-div {
		width: 320px;
		height: 340px;
		display: flex;
		flex-direction: column;
		align-content: center;
	}

	img {
		max-width: 320px;
		max-height: 300px;
		flex-grow: 1;
		object-fit: contain;
		z-index: 10;
	}

	.background-image {
		width: 320px;
		height: 300px;
		display: absolute;
		z-index: 0;
		object-fit: cover;

		filter: blur(10px);
		opacity: 0.4;
	}

	.image-title {
		font-size: x-large;
		height: 40px;
		text-align: center;
		vertical-align: center;
		@apply bg-white;
	}
</style>