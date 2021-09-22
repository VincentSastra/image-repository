<script>
import PhotoGridComponent from "./PhotoGridComponent.svelte"

	export let baseUrl, accessToken

	let inputArray = []
	let inputHTMLElement
	
	const onInputChange = (e) => {
		const filesToArray = [...e.target.files]
		filesToArray.forEach(async file => {
			// Read each file as a data url to be displayed back to the user
			const reader = new FileReader()
            reader.readAsDataURL(file);
            reader.onload = (e) => { 
				inputArray = [...inputArray, {url: e.target.result, file}]
			}
		})
	};

	const uploadAllPhotos = () => inputArray.forEach(async item => {
		const res = await fetch(`${baseUrl}/item/${item.file.name}`, {
			method: 'PUT',
			body: item.file,
			headers: {
				Authorization: accessToken
			}
		})
		console.log(res)
	})
</script>

<div class="bg-primary bg-opacity-30">
	<div class="p-8 text-2xl text-center w-full mt-8">
		Upload Pictures
	</div>
	<div class="flex justify-center w-full pb-8">
		<div class="upload-box rounded-xl">
			<div class="dashed-box flex content-center flex-col justify-between">
				{#if  inputArray.length > 0}
				<PhotoGridComponent 
				small={true}
				imageArray={inputArray.map(item => ({url: item.url, name: item.file.name}))}
				/>
				{:else}
				<div class="mt-32 text-center w-full text-2xl">
					Select some pictures from your computer
				</div>
				{/if}
				
				<div class="flex justify-center my-8">
					<button class="standard-button" on:click={() => inputHTMLElement.click()}>Choose Image</button>
					{#if inputArray.length > 0}
					<button class="standard-button ml-12" on:click={uploadAllPhotos}>Upload</button>
					{/if}
					<input class="hidden" type="file" accept=".jpg, .jpeg, .png" on:change={onInputChange} bind:this={inputHTMLElement} multiple>			
				</div>
			</div>
		</div>
	</div>
</div>
	
<style global lang="postcss">
	.upload-box {
			display: flex;
			width: 70vw;
			min-height: 40vw;
			border: 1px solid grey;
			@apply bg-grey;
	}

	.dashed-box {
		margin: 12px;
		padding: 12px;
		flex-grow: 1;
		border: 4px dashed grey;
	}
</style>