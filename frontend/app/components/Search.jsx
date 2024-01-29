"use client"
import { gql, useQuery } from '@apollo/client';
import { useState } from 'react';
import Link from 'next/link';

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

export default function Search() {
    const [crowdfundingNames, setCrowdfundingNames] = useState([])
    const [filteredData, setFilteredData] = useState([])

    const { loading: loadingContracts, error: errorContracts, data } = useQuery(GET_CROWDFUNDING_CONTRACTS);

    function handleSearch (t) {
        console.log(t)
        console.log(crowdfundingNames)
        const filtered = data?.fundingContractCreateds?.filter((i) => {
            return i.name.toLowerCase().includes(t.toLowerCase())
        })
        setFilteredData(filtered)
        console.log(filteredData)
        if(t === '') {
            setFilteredData([])
        }
    }

    return(
        <div className='relative'>
            <label className="mb-2 text-sm font-medium text-black sr-only dark:text-[#333333]">Search</label>
            <div className="relative ">
                <div className=" flex absolute inset-y-0 left-0 items-center pl-2 pointer-events-none">
                    <svg className="w-4 h-4 text-black dark:text-[#333333]" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                </div>
                <input onChange={(e) => handleSearch(e.target.value)} type="search" id="default-search" className="block p-3 pl-8 w-full text-sm text-white bg-transparent rounded-lg border border-white focus:ring-blue-500 focus:border-blue-500 dark:bg-transparent dark:border-gray-600 dark:placeholder-[#333333] dark:text-black dark:focus:ring-white dark:focus:border-white" placeholder="Search..." />
                <button type="submit" className="text-white  absolute right-2 bottom-1 bg-transparent hover:bg-transparent focus:ring-2 focus:outline-none focus:ring-blue-300 font-bold rounded-lg text-sm px-2 py-2 dark:bg-[#FF80AC] dark:hover:bg-[#DE6891] dark:focus:ring-[#DE6891]">Search</button>
            </div>

            <div className='absolute top-12 left-0 bg-white p-2 rounded-md w-[250px]'>
                {filteredData?.map((f) => {
                    return(
                        <div key={f.pair} className='mb-2 hover:border-b border-black'>
                            <Link href={`/crowdfunding/${f.pair}`}>
                             {f.name}
                            </Link>
                        </div>
                    )
                })}
            </div>
        </div>
    )
}