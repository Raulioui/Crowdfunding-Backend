"use client"
import React, { useState } from "react";
import Looks3OutlinedIcon from '@mui/icons-material/Looks3Outlined';
import Looks4OutlinedIcon from '@mui/icons-material/Looks4Outlined';
import Looks5OutlinedIcon from '@mui/icons-material/Looks5Outlined';
import LooksTwoOutlinedIcon from '@mui/icons-material/LooksTwoOutlined';
import LooksOneOutlinedIcon from '@mui/icons-material/LooksOneOutlined';
import {Input} from "@web3uikit/core"
import {categories} from "../../utils/constants"
import { useEffect } from 'react';
import { useNotification } from '@web3uikit/core';
import { ethers } from "ethers";
import uploadImageToIPFS from "../../utils/uploadImageToIPFS"
import { useRouter } from 'next/navigation'
import factoryAbi from "../../utils/Factory.json"
import { CircularProgress } from "@mui/material";
import { DemoContainer, DemoItem } from '@mui/x-date-pickers/internals/demo';
import { DateCalendar } from '@mui/x-date-pickers/DateCalendar';

export default function CreateCrowdFundingModal() {

	const [file, setFile] = useState("");
	
	const [uploading, setUploading] = useState(false);
	const dispatch = useNotification()
	const router = useRouter()

	const [name, setName] = useState("");
	const [description, setDescription] = useState("");
	const [target, setTarget] = useState("");
	const [categorie, setCategorie] = useState("");
	const [conversion, setConversion] = useState(0)
	
    const [eth, setEth] = useState(0)
	const [date, setDate] = useState(null)

	const requestOptions = {
		method: 'GET',
		redirect: 'follow'
	};

	useEffect(() => {
        fetch("https://api.coincap.io/v2/assets/ethereum", requestOptions)
          .then(res => res.json())
          .then(dat => setConversion(dat?.data.priceUsd))
    },[])

	const handleSubmit = async (event) => {
		event.preventDefault();
		setUploading(true)
		const imageCid = await uploadImageToIPFS(file)
		const _date = new Date(date)
		const  timeLimit = Math.floor(_date.getTime() / 1000);
	
		const _target = ethers.utils.parseUnits(target.toString(), "gwei") 

		const crowdfunding = {
			name: name,
			description: description,
			target: Number(_target),
			categorie: categorie.toString(),
			timeLimit: timeLimit,
			imageCid: imageCid
		};
		
		await createCrowdfunding(crowdfunding)

		setUploading(false);
	}

	const handleFileChange =  async (e) => {
		if (e.target.files) {
		 const file = await e.target.files[0]
		  setFile(file);		  
	   } 
	};



	async function createCrowdfunding({name, description, target, categorie, timeLimit, imageCid}) {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
		await provider.send("eth_requestAccounts", []);
		const signer = provider.getSigner();
		const contractInstance = new ethers.Contract (
		  "0xDE9934f7BC869dA20EAF63e28485c2112BEaEbdA", factoryAbi, signer
		);
		
		const tx = await contractInstance.createCrowdFunding(name, description, target, categorie, timeLimit, imageCid)
		await tx.wait(1)
		if(tx) {
			dispatch({
				type: "success",
				message: "Crowdfunding created",
				title: "Created",
				position: "topR",
			})
			router.push("/")
		} else {
			throw new Error("Failed creating the crowdfunding")
		}
	}

	function fromDolToEth(dol) {
		setEth(dol * conversion)
	}

	return (
		<div className="">
			{uploading ? (
				<div className="flex items-center justify-center mt-[300px]">
					<CircularProgress color="secondary" size={60}/>
				</div>
			) : (
			<div className="flex flex-col p-6  items-center md:flex-row justify-between ">
				<div className="block text-center md:text-left md:fixed top-[30%] left-20 w-full md:w-[25%]">
					<h2 className="mb-12 text-4xl font bold">Let's begin your fundraising jounery!</h2>
					<p>We're here to guide you every step of the way.</p>
				</div>
				<form onSubmit={handleSubmit} className="pb-8 w-[80%]  md:absolute top-0 right-0 float-right">
					<div className="mt-12 ">

						<div className="flex items-center justify-center gap-4 mb-8">
							<LooksOneOutlinedIcon fontSize='large'/>
								<h2 className='font-bold text-xl'>Choose the title</h2>
						</div>

						<div className='flex items-center justify-center mb-8'>
							<Input
								placeholder="Name:"
								color="white"
								onChange={(e) => setName(e.target.value)}
								required
							/>
						</div>
			
					</div>

					<div className="my-12 text-center">
						<div className='mb-8 flex items-center justify-center gap-4'>
							<LooksTwoOutlinedIcon 
								fontSize="large"
							/>
							<h2 className='font-bold text-xl'>What does your project consist of?</h2>
						</div>

						<div>
							<textarea 
								onChange={(e) => setDescription(e.target.value)}
								className='max-w-[700px]  sm:w-[60%] w-full m-auto overflow-auto bg-transparent text-center  border-2 border-gray-400 rounded-full p-8 resize-none' 
								placeholder='Can you explain your project in a minute?'
								required
							/>
						</div>
					</div>
			
			
			
							<div className="mb-8">

							<div className='flex items-center justify-center gap-4 mb-8'>
								<Looks3OutlinedIcon 
								fontSize="large"
								/>
								<h2 className='font-bold text-xl'>What is your target?</h2>
							</div>
			
							<div className='flex flex-col gap-4 justify-center items-center md:flex-row'>

								<div>
									<Input
									onChange={(e) => {
										fromDolToEth(e.target.value)
										setTarget(Number(e.target.value))
									}}
										placeholder="Eth"
										type="number"
										className=''
										required
									/> 
								</div>
			
								<div className='flex items-center gap-4 justify-left'>
									<p className="font-bold text-lg">{eth.toFixed(2)}</p>
									<p className="font-bold font-bold text-2xl">$</p>
								</div>
			
							</div>
			
							</div>
			
							<div className='flex items-center justify-center gap-4 mb-12  mt-12'>
								<Looks4OutlinedIcon fontSize='large'/>
								<h2 className='font-bold text-xl '>Categories</h2>
							</div>
			
							<div className='flex mb-8 flex-wrap items-center justify-center gap-8 w-full m-auto max-w-[70%] '>
								{categories?.map(c => {
								return (
								<div key={c.down} className="w-[90px] md:w-[130px]">
									<input type="radio" required id={c.down} name="hosting" value={c.down} className="hidden peer" onChange={(e) => setCategorie(e.target.value)}/>
									<label for={c.down} className="flex items-center justify-center px-4 py-2 text-white bg-white border border-gray-200 rounded-lg cursor-pointer dark:hover:text-white dark:border-gray-700 dark:peer-checked:text-white peer-checked:border-[#B12121] peer-checked:text-[#333232] hover:text-gray-600 hover:bg-gray-100 dark:text-gray-400 dark:bg-[#0C0C0E] dark:hover:bg-[#141313]">
										<div className="block">
											<div className="w-full text-sm md:text-md font-bold">{c.up}</div>
										</div>
									</label>
								</div>
								)
								})}
							</div>
						
							<div className="mb-12 flex items-center justify-center mt-16">
								<DemoContainer components={['DateCalendar']}>
									<DemoItem label="Select the time limit">
										<DateCalendar disablePast={true} value={date} onChange={(newValue) => setDate(newValue)} />
									</DemoItem>
								</DemoContainer>
							</div>
			
							<div className='flex items-center justify-center gap-4 mt-18'>
								<Looks5OutlinedIcon fontSize='large'/>
								<h2 className='font-bold text-xl'>Choose an image</h2>
							</div>
			
							<div class="flex flex-col relative items-center justify-center py-8 font-sans w-full md:w-[50%] m-auto mt-8">
			
							<label for="dropzone-file" class="absolute top-0 left-0 cursor-pointer flex w-full flex-col items-center rounded-xl border-2 border-dashed border-blue-400  p-6 h-full text-center"/>
							<svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
								<path stroke-linecap="round" stroke-linejoin="round" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
							</svg>
			
							<h2 class="mt-4 text-xl font-medium text-gray-700 tracking-wide">Payment File</h2>
			
							<p class="mt-2 text-white tracking-wide">Upload or darg & drop your file SVG, PNG, JPG or GIF. </p>
			
							<input onChange={handleFileChange} required id="dropzone-file" type="file" class="hidden" />
							</div>
			
							<div className="w-full mt-12 flex items-center justify-center">
								<button type='submit' className='border border-[#3472D8] font-bold px-8 bg-transparent  rounded-md  py-4 m-2 transition duration-500 w-[150px] md:w-[300px] ease select-none hover:bg-green-600 focus:outline-none focus:shadow-outline w-[15%]'>
									Send
								</button>
							</div>
			
					</form>
					
				</div>
				
			)}
		</div>
	)
}