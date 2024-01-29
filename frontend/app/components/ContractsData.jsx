"use client"
import { gql, useQuery } from '@apollo/client';
import Link from 'next/link'
import Image from 'next/image'
import { CircularProgress } from '@mui/material';

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

export default function ContractsData() {

    const { loading: loadingContracts, error: errorContracts, data } = useQuery(GET_CROWDFUNDING_CONTRACTS);

    return (
        <div>
            {loadingContracts ? (
                <CircularProgress />
            ) : (
                <div className=" flex flex-wrap gap-4 items-center">
                    {data?.fundingContractCreateds.slice(0,5).map((c) => {
                        return (
                            <Link key={c?.pair} style={{ textDecoration: 'none' }} href={`/crowdfunding/${c.pair}`} scroll={false}>
                                <div className="w-[250px] h-[300px]  rounded-lg p-2 hover:scale-105 duration-150 ">
                                    <div className="">
                                        <Image 
                                            src={`https://ipfs.io/ipfs/${c.imageCid}`}
                                            height={200}
                                            width={250}
                                            alt={c.name}
                                            className="rounded-lg"
                                        />
                                    </div>
                                    <div>
                                        <h2 className="font-bold my-2 no-underline text-black text-xl mt-6">{c.name}</h2>
                                    </div>
                                </div>
                            </Link>
                        )
                    })}
                </div>
            )}
        </div>
        
    )
}