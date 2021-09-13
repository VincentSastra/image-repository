<script>
	export let url, userName

	let inputArray = []
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
	{#each inputArray as item}
		<img class="w-16 h-16" src={item.url} alt={item.file.name} />
		<div>{item.file.name}</div>
	{/each}
	<button on:click={() => inputHTMLElement.click()}>Choose Image</button>
	<button on:click={() => inputArray.forEach(async item => {
		const res = await fetch(`${url}/item/${userName}/${item.file.name}`, {
			method: 'PUT',
			body: item.file
		})
		console.log(res)
	})}>Upload</button>
	<input class="hidden" type="file" accept=".jpg, .jpeg, .png" on:change={onInputChange} bind:this={inputHTMLElement} multiple>
</div>
 