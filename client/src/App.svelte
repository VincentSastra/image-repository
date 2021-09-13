<script>
	let name = "world";
</script>

<div>
	<h1>Hello {name}!</h1>
</div>

<style global lang="postcss">
	@tailwind base;
	@tailwind components;
	@tailwind utilities;
	:global(body) {
		background-color: #2B4570;
	}
</style>
