"use client"
import Header from "../app/components/Header"
import { gql, useQuery } from '@apollo/client';
import { useEffect } from "react";
import crowdfundingAbi from "../utils/Crowdfunding.json"
import { ethers } from "ethers";
import { useNotification } from '@web3uikit/core';
import { useState } from "react";
import { Link } from "@mui/material";
import Image from 'next/image'
import {CircularProgress} from "@mui/material";

const GET_CROWDFUNDING_CONTRACTS = gql` 
{
    fundingContractCreateds {
        id
        pair
		owner
        name
        description
        target
        categorie
        timeLimit
        imageCid
    }
}
`

export default function Home() {

  const { loading: loadingContracts, error: errorContracts, data } = useQuery(GET_CROWDFUNDING_CONTRACTS);
  const dispatch = useNotification()

  const donations = useState([])

  async function donate(message) {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
		await provider.send("eth_requestAccounts", []);
		const signer = provider.getSigner();
  
 		const contractInstance = new ethers.Contract (
		  "0x7556e8258acc386f9885a7e08fcb961880091de8", crowdfundingAbi, signer
		);
		console.log("Creating")
		
	 	const tx = await contractInstance.donate(message, {gasLimit: 1000000, value: ethers.utils.parseUnits("100", "wei")})
		await tx.wait(1)
		if(tx) {
			dispatch({
				type: "success",
				message: "Donation completed",
				title: "Created",
				position: "topR",
			})

		} else {
			throw new Error("Failed creating the crowdfunding")
		}
		console.log(tx) 

	}

  useEffect(() => {
    console.log(data)
	const newProvider = new ethers.providers.WebSocketProvider("wss://eth-sepolia.g.alchemy.com/v2/jJIBH9hHaXDMrtMz5YWJlQvBSTb_aMnk")
	const contractProvider = new ethers.Contract("0x7556e8258acc386f9885a7e08fcb961880091de8", crowdfundingAbi, newProvider)
  
	contractProvider.on("Donation", (donator, message, amount, percentage, totalDonationOfUser) => {
	  console.log(donator, message, amount, percentage, totalDonationOfUser)
	  donations.push({
		donator: donator,
		message: message,
		amount: Number(amount),
	  })
  	})
  },[data])

  // 0x92063edd13b4655235c39a0dd76abb310f16e080

  return(
    <div className="">
      <Header />
	  {loadingContracts ? (
		<div className="flex items-center justify-center mt-[200px]">
			<CircularProgress color="secondary" size={60}/>
		</div>
	  ) : (
		<div className="flex gap-12 flex-wrap p-8 ">
			    <div className='w-full  md:w-[40%] text-center  m-auto mt-24'>
                    <h1 className='leading-tight text-4xl md:text-6xl text-black font-bold mb-12'>Your home for help</h1>
                    <button 
                        className='bg-white brightness-200 shadow-black shadow-[0px_0px_25px_-5px_rgba(0,0,0,0.3)] text-black md:text-xl text-md md:px-6 md:py-4 p-2 rounded-xl hover:scale-105 duration-300 font-bold'
                        onClick={() => router.push("/createCrowdFunding")}>
                        Create crowdfunding
                    </button>
                </div>
			
		</div>
	  )}

	<div className="p-12 mt-12 ">
		{data?.fundingContractCreateds.map((c) => {
				return (
					<div className="w-[250px] rounded-lg p-2 hover:scale-105 duration-150 ">
						<Link style={{ textDecoration: 'none' }} href={`/crowdfunding/${c.pair}`} scroll={false}>
							<div className="">
								<div className="w-[250px] h-[200px] relative ">
									
									<Image 
										src={`https://ipfs.io/ipfs/${c.imageCid}`}
										fill={true}
										alt={c.name}
										className="rounded-lg"
									/>
								</div>
								<div>
									<h2 className="font-bold my-2 no-underline text-black text-xl mt-6">{c.name}</h2>
								</div>
							</div>
						</Link>
					</div>  
				)
			})}
	</div>
      
    </div>
	)

}