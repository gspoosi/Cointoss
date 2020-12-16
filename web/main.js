var contract;
var provider;
var accounts;
var signer;
var usr_account;
const address = '0xb3758BE1E6C480a88A683d14C8d184d3Edb74793'

$(document).ready(async function() {
		await window.ethereum.enable()
		provider = new ethers.providers.Web3Provider(window.ethereum);
        accounts = await provider.listAccounts();
        signer = provider.getSigner();
        contract = new ethers.Contract(address, abi, signer)
        signer.getAddress().then(async(res)=>{
                usr_account = res;
                await console.log("Account:" + usr_account);
            });

    	console.log(contract);
    	let potbalance = await contract.getBalance();
		$("#getPotBalance").text(ethers.utils.formatEther(potbalance));
		let balance = await contract.getPriceBalance();
		$("#getBalanceOutput").text(ethers.utils.formatEther(balance));	
    	// This filter could also be generated with the Contract or
		// Interface API. If address is not specified, any address
		// matches and if topics is not specified, any log matches
		contract.on("InitiateCoinToss", async function(player, amount, guess) {
			console.log("InitiateCoinToss");
			console.log(player + " bet " + amount + " on " + guess + ".");
			let balance = await contract.getBalance();
			$("#getPotBalance").text(ethers.utils.formatEther(balance));
			if (player == usr_account) {
				$("#notifier_box").text("Still flipping...");
			}
		});
		contract.on("ThanksForPlaying", async function(player, win) {
			console.log("ThanksForPlaying");
			console.log(player);
			console.log(usr_account);
			if (player == usr_account && win)
			{
				let balance = await contract.getPriceBalance();
				$("#getBalanceOutput").text(ethers.utils.formatEther(balance));
				$("#notifier_box").text("Nice you won!");
			} else if (player == usr_account) {
				$("#notifier_box").text("Sorry mate! No luck, but you should try again!");
			}	
		});
		contract.on("ClaimCollateral", async function(player, amount) {
			console.log("ClaimCollateral");
			console.log(player);
			console.log(usr_account);
			if (player == usr_account)
			{
				let potbalance = await contract.getBalance();
				$("#getPotBalance").text(ethers.utils.formatEther(potbalance));
				let balance = await contract.getPriceBalance();
				$("#getBalanceOutput").text(ethers.utils.formatEther(balance));	
				$("#notifier_box").text("Trying to get lucky")
			}
		});



		$(document).on('click', "#flipCoin_button_head", async function(accounts) {
			var config = {
				value: ethers.utils.parseEther("0.1"),
				from: usr_account
			};
			$("#notifier_box").text("Flipping...");
			await contract.flip("true",config);
		});

		$(document).on('click', "#flipCoin_button_tail", async function(accounts) {
			var config = {
				value: ethers.utils.parseEther("0.1"),
				from: usr_account
			};
			$("#notifier_box").text("Flipping...");
			await contract.flip("false",config);
		});

		$(document).on('click', "#claim_button", async function() {
			contract.claim()
		}); 	
    });



