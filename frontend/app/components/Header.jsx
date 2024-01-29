"use client"
import Diversity1RoundedIcon from '@mui/icons-material/Diversity1Rounded';
import { useRouter } from 'next/navigation'
import Link from 'next/link';
import { pink } from '@mui/material/colors';
import InputLabel from '@mui/material/InputLabel';
import FormControl from '@mui/material/FormControl';
import Select from '@mui/material/Select';
import { categories } from "../../utils/constants";
import Search from "./Search";

export default function Header() {

    const router = useRouter()

    return (
        <header className='bg-white rounded-full flex p-4  justify-around items-center md:justify-between w-full md:w-[90%] m-auto translate-x-[-50%] left-[50%] mt-12 fixed  mb-12'>

        <div className='flex items-center font-bold  px-8'>
            <Search />
        </div>

        <div className=''>
            <Link href="/">
                    <div className='flex-col flex  items-center justify-center'>
                        <Diversity1RoundedIcon 
                            sx={{ fontSize: 60, color: pink[300] }}
                        />
                    </div>
                </Link>
        </div>

        <div className='pr-8  hidden md:block'>
                     <FormControl  sx={{ m: 0, minWidth: 180, background: "transparent", borderRadius: "20px"}}>
                        <InputLabel className='text-[#333333] font-bold' id="demo-simple-select-autowidth-label">Discover</InputLabel>
                        <Select
                        labelId="demo-simple-select-autowidth-label"
                        id="demo-simple-select-autowidth"
                        label="Discover"
                        className='rounded-lg '
                        >
                        <div className='flex flex-col gap-2 m-0 p-2 font-bold'>
                            {categories?.map(c => {
                                return(
                                <p key={c.up} className='cursor-pointer' onClick={() => router.replace(`/categorie/${c.down}`)}>
                                    {c.up}
                                </p>
                                )
                            })}
                        </div>

                        <p className='p-2 font-bold m-0 underline cursor-pointer  ' onClick={() => router.replace(`/categories/all`)}>
                            See all
                        </p> 

                        </Select>
                    </FormControl>
        </div>
    </header>
    )
}