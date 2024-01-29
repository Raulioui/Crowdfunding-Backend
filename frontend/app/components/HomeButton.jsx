"use client"
import { useRouter } from 'next/navigation';

export default function HomeButton() {
    const router = useRouter()
    return(
        <div className="flex gap-12 flex-wrap p-8 pt-[200px]">
            <div className='w-full  md:w-[40%] text-center  m-auto mt-24'>
                <h1 className='leading-tight text-4xl md:text-6xl text-[#333333] font-bold mb-12'>Your home for help</h1>
                <button 
                    className='bg-white brightness-200 shadow-black shadow-[0px_0px_25px_-5px_rgba(0,0,0,0.3)] text-black md:text-xl text-md md:px-6 md:py-4 p-2 rounded-xl hover:scale-105 duration-300 font-bold'
                    onClick={() => router.push("/create")}>
                    Create crowdfunding
                </button>
            </div>
        </div>
    )
}