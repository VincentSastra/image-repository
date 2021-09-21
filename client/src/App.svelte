<script>
	import AuthWidget from "./AuthWidget.svelte"
	import FileUploadWidget from "./FileUploadWidget.svelte"
import ImageGallery from "./ImageGallery.svelte";

	let accessToken

	// Load all the environment variables from the env.json file in S3
	let env = {}	
	const getEnv = async () => {
		const res = await fetch("http://" + window.location.host + "/env.json")
		const json = await res.json()
		console.log(json)
		env = json
	}
	getEnv()
</script>

<div>
	<AuthWidget bind:accessToken={accessToken} bind:ClientId={env.cognitoClientId} bind:UserPoolId={env.UserPoolId} />
	<ImageGallery bind:accessToken={accessToken} baseUrl={env.apigatewayEndpoint} />
	<FileUploadWidget baseUrl={env.apigatewayEndpoint} accessToken={accessToken} />
</div>

<style global lang="postcss">
	@tailwind base;
	@tailwind components;
	@tailwind utilities;
	:global(body) {
		background-color: #FFFFFF;
	}
</style>
