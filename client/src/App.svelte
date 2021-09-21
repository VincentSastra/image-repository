<script>
	import FileUploadComponent from "./FileUploadComponent.svelte";
	import ImageGalleryComponent from "./ImageGalleryComponent.svelte";
	import LoginComponent from "./LoginComponent.svelte";

	let accessToken

	// Load all the environment variables from the env.json file in S3
	let env = null
	const getEnv = async () => {
		const res = await fetch("http://" + window.location.host + "/env.json")
		const json = await res.json()
		console.log(json)
		env = json
	}
	getEnv()
</script>

<div>
	{#if env !== null}	
		<LoginComponent bind:accessToken={accessToken} bind:ClientId={env.cognitoClientId} bind:UserPoolId={env.cognitoUserPoolId} />
		<ImageGalleryComponent bind:accessToken={accessToken} baseUrl={env.apigatewayEndpoint} />
		<FileUploadComponent baseUrl={env.apigatewayEndpoint} accessToken={accessToken} />
	{/if}
</div>

<style global lang="postcss">
	@tailwind base;
	@tailwind components;
	@tailwind utilities;
	:global(body) {
		background-color: #FFFFFF;
		margin: 0px;
		padding: 0px;
	}
</style>
