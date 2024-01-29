"use client"
import { useEffect, useState } from "react";
import { CircularProgress } from "@mui/material";
import { gql, useQuery } from '@apollo/client';
import Link from "next/link";
import Image from "next/image";
import Header from "@/app/components/Header";

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

export default function Page({params: {id}}) {
    const { loading: loadingContracts, error: errorContracts, data } = useQuery(GET_CROWDFUNDING_CONTRACTS);
    const [filteredCrowdfundings, setFilteredCrowdfundings] = useState([])

    useEffect(() => {
        setFilteredCrowdfundings(data?.fundingContractCreateds.filter((c) => c.categorie == id))
    },[data])

    return (
        <div>
            <Header />
            
            <div className="pt-[200px]">
                <h2 className="font-bold text-4xl text-center mb-12">Get help with {id} crowdfundings</h2>
            </div>

            <div>
                {loadingContracts ? (
                    <CircularProgress />
                ) : (
                    <div className="p-6 md:p-12 ">
                        {filteredCrowdfundings.length == 0 ? (
                            <p>No current {id} crowdfundings</p>
                        ) : (
                            filteredCrowdfundings?.map((c) => {
                                return (
                                    <div key={c?.pair} className="w-[250px] rounded-lg p-2 hover:scale-105 duration-150 ">
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
                            })
                        )}
                    </div>
                )}
            </div>

        </div>

    )
}

