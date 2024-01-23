"use client"
import crowdfundingAbi from "../../utils/Crowdfunding.json"
import votingAbi from "../../utils/Voting.json"
import { useEffect, useState } from "react"
import { ethers } from "ethers"
import { useNotification } from '@web3uikit/core';
import { CircularProgress } from "@mui/material";

// Poner la cuenta atras : añadir el block.timestamp al evento
// Mostrar si ya ha votado el usuario
export default function VotingComponent({owner, pair, message, crowdfundingContract}) {
    const [loading, setLoading] = useState(false)
    const dispatch = useNotification()
    const [votes, setVotes] = useState([])
    const [totalVotes,  setTotalVotes] = useState(0)

    async function getVotingData() {
        setLoading(true)
        const newProvider = new ethers.providers.WebSocketProvider("wss://eth-sepolia.g.alchemy.com/v2/jJIBH9hHaXDMrtMz5YWJlQvBSTb_aMnk")
        const contractProvider = new ethers.Contract(pair, votingAbi, newProvider)
        
        const filterDonations = contractProvider.filters.Voted()
        const eventsVotes = await contractProvider.queryFilter(filterDonations)

        setVotes(eventsVotes)
        setTotalVotes((Number(eventsVotes[eventsVotes.length - 1]?.args[1]) / ((Number(eventsVotes[eventsVotes.length - 1]?.args[1]) + Number(eventsVotes[eventsVotes.length - 1]?.args[2]))) * 100))  
        setLoading(false)
    }

    useEffect(() => {
        getVotingData()
    },[])

    console.log(totalVotes)

    async function vote(vote) {
        setLoading(true)
        const provider = new ethers.providers.Web3Provider(window.ethereum);
		await provider.send("eth_requestAccounts", []);
		const signer = provider.getSigner();
        
  
 		const contractInstance = new ethers.Contract (
		  crowdfundingContract, crowdfundingAbi, signer
		);
		console.log(contractInstance)
		
	 	const tx = await contractInstance.vote(vote, pair, {gasLimit: 1000000})
		await tx.wait(1)
		if(tx) {
			dispatch({
				type: "success",
				message: "Vote submitted",
				title: "Created",
				position: "topR",
			})
        
		} else {
			throw new Error("Failed withdrawing")
		}
		console.log(tx) 
        setLoading(false)
    }

    return(
        <div >
            {loading ? (
                <div className="flex items-center justify-center mt-[300px]">
                    <CircularProgress color="secondary" size={60}/>
                </div>
            ) : (
                <div className="w-full rounded-lg mb-12 p-4 bg-[#b2cffe] m-auto flex flex-col items-center gap-4 my-8  text-center">

                    <div>
                        <h3 className="font-bold">{message}</h3>
                        <p>Votes: {votes?.length}</p>
                    </div>


                    <div className=" w-full flex flex-col items-center justify-center lg:gap-8 xl:gap-12 lg:flex-row">
                        <button onClick={() => vote(1)} className='min-w-[150px] md:min-w-[200px] h-10 bg-[#FF80AC] rounded-lg text-white mt-4 font-bold w-[80px]' >Yes</button>
                        <button onClick={() => vote(0)} className='min-w-[150px] md:min-w-[200px] h-10 bg-[#FF80AC] rounded-lg text-white mt-4 font-bold w-[80px]'>No</button>
                    </div> 

                    {votes?.length == 0 ? (
                        <div className="w-[200px] sm:w-[300px] sm:w-[300px] xl:w-[600px] h-[10px] rounded-full bg-zinc-600"></div>
                    ) : (
                        <div className="w-[200px] sm:w-[300px] xl:w-[600px] h-[10px] rounded-full bg-red-700">
                            <div className={`h-[10px] rounded-full w-[${totalVotes && totalVotes}%] bg-green-600`}></div>
                        </div>
                    
                    )}
                </div>
            )}
        </div>
    )
}