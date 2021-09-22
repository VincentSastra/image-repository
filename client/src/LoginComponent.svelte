<script>
	export let accessToken = "", UserPoolId, ClientId

	let signUp, signIn, verify, username, email, resendToken, error
	
	let awsOnload = () => {
		console.log({UserPoolId, ClientId})
		const CognitoUserPool = AmazonCognitoIdentity.CognitoUserPool;

		console.log(CognitoUserPool)

		const poolData = {
			UserPoolId, 
			ClientId 
		};
		const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData)

		signUp = async (e) => {
			error = ""
			const dataEmail = {
				Name: 'email',
				Value: e.target[2].value,
			};
			username = e.target[0].value
			email = e.target[2].value

			userPool.signUp(e.target[0].value, e.target[1].value, [dataEmail], null, (err, res) => {
				if (err) {
					error = err
					return 
				}
				content = "verify"
			})

			const userData = {
				Username:  username,
				Pool: userPool,
			};
			const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);
			resendToken = () => cognitoUser.resendConfirmationCode((err) => { error = err } )
		}
		
		signIn = async (e) => {
			error = ""
			const authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails({
				Username: e.target[0].value, Password: e.target[1].value
			});
			const userData = {
				Username:  e.target[0].value,
				Pool: userPool,
			};
			const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);
			cognitoUser.authenticateUser(authenticationDetails, {
				onSuccess: function(result) {
					accessToken = result.idToken.jwtToken
					showModal = false
				},

				onFailure: (err) => { error = err },
			});
		}

		verify = async (e) => {
			error = ""
			const userData = {
				Username:  username,
				Pool: userPool,
			};
			const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);

			cognitoUser.confirmRegistration(e.target[0].value, true, function(err, result) {
				if (err) {
					error = err
					return
				}
				content = "signin"
			});
		}
	}
		
	let showModal = false
	let content = null
</script>
<svelte:head>
	<script src="./amazon-cognito-identity.min.js" on:load={awsOnload}></script>
</svelte:head>

<div>
	{#if showModal}
		<div on:click={() => {showModal = false}} 
			class="fixed z-40 w-full h-full bg-black bg-opacity-80 flex justify-center">
			<div class="modal-content" on:click={(e) => e.stopPropagation()}>
				{#if content === "signup"}
					<form on:submit|preventDefault={signUp}>
						{#if error}
							<div class="text-red">{error.message || JSON.stringify(error)}</div>
						{/if}

						<div class="py-8 text-lg">
							<b>Sign up</b> 
							for an account. A verification email will be sent to your email
						</div>

						<div>Username</div>
						<input>
						<div>Password</div>
						<input type="password">
						<div>Email</div>
						<input type="email">
						
						<button class="submit-button" type="submit">
							Sign up
						</button>
					</form>
				{:else if content === "signin"}
					<form on:submit|preventDefault={signIn}>
						{#if error}
							<div class="text-red w-full">{error.message || JSON.stringify(error)}</div>
						{/if}
						
						<div class="py-8 text-lg">
							<b>Login</b> 
							use your own account or login with the example credentials
						</div>

						<div>Username</div>
						<input value="example">
						<div>Password</div>
						<input type="password" value="HelloW0rld!">
						<button class="submit-button" type="submit">
							Log in
						</button>
					</form>
				{:else}	
					<form on:submit|preventDefault={verify}>
						{#if error}
							<div class="text-red w-full">{error.message || JSON.stringify(error)}</div>
						{/if}

						<div class="py-8 text-lg">
							<b>Verify</b> 
							your email by submitting the access token sent to your email
						</div>

						<div>Verification Code</div>
						<input>
						
						<button class="submit-button" type="submit">
							Verify Token
						</button>
						<div>Did not get the email? <a on:click={function() { resendToken() }}>Resend Token</a></div>
					</form>
				{/if}
			</div>
		</div>
	{/if}
</div>
	
<div class="flex justify-end bg-primary">
	{#if accessToken !== ""}
		<button 
		class="bg-opacity-0 hover:bg-opacity-100 bg-white p-4 border-t-0 border-b-0 border-black"
		on:click={() => accessToken = ""}>Sign Out</button>
	{:else}
		<button 
			class="bg-opacity-0 hover:bg-opacity-100 bg-white p-4 border-t-0 border-b-0 border-black border-r-0"
			on:click={() => {
				showModal = true
				content = "signin"
		}}>Login</button>

		<button
		class="bg-opacity-0 hover:bg-opacity-100 bg-white p-4 border-t-0 border-b-0 border-black"
		on:click={() => {
				showModal = true
				content = "signup"
		}}>Sign Up</button>
	{/if}
	<div class="bg-secondary rounded-full h-8 w-8 my-auto mx-4">

	</div>
	<div class="my-auto pr-4 ">
		Image Repository
	</div>
</div>

{#if accessToken === ""}
	<div class="pt-40 mb-8 text-center text-4xl">Login or Sign up to use this website</div>
	<div class="w-full flex justify-center content-center">
		<button on:click={() => {
			showModal = true;
			content = "signin"
		}} class="standard-button mr-12">Login</button>
		<button on:click={() => {
			showModal = true;
			content = "signup"
		}} class="standard-button">Sign up</button>
	</div>
{/if}

<style global lang="postcss">
	@tailwind base;
	@tailwind components;
	@tailwind utilities;
	.modal-content {
		background-color: #FFFFFF;
		height: 70%;
		margin: auto;		
		width: 80%;
		max-width: 350px;
		box-shadow: 0 3px 10px rgb(0 0 0 / 0.2);	
	}
	
	form {
		display: flex;
		flex-direction: column;
		height: 100%;
		width: 100%;
		justify-content: center;
		padding: 0px 20%;
		background-color: #EEEEEE;
		overflow-y: auto;
	}

	form > input {
		@apply mb-5 p-1;
	}

	.submit-button {
		padding: 8px;
		display: flex;
		justify-content: center;
		@apply bg-primary hover:bg-white;
	}
</style>