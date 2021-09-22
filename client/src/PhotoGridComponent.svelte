<script>
	export let imageArray;
	export let small;
</script>

<div class={`photo-grid ${small ? "sm" : "lg"}`}>
	{#each imageArray as image}
		<div class="photo-div">
			<img src={image.url} alt={image.name} class="absolute background-image" />
			<img src={image.url} alt={image.name} />
			<div class="image-title">{image.name}</div>
		</div>
	{/each}
</div>

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

	.photo-grid.sm {
		grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
	}

	.photo-div {
		width: 320px;
		height: 340px;
		display: flex;
		flex-direction: column;
		align-content: center;
	}

	.sm > .photo-div {
		width: 160px;
		height: 170px;
	}

	img {
		max-width: 320px;
		max-height: 300px;
		flex-grow: 1;
		object-fit: contain;
		z-index: 10;
	}

	.sm > .photo-div > img {
		max-width: 160px;
		max-height: 150px;
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

	.sm > .photo-div > .background-image {
		width: 160px;
		height: 150px;
	}

	.image-title {
		font-size: x-large;
		height: 40px;
		text-align: center;
		vertical-align: center;
		background-color: transparent;
	}

	.sm > .photo-div > .image-title {
		font-size: large;
		height: 20px;
	}
</style>