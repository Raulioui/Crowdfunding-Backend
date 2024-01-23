"use client"

import Diversity1RoundedIcon from '@mui/icons-material/Diversity1Rounded';
import { useRouter } from 'next/navigation'
import Link from 'next/link';
import { pink } from '@mui/material/colors';
import InputLabel from '@mui/material/InputLabel';
import FormControl from '@mui/material/FormControl';
import Select from '@mui/material/Select';
import { categories } from "../../utils/constants";
import { useState } from 'react';


export default function Header() {

    const router = useRouter()
    const [importantCat, setImportantCat] = useState([])

/*     useEffect(() => {
        setImportantCat(categories?.filter(c => c.isImportant == true));
    },[]) */

    return (
        <header className='flex p-6 md:p-12 justify-around items-center md:justify-between w-full mb-12'>

        <div className='flex items-center  gap-16 '>
            <div >
                <label className="mb-2 text-sm font-medium text-gray-900 sr-only dark:text-gray-300">Search</label>
                <div className="relative ">
                    <div className=" flex absolute inset-y-0 left-0 items-center pl-3 pointer-events-none">
                        <svg className="w-5 h-5 text-gray-500 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                    </div>
                    <input type="search" id="default-search" className="block p-4 pl-10 w-full text-sm text-white bg-transparent rounded-lg border border-white focus:ring-blue-500 focus:border-blue-500 dark:bg-transparent dark:border-gray-600 dark:placeholder-black dark:text-black dark:focus:ring-white dark:focus:border-white" placeholder="Search..." />
                    <button type="submit" className="text-white   absolute right-2.5 bottom-2.5 bg-transparent hover:bg-transparent focus:ring-4 focus:outline-none focus:ring-blue-300 font-bold rounded-lg text-sm px-4 py-2 dark:bg-[#FF80AC] dark:hover:bg-[#DE6891] dark:focus:ring-[#DE6891]">Search</button>
                </div>
            </div>
 
        </div>

        <div className=''>
            <Link href="/home">
                    <div className='flex-col flex  items-center justify-center'>
                        <Diversity1RoundedIcon 
                            sx={{ fontSize: 60, color: pink[300] }}
                        />
                    </div>
                </Link>
        </div>

        <div className='  hidden md:block'>
                     <FormControl  sx={{ m: 0, minWidth: 180, background: "transparent", borderRadius: "10px"}}>
                        <InputLabel className='text-black' id="demo-simple-select-autowidth-label">Discover</InputLabel>
                        <Select
                        labelId="demo-simple-select-autowidth-label"
                        id="demo-simple-select-autowidth"
                        label="Discover"
                        className='rounded-lg border border-black'
                        >
                        <div className='flex flex-col gap-2 m-0 p-2 font-bold  text-white'>
                            {categories?.map(c => {
                                return(
                                <p className='cursor-pointer' onClick={() => router.replace(`/categorie/${c.down}`)}>
                                    {c.up}
                                </p>
                                )
                            })}
                        </div>

                        <p className='p-2 font-bold m-0 underline cursor-pointer   text-white' onClick={() => router.replace(`/categories/all`)}>
                            See all
                        </p> 

                        </Select>
                    </FormControl>
        </div>
    </header>
    )
}