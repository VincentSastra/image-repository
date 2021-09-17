<script>
	let user = {}
	let userSub = {}

	let userName = ""
	let password = ""

	let accessToken = ""

	let signUp, signIn, signOut, verify
	
	let awsOnload = () => {
		const CognitoUserPool = AmazonCognitoIdentity.CognitoUserPool;

		console.log(CognitoUserPool)

		const poolData = {
			UserPoolId: 'us-east-2_IYLA4zOeT', // Your user pool id here
			ClientId: 'uenus0g7i21dvsg1c2590e7fb', // Your client id here
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
					console.log(result)
					accessToken = result.getAccessToken().getJwtToken();
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
	
{JSON.stringify(user)}
{userSub}
{accessToken}

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