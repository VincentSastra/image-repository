<script>
	export let accessToken = "", UserPoolId, ClientId

	let signUp, signIn, signOut, verify
	
	let awsOnload = () => {
		const CognitoUserPool = AmazonCognitoIdentity.CognitoUserPool;

		console.log(CognitoUserPool)

		const poolData = {
			UserPoolId, 
			ClientId 
		};
		const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData)

		signUp = async(e) => {
			const dataEmail = {
				Name: 'email',
				Value: e.target[2].value,
			};
			userPool.signUp(e.target[0].value, e.target[1].value, [dataEmail], null, (err, res) => {
				if (err) {
					console.log(err)
					return 
				}
				({user, userSub} = res)
			})
		}
		
		signIn = async(e) => {
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
					console.log(result.idToken)
					accessToken = result.idToken.jwtToken
				},

				onFailure: function(err) {
					console.log(err)
					alert(err.message || JSON.stringify(err));
				},
			});
		}

		verify = async (e) => {
			const userData = {
				Username:  e.target[0].value,
				Pool: userPool,
			};
			const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);
			cognitoUser.confirmRegistration(e.target[1].value, true, function(err, result) {
				if (err) {
					alert(err.message || JSON.stringify(err));
					return;
				}
				console.log('call result: ' + result);
			});
		}
	}
		
</script>
<svelte:head>
	<script src="./amazon-cognito-identity.min.js" on:load={awsOnload}></script>
</svelte:head>
<form on:submit|preventDefault={signUp}>
	<input>
	<input type="password">
	<input type="email">

	<button type="submit">
		Sign up
	</button>
</form>

<form on:submit|preventDefault={verify}>
	<input>
	<input>

	<button type="submit">
		Verify Token
	</button>
</form>


<form on:submit|preventDefault={signIn}>
	<input>
	<input type="password">
	<button type="submit">
		Log in
	</button>
</form>

<button on:click={() => accessToken = ""}>Sign Out</button>