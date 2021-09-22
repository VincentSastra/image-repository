<script>
	export let baseUrl, accessToken

	let inputArray = [
	
	]
	let inputHTMLElement
	
	function onInputChange(e) {
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
</script>

<div id="app">
	<div>
		{#each inputArray as item}
			<div>
				<img class="w-16 h-16" src={item.url} alt={item.file.name} />
				<div>{item.file.name}</div>
			</div>
		{/each}
	</div>
	<button on:click={() => inputHTMLElement.click()}>Choose Image</button>
	<button on:click={() => inputArray.forEach(async item => {
		const res = await fetch(`${baseUrl}/item/${item.file.name}`, {
			method: 'PUT',
			body: item.file,
			headers: {
				Authorization: accessToken
			}
		})
		console.log(res)
	})}>Upload</button>
	<input class="hidden" type="file" accept=".jpg, .jpeg, .png" on:change={onInputChange} bind:this={inputHTMLElement} multiple>
</div>
 