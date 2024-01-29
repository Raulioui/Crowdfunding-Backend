"use client"
import { ethers } from "ethers";
import { useEffect, useState } from "react"
import crowdfundingAbi from "../../../utils/Crowdfunding.json"
import { gql, useQuery } from '@apollo/client';
import CrowdfundingComponent from "../../components/CrowdfundingComponent"
import { CircularProgress } from "@mui/material";

export default function Page({params}) {
    const {id} = params
    const [donations, setDonations] = useState([])
    const [withdraws, setWithdraws] = useState([])
    const [votings, setVotings] = useState([])

    const GET_Contracts = gql`
    query Contract($id: String!) {
      fundingContractCreateds(where: {pair: $id}) {
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
  
     const { loading: load, error: err, data: contractData } = useQuery(GET_Contracts, {
      variables: { id },
    }); 

    async function getCrowdfundingData() {
        const newProvider = new ethers.providers.WebSocketProvider("wss://eth-sepolia.g.alchemy.com/v2/vbAE015OkuKDg-T6JKEvXOmpYJuuJ8eN")
        const contractProvider = new ethers.Contract(id, crowdfundingAbi, newProvider)
        console.log(contractProvider)
        const filterDonations = contractProvider.filters.Donation()
        const eventsDonations = await contractProvider.queryFilter(filterDonations)
    
        const filterWithdraws = contractProvider.filters.UserWithdraw()
        const eventsWithdraws = await contractProvider.queryFilter(filterWithdraws)

        const filterVotings = contractProvider.filters.VotingCreated()
        const eventsVotings = await contractProvider.queryFilter(filterVotings)

        setWithdraws(eventsWithdraws)
        setDonations(eventsDonations)
        setVotings(eventsVotings)
    }

    useEffect(() => {
        getCrowdfundingData()
    },[])

    return (
      <div>
        {load ? (
          <div className="flex items-center justify-center mt-[300px]">
					  <CircularProgress color="secondary" size={60}/>
				  </div>
        ) : (
          <div>
            {contractData?.fundingContractCreateds.map((c) => {
              return(
                <CrowdfundingComponent 
                  key={c.id}
                  categorie={c.categorie}
                  description={c.description}
                  imageCid={c.imageCid}
                  name={c.name}
                  owner={c.owner}
                  pair={c.pair}
                  target={ethers.utils.formatEther(c.target)}
                  timeLimit={c.timeLimit}
                  donations={donations}
                  withdraws={withdraws}
                  votings={votings}
                />
              )
          })}
          </div>
        )}
      </div>
    )
}